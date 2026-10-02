#!/usr/bin/env python3
import json
import runpy
import tempfile
import unittest
from pathlib import Path

BIN = Path(__file__).parents[1] / "bin"
sync = runpy.run_path(str(BIN / "orca-automations"))
precheck = runpy.run_path(str(BIN / "orca-dev-triage-precheck"))
HOME = "/home/tester"

LIVE = {
    "id": "abc12345-0000",
    "name": "Daily",
    "agentId": "codex",
    "prompt": "do it\n",
    "rrule": "FREQ=DAILY;BYHOUR=9;BYMINUTE=0",
    "timezone": "Asia/Tokyo",
    "runContext": {"path": HOME + "/dotfiles"},
    "precheck": {"command": "bin/check", "timeoutSeconds": 60},
    "reuseSession": False,
    "missedRunGraceMinutes": 120,
    "enabled": True,
}


class SelectorTest(unittest.TestCase):
    def test_expand_and_contract_round_trip(self):
        self.assertEqual(sync["expand_selector"]("path:~/dotfiles", HOME), "path:" + HOME + "/dotfiles")
        self.assertEqual(sync["contract_path"](HOME + "/dotfiles", HOME), "path:~/dotfiles")

    def test_non_home_paths_are_kept(self):
        self.assertEqual(sync["expand_selector"]("name:dotfiles", HOME), "name:dotfiles")
        self.assertEqual(sync["contract_path"]("/opt/x", HOME), "path:/opt/x")
        self.assertEqual(sync["contract_path"](HOME + "x/y", HOME), "path:" + HOME + "x/y")


class SpecTest(unittest.TestCase):
    def exported(self):
        spec = sync["to_spec"](LIVE, HOME)
        spec["prompt"] = LIVE["prompt"]
        return spec

    def test_export_round_trip_has_no_diff(self):
        spec = self.exported()
        self.assertEqual(sync["diff_fields"](sync["spec_view"](spec, HOME), sync["live_view"](LIVE)), [])

    def test_diff_reports_changed_fields(self):
        spec = self.exported()
        spec["enabled"] = False
        spec["precheck"] = "bin/other"
        diff = sync["diff_fields"](sync["spec_view"](spec, HOME), sync["live_view"](LIVE))
        self.assertEqual(diff, ["precheck", "enabled"])

    def test_build_args_create_and_edit(self):
        spec = self.exported()
        create = sync["build_args"](spec, home=HOME)
        self.assertEqual(create[:3], ["orca", "automations", "create"])
        self.assertIn("--enabled", create)
        self.assertIn("--fresh-session", create)
        self.assertEqual(create[create.index("--workspace") + 1], "path:" + HOME + "/dotfiles")
        self.assertEqual(create[create.index("--precheck") + 1], "bin/check")
        edit = sync["build_args"](spec, "abc12345-0000", HOME)
        self.assertEqual(edit[:4], ["orca", "automations", "edit", "abc12345-0000"])

    def test_load_specs_inlines_prompt_and_rejects_duplicates(self):
        with tempfile.TemporaryDirectory() as tmp:
            a, b = Path(tmp, "a"), Path(tmp, "b")
            a.mkdir()
            b.mkdir()
            for d in (a, b):
                (d / "p.md").write_text("hello\n")
                (d / "s.json").write_text(json.dumps({"name": "X", "promptFile": "p.md"}))
            specs = sync["load_specs"]([a])
            self.assertEqual(specs["X"]["prompt"], "hello\n")
            with self.assertRaises(ValueError):
                sync["load_specs"]([a, b])


class PrecheckTest(unittest.TestCase):
    def test_github_repos_from_orca_list(self):
        listing = {"result": {"repos": [
            {"gitRemoteIdentity": {"canonicalKey": "github.com/me/b"}},
            {"gitRemoteIdentity": {"canonicalKey": "github.com/me/a"}},
            {"gitRemoteIdentity": {"canonicalKey": "gitlab.com/me/c"}},
            {"gitRemoteIdentity": None},
        ]}}
        self.assertEqual(precheck["github_repos"](listing), ["me/a", "me/b"])

    def test_failing_workflows_uses_latest_completed_run_per_workflow(self):
        runs = [
            {"workflowName": "CI", "status": "in_progress", "conclusion": "", "databaseId": 5},
            {"workflowName": "CI", "status": "completed", "conclusion": "success", "databaseId": 4},
            {"workflowName": "CI", "status": "completed", "conclusion": "failure", "databaseId": 3},
            {"workflowName": "Deploy", "status": "completed", "conclusion": "failure", "databaseId": 2},
        ]
        self.assertEqual([f["runId"] for f in precheck["failing_workflows"](runs)], [2])

    def test_fingerprint_changes_only_with_findings(self):
        base = [{"repo": "me/a", "prs": [{"number": 1, "updatedAt": "t1"}],
                 "failures": [{"runId": 9}]}]
        same = json.loads(json.dumps(base))
        moved = json.loads(json.dumps(base))
        moved[0]["prs"][0]["updatedAt"] = "t2"
        self.assertEqual(precheck["fingerprint"](base), precheck["fingerprint"](same))
        self.assertNotEqual(precheck["fingerprint"](base), precheck["fingerprint"](moved))


if __name__ == "__main__":
    unittest.main()
