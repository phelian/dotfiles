---
description: "Fan out specialized agents for a complete multi-dimensional code review and write a summary report"
argument-hint: "[all | diff | <path>]  (default: branch + working-tree changes)"
---

Run a complete, multi-dimensional code review by fanning out specialized review agents, then write a single summary report to the repo root.

## 1. Determine scope

Parse `$ARGUMENTS`:

- `all` → review the whole codebase.
- `diff` → review only uncommitted working-tree changes (`git diff` + untracked).
- a path → review only that file or directory.
- empty → review the current branch versus main plus uncommitted changes: `git diff main...HEAD`, `git diff`, and untracked files. If that set is empty, fall back to reviewing the whole codebase.

Resolve the concrete file list before dispatching agents and share it with every agent so they review the same surface.

## 2. Detect GSD

Check whether a `.planning/` directory exists at the repo root. Record this as `GSD_ENABLED`. Do not stop if it is absent.

## 3. Fan out review agents in parallel

Dispatch these subagents in a single batch (one `Agent` call each, same message). Give each the scope file list and ask for findings as a list of `{severity (critical|high|medium|low), file:line, title, why it matters, recommendation}`.

- `code-reviewer` — best practices, correctness bugs, architecture, performance, backend logic.
- `code-reviewer-frontend` — dispatch only if the scope contains frontend code (React/TypeScript, CSS); otherwise omit. Covers UI weirdness, accessibility, layout and state issues.
- `silent-failure-hunter` — swallowed errors, empty catches, inappropriate fallbacks, inadequate error handling.
- `general-purpose` with a security-focused brief — injection, authn/authz, secrets, unsafe deserialization, SSRF, path traversal, dependency risk. (If a `.planning/` security context exists, prefer the `gsd-security-auditor` agent instead.)

Only dispatch agents that have an applicable surface — a trivial or single-domain scope should not spawn the whole fleet. Add `ts_backend` or `terraform` agents if the scope is heavily one of those and the default reviewers miss domain specifics.

## 4. Consolidate

Merge all findings. De-duplicate overlapping reports, drop false positives you can disprove by reading the code, and sort by severity. For each surviving finding keep: severity, location, title, explanation, and a concrete fix.

## 5. File GSD todos (only if `GSD_ENABLED`)

For every actionable finding, create a todo via the `gsd-capture` skill (default mode → `.planning/todos/`). Use one todo per finding, titled with the severity and a short summary, body containing the location and recommended fix. Skip purely informational notes.

## 6. Write the report

Compute the date with `date +%y%m%d` and write `REVIEW_REPORT_<YYMMDD>.md` to the repo root (the `REVIEW_REPORT_*.md` pattern is gitignored, so this stays out of `git status`) with:

- A short header: scope reviewed, date, files/agents involved, GSD todos created (count + linkage) or a note that GSD was not detected.
- A summary table: counts per severity.
- Findings grouped by severity, each with location, explanation, and recommended fix.
- A final "Quick wins" shortlist of the highest-value, lowest-effort fixes.

Keep the report factual and skimmable. End the file with a trailing newline. Do not commit it.
