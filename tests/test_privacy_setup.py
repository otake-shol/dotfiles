from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parent.parent


class PrivacySetupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.repo = self.base / "repo"
        self.config = self.base / "config"
        self.source = self.repo / "stow/claude/.claude"
        self.source.mkdir(parents=True)

    def setup_local(self):
        return subprocess.run(
            ["python3", str(ROOT / "bin/setup-claude-local"), "--repo", str(self.repo),
             "--config-dir", str(self.config)], capture_output=True, text=True)

    def test_migration_preserves_content_and_is_repeatable(self):
        profile = self.source / "profile.local.md"
        profile.write_text("private profile fixture\n")
        fact = self.source / "skills/fact"
        fact.mkdir(parents=True)
        (fact / "SKILL.md").write_text("private skill fixture\n")
        for _ in range(2):
            result = self.setup_local()
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(profile.is_symlink())
        self.assertTrue(fact.is_symlink())
        self.assertEqual(profile.read_text(), "private profile fixture\n")
        self.assertEqual((fact / "SKILL.md").read_text(), "private skill fixture\n")
        self.assertNotIn(self.repo, profile.resolve().parents)
        self.assertEqual(profile.stat().st_mode & 0o777, 0o600)
        subprocess.run(["git", "init", "--quiet", "--template=", str(self.repo)], check=True)
        shutil.copyfile(ROOT / ".gitignore", self.repo / ".gitignore")
        for path in (profile, fact):
            result = subprocess.run(["git", "check-ignore", "-q", str(path.relative_to(self.repo))],
                                    cwd=self.repo)
            self.assertEqual(result.returncode, 0, "private symlink must stay ignored")

    def test_collision_preserves_both_sources_before_any_move(self):
        profile = self.source / "profile.local.md"
        profile.write_text("original\n")
        fact = self.source / "skills/fact"
        fact.mkdir(parents=True)
        (fact / "SKILL.md").write_text("original skill\n")
        destination = self.config / "dotfiles-local/claude/skills/fact"
        destination.mkdir(parents=True)
        (destination / "SKILL.md").write_text("different skill\n")
        self.assertNotEqual(self.setup_local().returncode, 0)
        self.assertFalse(profile.is_symlink())
        self.assertEqual(profile.read_text(), "original\n")
        self.assertEqual((destination / "SKILL.md").read_text(), "different skill\n")

    def test_destination_inside_checkout_rejected(self):
        self.config = self.repo / "private"
        self.assertNotEqual(self.setup_local().returncode, 0)
        self.assertFalse(self.config.exists())

    def test_unrelated_source_symlink_untouched(self):
        other = self.base / "other.md"
        other.write_text("keep\n")
        (self.source / "profile.local.md").symlink_to(other)
        self.assertNotEqual(self.setup_local().returncode, 0)
        self.assertEqual(other.read_text(), "keep\n")

    def test_dangling_destination_symlink_untouched(self):
        destination = self.config / "dotfiles-local/claude/profile.local.md"
        destination.parent.mkdir(parents=True)
        destination.symlink_to(self.base / "missing")
        (self.source / "profile.local.md").write_text("keep\n")
        self.assertNotEqual(self.setup_local().returncode, 0)
        self.assertTrue(destination.is_symlink())
        self.assertFalse((self.source / "profile.local.md").is_symlink())

    def test_managed_directory_symlink_rejected(self):
        root = self.config / "dotfiles-local"
        root.mkdir(parents=True)
        (root / "claude").symlink_to(self.repo, target_is_directory=True)
        self.assertNotEqual(self.setup_local().returncode, 0)
        self.assertFalse((self.repo / "profile.local.md").exists())

    def test_rules_symlink_rejected_before_migration(self):
        rules = self.config / "dotfiles-local/privacy/blocked-phrases.txt"
        rules.parent.mkdir(parents=True)
        rules.symlink_to(self.base / "missing")
        (self.source / "profile.local.md").write_text("keep\n")
        self.assertNotEqual(self.setup_local().returncode, 0)
        self.assertFalse((self.source / "profile.local.md").is_symlink())
        self.assertFalse((self.base / "missing").exists())

    def test_hook_preserves_existing_hook_and_its_input(self):
        subprocess.run(["git", "init", "--template=", str(self.repo)], check=True,
                       capture_output=True)
        (self.repo / "bin").mkdir()
        (self.repo / ".githooks").mkdir()
        shutil.copyfile(ROOT / "bin/setup-privacy-hook", self.repo / "bin/setup-privacy-hook")
        shutil.copyfile(ROOT / ".githooks/pre-push", self.repo / ".githooks/pre-push")
        (self.repo / "bin/check-public-content").write_text(
            "import sys\nfrom pathlib import Path\n"
            "Path('scanner-input').write_text(sys.stdin.read())\n")
        hooks = self.repo / ".git/hooks"
        hooks.mkdir(exist_ok=True)
        prior = hooks / "pre-push"
        prior.write_text('#!/bin/bash\ncat > prior-input\nprintf "%s\\n" "$@" > prior-args\n')
        prior.chmod(0o755)
        for _ in range(2):
            result = subprocess.run(["python3", str(self.repo / "bin/setup-privacy-hook")],
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
        update = "refs/heads/main abc refs/heads/main def\n"
        result = subprocess.run([str(prior), "origin", "local-remote"], cwd=self.repo,
                                input=update, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.repo / "scanner-input").read_text(), update)
        self.assertEqual((self.repo / "prior-input").read_text(), update)
        self.assertEqual((self.repo / "prior-args").read_text(), "origin\nlocal-remote\n")
        edited = prior.read_bytes() + b"# user edit\n"
        prior.write_bytes(edited)
        result = subprocess.run(["python3", str(self.repo / "bin/setup-privacy-hook")],
                                capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(prior.read_bytes(), edited)


if __name__ == "__main__":
    unittest.main()
