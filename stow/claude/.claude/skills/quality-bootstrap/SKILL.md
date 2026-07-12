---
name: quality-bootstrap
description: Set up the AI-development quality safety net (unit tests, lint, format, browser smoke, a `verify` script, GitHub Actions CI, and an enforcing Stop hook) in the current repository. Use when starting a new product, or when a repo lacks automated tests / CI / lint and you want to systematize regression prevention. Mirrors the catchup-studio reference setup.
---

# quality-bootstrap

Goal: make "prevent bugs by mechanism, not vigilance" real in this repo. See `~/.claude/engineering-quality.md` for the principle.

## Steps

1. **Survey current state** (don't assume): tests? CI (`.github/workflows`)? lint/format config? `package.json` scripts/deps? lockfile? Node pinned? Report the gaps before changing anything.

2. **Decide the dependency stance** with the user (default = hybrid): keep runtime deps minimal; allow `devDependencies` for tooling. Units via `node:test` (zero-dep) or Vitest; UI smoke via Playwright; ESLint + Prettier.

3. **Make code testable**: pure functions (parsers/normalizers/serializers/calculations) must be importable without side effects. Prefer extracting them to a `lib/` module; the lighter path is to guard the entrypoint (`if (isMain) { server.listen(...) }` / `if (isMain) { main() }`) and `export` the pure functions so tests can import them.

4. **Add tests**:
   - `test/unit/*.test.mjs` — cover pure functions, including their failure/throw cases and round-trips (parse↔serialize). Let tests reveal real behavior (don't assume).
   - For a UI/server: `test/smoke.test.mjs` — spawn the server, load it in a real browser (Playwright), assert no `pageerror` + key elements render, and that core API endpoints respond. This catches the "embedded client JS broke but syntax-check passed" class.

5. **Wire scripts** in `package.json`:
   - `test` (units), `smoke` (browser), `lint` (eslint .), `format` / `format:write` (prettier), `verify` = `check + lint + test`.
   - Add `engines` (Node pin). Commit the lockfile; gitignore `node_modules`.

6. **Config**: lean ESLint flat config (catch `no-undef`/`no-dupe-keys`; style → Prettier; downgrade noisy rules to warn so `lint` is green). `.prettierrc` + `.prettierignore`. Allow browser globals only for files with `page.evaluate` callbacks.

7. **CI**: `.github/workflows/ci.yml` running `npm ci` → `npm run verify`, plus a separate job installing the browser for `npm run smoke`.

8. **Make it loaded & enforced**:
   - `<repo>/CLAUDE.md`: a "Quality Gate / Definition of Done" section ("run `npm run verify` before done; `npm run smoke` if UI touched"), pointing to `docs/quality.md`.
   - `<repo>/.claude/settings.json`: a `Stop` hook that runs `npm test` only when `scripts`/`test` changed (`git diff --quiet`), surfacing failures.

9. **Verify the net itself**: run `npm run verify` and `npm run smoke`; confirm green. Then summarize what now protects the repo and what remains (follow-ups: extract `lib/`, dedup parsers, add timeouts, type-check via JSDoc `tsc --checkJs`).

## Notes
- Don't let lint become a cleanup rabbit hole: keep the config lean, warnings non-blocking, errors only for real bugs.
- Keep the unit test loop fast/browserless; keep the browser smoke as a separate script/CI job.
