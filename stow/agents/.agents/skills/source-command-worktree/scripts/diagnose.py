#!/usr/bin/env python3
"""Read-only worktree inventory. Candidates always require human review."""

import argparse
from collections import Counter
import json
import os
from pathlib import Path
import subprocess


class ProbeError(Exception):
    pass


def run(argv):
    try:
        return subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              env={**os.environ, "GIT_OPTIONAL_LOCKS": "0"}, timeout=30)
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise ProbeError("command unavailable or timed out") from exc


def git(repo, *args, allowed=(0,)):
    result = run(["git", "--no-optional-locks", "-C", str(repo), *args])
    if result.returncode not in allowed:
        raise ProbeError("git " + args[0] + " failed")
    return result


def decode(value):
    return os.fsdecode(value)


def git_path(repo, *args):
    # rev-parse emits a single path followed by one newline; preserve path newlines.
    return Path(decode(git(repo, "rev-parse", *args).stdout.removesuffix(b"\n"))).resolve()


def within(path, parent):
    return path == parent or parent in path.parents


def records(raw):
    entry = {}
    for field in raw.split(b"\0"):
        if not field:
            if entry:
                yield entry
                entry = {}
            continue
        key, _, value = field.partition(b" ")
        entry[decode(key)] = decode(value)
    if entry:
        yield entry


def process_cwds():
    try:
        result = run(["lsof", "-nP", "-a", "-u", str(os.getuid()), "-d", "cwd", "-F0pn"])
    except ProbeError:
        return [], False
    paths = [Path(decode(field[1:])).resolve()
             for field in (part.lstrip(b"\n") for part in result.stdout.split(b"\0"))
             if field.startswith(b"n/")]
    return paths, result.returncode == 0 and not result.stderr and bool(paths)


def select_base(repo, requested):
    if requested:
        refs = [requested]
    else:
        symbolic = git(repo, "symbolic-ref", "-q", "refs/remotes/origin/HEAD", allowed=(0, 1))
        refs = ([decode(symbolic.stdout).rstrip("\n")] if symbolic.returncode == 0
                else ["refs/remotes/origin/main", "refs/remotes/origin/master"])
    found = []
    for ref in refs:
        result = git(repo, "rev-parse", "--verify", "--end-of-options", ref + "^{commit}", allowed=(0, 128))
        if result.returncode == 0:
            found.append((ref, decode(result.stdout).strip()))
    return found[0] if len(found) == 1 else (None, None)


OPERATIONS = ("MERGE_HEAD", "rebase-merge", "rebase-apply", "CHERRY_PICK_HEAD",
              "REVERT_HEAD", "BISECT_LOG", "sequencer")


def status_reasons(raw):
    reasons = set()
    fields = iter(raw.split(b"\0"))
    for field in fields:
        if not field:
            continue
        code = field[:2]
        reasons.add({b"??": "untracked_files", b"!!": "ignored_files"}.get(code, "tracked_changes"))
        if b"R" in code or b"C" in code:
            next(fields, None)  # The next NUL field is the original rename/copy path.
    return sorted(reasons)


def diagnose(repo, entry, first, common, base_oid, cwds, processes_known):
    path = Path(entry["worktree"]).resolve()
    item = {"path": str(path), "branch": entry.get("branch"),
            "head": entry.get("HEAD"), "status": "hold", "reasons": []}
    reasons = item["reasons"]
    for condition, reason in ((first, "main_worktree"), ("locked" in entry, "locked"),
                              ("bare" in entry, "bare"), (within(Path.cwd().resolve(), path), "current_directory")):
        if condition:
            reasons.append(reason)
    if reasons:
        item["status"] = "protected"
        return item
    if not path.exists():
        item["status"] = "prune_review"
        reasons.append("directory_missing_manual_check")
        return item
    try:
        if (not (path / ".git").is_file()
                or git_path(path, "--path-format=absolute", "--show-toplevel") != path
                or git_path(path, "--path-format=absolute", "--git-common-dir") != common):
            raise ProbeError("worktree identity mismatch")
        if "detached" in entry or not entry.get("branch"):
            reasons.append("detached_head")
        status = git(path, "status", "--porcelain=v1", "-z", "--untracked-files=all",
                     "--ignored=matching", "--ignore-submodules=none").stdout
        reasons.extend(status_reasons(status))
        # Superproject status does not expose ignored-only files inside submodules.
        index = git(path, "ls-files", "--stage", "-z").stdout
        if any(field.startswith(b"160000 ") for field in index.split(b"\0")):
            reasons.append("submodules_uninspected")
        for marker in OPERATIONS:
            if git_path(path, "--path-format=absolute", "--git-path", marker).exists():
                reasons.append("operation_in_progress:" + marker)
        if any(within(cwd, path) for cwd in cwds):
            reasons.append("process_cwd_inside")
        if not processes_known:
            reasons.append("process_state_unknown")
        if base_oid is None:
            reasons.append("base_missing_or_ambiguous")
        elif git(path, "merge-base", "--is-ancestor", entry["HEAD"], base_oid, allowed=(0, 1)).returncode:
            reasons.append("not_ancestor_squash_unverified")
        # A concurrent checkout must not turn an older snapshot into a candidate.
        head = decode(git(path, "rev-parse", "HEAD").stdout).strip()
        branch = git(path, "symbolic-ref", "-q", "HEAD", allowed=(0, 1))
        if head != entry.get("HEAD") or decode(branch.stdout).rstrip("\n") != entry.get("branch", ""):
            reasons.append("head_changed_during_scan")
    except (ProbeError, OSError, KeyError) as exc:
        reasons.append("inspection_failed:" + (str(exc) if isinstance(exc, ProbeError) else type(exc).__name__))
    if not reasons:
        item["status"] = "review_candidate"
        reasons.append("ancestor_of_local_base")
    return item


def inventory(repos, parents, base=None):
    errors, seeds = [], list(repos)
    for parent in parents:
        try:
            seeds.extend(child for child in sorted(Path(parent).expanduser().iterdir())
                         if (child / ".git").exists())
        except OSError:
            errors.append({"path": str(parent), "reason": "parent_unreadable"})
    cwds, known = process_cwds()
    seen, output = set(), []
    for seed in seeds:
        repo = Path(seed).expanduser().resolve()
        try:
            common = git_path(repo, "--path-format=absolute", "--git-common-dir")
            if common in seen:
                continue
            seen.add(common)
            entries = list(records(git(repo, "worktree", "list", "--porcelain", "-z").stdout))
            ref, oid = select_base(repo, base)
            output.append({"repository": entries[0]["worktree"], "base": ref, "base_oid": oid,
                           "worktrees": [diagnose(repo, entry, i == 0, common, oid, cwds, known)
                                         for i, entry in enumerate(entries)]})
        except (ProbeError, OSError, KeyError, IndexError) as exc:
            errors.append({"path": str(repo), "reason": str(exc) if isinstance(exc, ProbeError) else type(exc).__name__})
    return {"schema_version": 1, "read_only": True,
            "limitations": ["local_refs_only_no_fetch", "squash_merge_unverified",
                            "same_user_cwd_observation_only", "orca_sessions_unverified",
                            "snapshot_not_deletion_authorization"],
            "repositories": output, "errors": errors}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", action="append", default=[], help="repository path (repeatable)")
    parser.add_argument("--parent", action="append", default=[], help="scan immediate child repositories (repeatable)")
    parser.add_argument("--base", help="explicit merge target ref; no fetch")
    parser.add_argument("--json", action="store_true", help="machine-readable report")
    args = parser.parse_args()
    report = inventory(args.repo or ([] if args.parent else [Path.cwd()]), args.parent, args.base)
    if args.json:
        print(json.dumps(report, ensure_ascii=True, indent=2))
    else:
        print("読み取り専用診断: ローカルrefのみ。squash merge・Orcaセッションは未確認。候補は削除許可ではありません。")
        counts = Counter()
        for repo in report["repositories"]:
            print("\nRepository:", json.dumps(repo["repository"], ensure_ascii=False), " Base:", repo["base"])
            for item in repo["worktrees"]:
                counts[item["status"]] += 1
                print(item["status"], json.dumps(item["path"], ensure_ascii=False), ":", ", ".join(item["reasons"]))
        print("\nSummary:", dict(counts))
        for error in report["errors"]:
            print("ERROR:", json.dumps(error, ensure_ascii=False))
    return 1 if report["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
