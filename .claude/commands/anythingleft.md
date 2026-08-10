---
description: "Audit the session for loose ends before clearing context — unfinished work, uncommitted code, stray branches and processes — and emit a handoff to paste into the next session"
argument-hint: "(no arguments)"
---

The user is about to clear context or end the session. Find everything that would be lost or forgotten, and hand it back as text they can paste into a fresh session.

Be accurate over reassuring. A missed loose end is the whole failure mode of this command; "all clear" when something is outstanding is worse than a noisy report.

## 1. Look at the repository

Run these and read the results — do not assume a clean tree because you believe you committed everything:

- `git status --short` — uncommitted and untracked files. Separate **yours** from another session's or the user's own edits, and say which is which. If you cannot tell, say so rather than guessing.
- `git log --oneline origin/$(git branch --show-current)..HEAD` — commits made but not pushed.
- `git stash list` — anything parked, including stashes you created to work around a dirty tree.
- `git worktree list` — worktrees, especially temporary ones created for verification.
- `git branch --format='%(refname:short) %(upstream:track)'` — local branches, merged or stale ones, branches with no upstream.
- `gh pr list --state open` and `gh pr checks` on anything you opened — open PRs, red CI.
- `gh run list --branch <current> --limit 3` — a run still in progress or failed after the last push.

## 2. Look at the conversation

Re-read this session for things that were said but never landed. Specifically hunt for:

- Work you described as a follow-up, deferred, "next pass", or "worth doing separately".
- Issues you filed but did not fix, and issues you closed **partially** — say which half is missing.
- Anything you shipped but could **not verify** (no runtime check, blocked port, missing credentials, skipped test). Name the specific thing that is unverified.
- Decisions the user asked about that you never answered, or questions you asked that they never answered.
- Scope you narrowed on your own judgement — the user may not have registered it.
- Bugs or oddities you noticed in passing and did not file (someone else's broken code, a failing check you diagnosed as pre-existing).

## 3. Look at what you left running or lying about

- Background processes you started (dev servers, watchers). Report the PID or process group and whether they are still up.
- Temporary edits: search the working tree for markers you introduced (`TEMP`, `XXX`, commented-out code, forced states, hardcoded overrides). Any that survive are a bug waiting to ship.
- Scratch files written outside the repo that hold something worth keeping.
- Local database or environment changes: migrations applied, seeded rows, env vars set, config toggled.

## 4. Report

Lead with the verdict in one line: everything is clean, or there are N things outstanding.

Then, only for categories that actually have something, a short section each. Skip empty categories entirely rather than printing "none".

Then a fenced block the user can copy whole into the next session. Write it addressed to a fresh assistant with no memory of this conversation, and make it self-contained:

```
Repo: <absolute path>   Branch: <name>   HEAD: <sha> <subject>

In flight:
- <what is half-done, and where it stands>

Next steps:
- <the specific next action, precise enough to act on without re-deriving it>

Watch out for:
- <traps: a shared working tree, another session's uncommitted files, a broken dev stack, an unverified change>
```

Keep the block tight. Someone should be able to act on it without reading anything else. Do not pad it with what was finished and pushed — that is history, not a loose end.

If the session genuinely has nothing outstanding, say that plainly in one line and emit no block.
