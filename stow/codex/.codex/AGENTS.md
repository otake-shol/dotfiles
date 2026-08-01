# Global Codex Instructions

## Language

- Default to Japanese for user-facing explanations unless the user asks otherwise.
- Keep final answers concise and include concrete verification results when files changed.

## 資料文体ルール

- 資料タイトル・見出しは体言止め。本文では「Aは、B。」構文を原則禁止。
- 助詞直後の不要な読点を入れない。「Aを、Bする」「Aが、Bになる」「Aで。Bする」は、誤読防止の必要がない限り「AをBする」「AがBになる」「AでBする」に修正する。
- 読点は意味の切れ、並列、長文の誤読防止に必要な場合のみ使用。
- 出力前に「は、」「を、」「が、」「で、」「など、」を全件確認し、不要な読点を削除する。

## Working Style

- Read the local code and project instructions before making changes.
- Prefer existing patterns over new abstractions.
- Use `rg` / `rg --files` for search.
- Use `apply_patch` for hand edits.
- Do not revert user changes unless explicitly asked.
- When a task changes code, run the narrowest useful verification before finishing.

## Model Routing

- Keep routine, clear, single-component work in the main agent; do not delegate it.
- Codex should use the `explorer` agent for read-only scans spanning many files, large logs, or other noisy evidence that can be summarized compactly.
- Codex should use the `worker` agent only for an independent, bounded implementation that can run in parallel with different main-agent work.
- Codex should use the `expert` agent for security, data-loss, concurrency, or migration risk, or when at least two of these apply: ambiguous requirements, three or more affected components, multiple plausible root causes, or one failed implementation attempt.
- Codex should use the `reviewer` agent after a non-trivial change only when correctness risk is elevated, such as security, concurrency, persistence, compatibility, or a public API contract.
- Use at most two subagents per task. Do not delegate recursively, assign duplicate work, or repeat a completed scan without a concrete evidence gap.
- Ask subagents for evidence-based summaries under 800 tokens. Keep raw logs and broad exploration out of the main thread.
- `gpt-5.5` and Codex-Spark are manual comparison profiles; do not route to them automatically without representative eval evidence.

## Safety

- Do not read or write `.env`, `*credentials*`, `*.key`, or files under `~/.ssh/`.
- Ask before destructive operations such as `rm -rf`, `git reset --hard`, `git push --force`, `brew uninstall`, or `stow -D`.
- Avoid piping remote scripts into a shell. If installation is needed, inspect instructions first.
- Do not expose tokens, API keys, cookies, or private auth files in responses.

## Coding Conventions

- Follow each repository's own `AGENTS.md`, `CLAUDE.md`, README, formatter, and test setup.
- Shell scripts should use `#!/bin/bash`, `set -euo pipefail`, `local` declarations where appropriate, and pass ShellCheck.
- Use Conventional Commits when asked to commit.
- For Node projects, follow the lockfile to choose the package manager.

## Verification Defaults

- For this dotfiles repository, prefer `make lint`, `make check`, and `make doctor` as appropriate.
- For TypeScript/React projects, prefer typecheck, lint, unit tests, and targeted Playwright checks based on the change.
