import importlib.util
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


SCRIPT = (Path(__file__).resolve().parents[1] / "stow/agents/.agents/skills/"
          "source-command-worktree/scripts/diagnose.py")
SPEC = importlib.util.spec_from_file_location("diagnose", SCRIPT)
diagnose = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(diagnose)


class WorktreeTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name).resolve()
        self.repo = self.root / "repo"
        self.repo.mkdir()
        self.git(self.repo, "init", "-b", "main")
        self.git(self.repo, "config", "user.name", "Test")
        self.git(self.repo, "config", "user.email", "test@example.invalid")
        self.git(self.repo, "config", "commit.gpgsign", "false")
        (self.repo / "tracked.txt").write_text("initial\n")
        (self.repo / ".gitignore").write_text("cache/\n")
        self.git(self.repo, "add", ".")
        self.git(self.repo, "commit", "-m", "initial")
        self.git(self.repo, "update-ref", "refs/remotes/origin/main", "HEAD")
        self.wt = self.root / "作業 space\nline"
        self.git(self.repo, "worktree", "add", "-b", "topic", str(self.wt))
        observer = patch.object(diagnose, "process_cwds", return_value=([], True))
        observer.start()
        self.addCleanup(observer.stop)

    def git(self, path, *args):
        return subprocess.run(["git", "-C", str(path), *args], check=True,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout

    def report(self):
        return diagnose.inventory([self.repo], [])

    def item(self):
        report = self.report()
        self.assertFalse(report["errors"])
        return report["repositories"][0]["worktrees"][1]

    def test_clean_merged_candidate_and_main_protection(self):
        report = self.report()
        items = report["repositories"][0]["worktrees"]
        self.assertEqual(items[0]["status"], "protected")
        self.assertEqual(items[1]["status"], "review_candidate")
        self.assertEqual(items[1]["path"], str(self.wt))

    def test_tracked_untracked_and_ignored_all_hold(self):
        for name, reason in (("tracked.txt", "tracked_changes"), ("new.txt", "untracked_files"),
                             ("cache/data.txt", "ignored_files")):
            with self.subTest(name=name):
                path = self.wt / name
                path.parent.mkdir(exist_ok=True)
                original = path.read_bytes() if path.exists() else None
                path.write_text("changed\n")
                self.assertIn(reason, self.item()["reasons"])
                if original is not None:
                    path.write_bytes(original)
                else:
                    path.unlink()

    def test_locked_detached_and_current_directory(self):
        self.git(self.repo, "worktree", "lock", str(self.wt))
        self.assertEqual(self.item()["status"], "protected")
        self.git(self.repo, "worktree", "unlock", str(self.wt))
        self.git(self.wt, "checkout", "--detach")
        self.assertIn("detached_head", self.item()["reasons"])
        with patch.object(diagnose.Path, "cwd", return_value=self.wt):
            self.assertIn("current_directory", self.item()["reasons"])

    def test_staged_rename_keeps_untracked_reason(self):
        self.git(self.wt, "mv", "tracked.txt", "renamed.txt")
        (self.wt / "new.txt").write_text("new\n")
        reasons = self.item()["reasons"]
        self.assertIn("tracked_changes", reasons)
        self.assertIn("untracked_files", reasons)

    def test_all_operation_markers_hold(self):
        for marker in diagnose.OPERATIONS:
            with self.subTest(marker=marker):
                path = diagnose.git_path(self.wt, "--path-format=absolute", "--git-path", marker)
                path.touch()
                try:
                    self.assertIn("operation_in_progress:" + marker, self.item()["reasons"])
                finally:
                    path.unlink()

    def test_process_busy_unknown_and_path_boundary(self):
        for paths, known, expected in (([self.wt / "child"], True, "hold"),
                                       ([], False, "hold"),
                                       ([Path(str(self.wt) + "-other")], True, "review_candidate")):
            with patch.object(diagnose, "process_cwds", return_value=(paths, known)):
                self.assertEqual(self.item()["status"], expected)

    def test_missing_and_ambiguous_base_hold(self):
        self.git(self.repo, "update-ref", "refs/remotes/origin/master", "HEAD")
        self.assertIn("base_missing_or_ambiguous", self.item()["reasons"])
        explicit = diagnose.inventory([self.repo], [], "refs/remotes/origin/main")
        self.assertEqual(explicit["repositories"][0]["worktrees"][1]["status"], "review_candidate")
        self.git(self.repo, "update-ref", "-d", "refs/remotes/origin/main")
        self.git(self.repo, "update-ref", "-d", "refs/remotes/origin/master")
        self.assertIn("base_missing_or_ambiguous", self.item()["reasons"])

    def test_unmerged_and_squash_hold(self):
        (self.wt / "tracked.txt").write_text("feature\n")
        self.git(self.wt, "commit", "-am", "feature")
        self.assertIn("not_ancestor_squash_unverified", self.item()["reasons"])
        self.git(self.repo, "merge", "--squash", "topic")
        self.git(self.repo, "commit", "-m", "squashed")
        self.git(self.repo, "update-ref", "refs/remotes/origin/main", "HEAD")
        self.assertIn("not_ancestor_squash_unverified", self.item()["reasons"])

    def test_missing_directory_and_identity_mismatch_hold(self):
        moved = self.root / "moved"
        self.wt.rename(moved)
        self.assertEqual(self.item()["status"], "prune_review")
        self.wt.mkdir()
        self.assertEqual(self.item()["status"], "hold")

    def test_submodule_ignored_only_files_hold(self):
        self.git(self.wt, "-c", "protocol.file.allow=always", "submodule", "add", str(self.repo), "module")
        self.git(self.wt, "commit", "-am", "add submodule")
        self.git(self.wt, "update-ref", "refs/remotes/origin/main", "HEAD")
        cache = self.wt / "module/cache"
        cache.mkdir()
        (cache / "data.txt").write_text("local only\n")
        # Demonstrate the blind spot before verifying our conservative guard.
        self.assertEqual(self.git(self.wt, "status", "--porcelain=v1", "--ignored",
                                  "--ignore-submodules=none"), b"")
        item = self.item()
        self.assertEqual(item["status"], "hold")
        self.assertIn("submodules_uninspected", item["reasons"])

    def test_parent_discovery_and_common_dir_dedup(self):
        report = diagnose.inventory([self.repo, self.wt], [self.root])
        self.assertFalse(report["errors"])
        self.assertEqual(len(report["repositories"]), 1)
        self.assertEqual(len(report["repositories"][0]["worktrees"]), 2)

    def test_git_failure_never_becomes_candidate(self):
        original = diagnose.git

        def failing(repo, *args, **kwargs):
            if args[0] == "status":
                raise diagnose.ProbeError("status unavailable")
            return original(repo, *args, **kwargs)

        with patch.object(diagnose, "git", side_effect=failing):
            self.assertEqual(self.item()["status"], "hold")

    def test_diagnostic_has_no_mutating_commands_or_index_writes(self):
        paths = [self.repo / ".git/index", diagnose.git_path(self.wt, "--git-path", "index")]
        before = [(p.stat().st_mtime_ns, p.read_bytes()) for p in paths]
        original, commands = diagnose.run, []

        def recording(argv):
            commands.append(argv[4:])  # git --no-optional-locks -C path command...
            return original(argv)

        with patch.object(diagnose, "run", side_effect=recording):
            self.assertEqual(self.item()["status"], "review_candidate")
        for command in commands:
            self.assertFalse(set(command) & {"fetch", "prune", "remove", "update-ref", "checkout"})
        self.assertEqual(before, [(p.stat().st_mtime_ns, p.read_bytes()) for p in paths])

    def test_lsof_failure_and_nul_paths(self):
        # Use the real function despite the setUp observation fixture.
        with patch.object(diagnose, "run", side_effect=diagnose.ProbeError("unavailable")):
            paths, known = WorktreeTest.original_process_cwds()
            self.assertEqual((paths, known), ([], False))
        raw = b"p123\0\nn" + os.fsencode(self.wt) + b"\0\n"
        for stderr, expected in ((b"", True), (b"incomplete observation", False)):
            result = subprocess.CompletedProcess([], 0, raw, stderr)
            with patch.object(diagnose, "run", return_value=result):
                paths, known = WorktreeTest.original_process_cwds()
                self.assertEqual(paths, [self.wt])
                self.assertEqual(known, expected)


WorktreeTest.original_process_cwds = staticmethod(diagnose.process_cwds)


if __name__ == "__main__":
    unittest.main()
