#!/usr/bin/env python3
import os
import runpy
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


CHECK = Path(__file__).parents[1] / "bin/check-public-content"


class PublicContentTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.repo = Path(self.temp.name)
        self.git("init", "-q", "--template=")
        self.git("config", "user.email", "test@example.invalid")
        self.git("config", "user.name", "Test")
        self.rules_dir = tempfile.TemporaryDirectory()
        self.rules = Path(self.rules_dir.name) / "rules.txt"
        self.rules.write_text("family-private-phrase\n")

    def tearDown(self):
        self.rules_dir.cleanup()
        self.temp.cleanup()

    def git(self, *args, input=None):
        return subprocess.run(["git", *args], cwd=self.repo, input=input, text=True,
                              capture_output=True, check=True)

    def write(self, name, text):
        target = self.repo / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text)

    def commit(self, message):
        self.git("add", ".")
        self.git("commit", "-qm", message)
        return self.git("rev-parse", "HEAD").stdout.strip()

    def check(self, flag, stdin=""):
        return subprocess.run([str(CHECK), flag, "--rules-file", str(self.rules)], cwd=self.repo,
                              input=stdin, text=True, capture_output=True)

    def test_staged_not_unstaged_and_secret_is_redacted(self):
        self.write("note.md", "clean\n")
        self.git("add", "note.md")
        self.assertEqual(self.check("--index").returncode, 0)
        github_token = "ghp_" + "A" * 36
        self.write("note.md", github_token + "\n")
        self.assertEqual(self.check("--index").returncode, 0)
        self.git("add", "note.md")
        result = self.check("--index")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("GitHub token", result.stderr)
        self.assertNotIn(github_token, result.stderr)
        self.write("later.md", "another staged change\n")
        self.git("add", "later.md")
        self.assertIn("GitHub token", self.check("--index").stderr)

    def test_local_phrase_and_forbidden_paths_are_blocked_without_reading(self):
        self.write("journal.md", "family-private-phrase\n")
        self.git("add", "journal.md")
        phrase_result = self.check("--index")
        self.assertIn("private phrase", phrase_result.stderr)
        self.assertNotIn("family-private-phrase", phrase_result.stderr)
        self.git("rm", "--cached", "-q", "journal.md")
        self.write("notes.local.md", "ordinary\n")
        self.git("add", "notes.local.md")
        self.assertIn("local note", self.check("--index").stderr)
        self.git("rm", "--cached", "-q", "notes.local.md")

    def test_protected_paths_are_checked_from_metadata_only(self):
        module = runpy.run_path(str(CHECK), run_name="scanner_test")
        scanner = module["Scanner"](())
        with patch.dict(scanner.scan_blob.__globals__,
                        {"run_git": lambda *args: self.fail("protected contents were read")}):
            for path, oids in module["UNREAD_BASELINES"].items():
                for oid in oids:
                    scanner.scan_blob(path, "100644", oid)
            self.assertFalse(scanner.findings)
            scanner.scan_blob(".env", "100644", "a" * 40)
            scanner.scan_blob("stow/ssh/.ssh/config", "100644", "b" * 40)
            self.assertEqual(len(scanner.findings), 2)

    def test_non_utf8_and_json_key_are_detected_without_logging_values(self):
        token = "ghp_" + "A" * 36
        (self.repo / "mixed.txt").write_bytes(token.encode() + b"\xff")
        marker = "-----BEGIN " + "PRIVATE KEY-----"
        self.write("settings.json", '{"private_key": "' + marker + '"}\n')
        self.git("add", "mixed.txt", "settings.json")
        result = self.check("--index")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("GitHub token", result.stderr)
        self.assertIn("private-key marker", result.stderr)
        self.assertNotIn(token, result.stderr)
        self.assertNotIn(marker, result.stderr)

    def test_symlinks_are_not_followed_and_clean_content_is_allowed(self):
        self.write("clean.md", "ordinary public documentation\n")
        os.symlink("/etc/passwd", self.repo / "linked.md")
        self.git("add", "clean.md", "linked.md")
        self.assertEqual(self.check("--index").returncode, 0)

    def test_private_paths_and_pem_marker_are_classified(self):
        self.write("stow/claude/.claude/skills/fact/rule.md", "ordinary\n")
        self.write("auth.json", "{}\n")
        self.write("public.txt", "-----BEGIN " + "PRIVATE KEY-----\n")
        self.git("add", "stow/claude/.claude/skills/fact/rule.md", "auth.json", "public.txt")
        result = self.check("--index")
        self.assertIn("private fact skill", result.stderr)
        self.assertIn("authentication file", result.stderr)
        self.assertIn("private-key marker", result.stderr)

    def test_project_token_and_documented_samples(self):
        project_token = "sk-" + "proj-" + "A" * 24
        aws_example = "AKIA" + "IOSFODNN7EXAMPLE"
        placeholder = "ghp_" + "x" * 36
        self.write("keys.md", project_token + "\n")
        self.write(".gitconfig", aws_example + "\n" + placeholder + "\n")
        self.git("add", "keys.md", ".gitconfig")
        result = self.check("--index")
        self.assertIn("OpenAI key", result.stderr)
        self.assertNotIn("AWS access key", result.stderr)
        self.assertNotIn("GitHub token", result.stderr)

    def test_push_catches_removed_history_and_commit_message(self):
        self.write("old.md", "family-private-phrase\n")
        first = self.commit("private phrase family-private-phrase")
        self.write("old.md", "removed\n")
        last = self.commit("remove content")
        result = self.check("--pre-push", f"refs/heads/main {last} refs/heads/main {'0' * 40}\n")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(first[:12], result.stderr)
        self.assertNotIn("family-private-phrase", result.stderr)

    def test_push_unknown_base_full_history_and_deletion_are_safe(self):
        self.write("history.md", "family-private-phrase\n")
        head = self.commit("history")
        unknown = "1" * 40
        result = self.check("--pre-push", f"refs/heads/main {head} refs/heads/main {unknown}\n")
        self.assertNotEqual(result.returncode, 0)
        deletion = self.check("--pre-push", f"(delete) {'0' * 40} refs/heads/main {head}\n")
        self.assertEqual(deletion.returncode, 0)

    def test_push_scans_merge_commit_tree(self):
        self.write("base.md", "base\n")
        self.commit("base")
        base_branch = self.git("symbolic-ref", "--short", "HEAD").stdout.strip()
        self.git("checkout", "-qb", "side")
        self.write("merged.md", "family-private-phrase\n")
        self.commit("side content")
        self.git("checkout", "-q", base_branch)
        self.write("main.md", "main\n")
        self.commit("main content")
        self.git("merge", "--no-ff", "-qm", "merge side", "side")
        merge = self.git("rev-parse", "HEAD").stdout.strip()
        result = self.check("--pre-push", f"refs/heads/{base_branch} {merge} refs/heads/{base_branch} {'0' * 40}\n")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(merge[:12], result.stderr)

    def test_installed_hook_blocks_real_push_before_remote_update(self):
        (self.repo / "bin").mkdir()
        shutil.copyfile(CHECK, self.repo / "bin/check-public-content")
        hooks = self.repo / ".git/hooks"
        hooks.mkdir(exist_ok=True)
        hook = hooks / "pre-push"
        shutil.copyfile(CHECK.parent.parent / ".githooks/pre-push", hook)
        hook.chmod(0o755)
        remote = Path(self.rules_dir.name) / "remote.git"
        self.git("init", "--bare", "--template=", str(remote))
        self.write("readme.md", "public fixture\n")
        clean = self.commit("clean")
        self.git("push", str(remote), "HEAD:refs/heads/main")
        token = "ghp_" + "A" * 36
        self.write("accident.txt", token)
        self.commit("accidental content")
        self.write("accident.txt", "removed\n")
        self.commit("remove accidental content")
        result = subprocess.run(["git", "push", str(remote), "HEAD:refs/heads/main"],
                                cwd=self.repo, capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("GitHub token", result.stderr)
        self.assertNotIn(token, result.stderr)
        actual = subprocess.check_output(["git", "--git-dir", str(remote),
                                          "rev-parse", "refs/heads/main"], text=True).strip()
        self.assertEqual(actual, clean)


if __name__ == "__main__":
    unittest.main()
