---
description: "Write a self-contained handover note so a fresh session with no context can continue the work — state, what was built and where, decisions, environment, gotchas, open items"
argument-hint: "[optional focus, e.g. a feature name]"
---

Write a handover note for a context-free session: a new assistant, in this same repository, that has not seen this conversation and cannot ask you anything. Output the note as plain text in the reply only. Do not write it to a file unless the user asks.

The note is judged by one question: can the next session pick up exactly where this one stopped without re-deriving anything? Every fact the reader would otherwise have to rediscover by reading code, running commands or asking the user belongs in the note. Everything derivable from the code in a minute does not.

$ARGUMENTS

## Before writing

Check the ground truth rather than trusting your memory of it:

- `git status --short` and `git log --oneline -5` — what is committed, what is not, and whose the uncommitted changes are. Separate your changes from the user's or another session's.
- `git log --oneline origin/$(git branch --show-current)..HEAD` — unpushed commits.
- Anything you left running (dev servers, tunnels, watchers, background jobs) and anything you changed outside the repo (local databases, env files, config, symlinks, credentials, scheduled jobs).
- If the work was deployed, what is actually live, and how you verified it.

Re-read the conversation for decisions the user made, questions they answered, requests they declined, and things they asked about that were left open.

## Structure

Use these sections, in this order, and skip any that are empty. Headings are `##`. Keep it scannable: short paragraphs, bullets for parallel items, file paths where the reader has to go there. No code blocks unless a command or URL has to be copied exactly.

**Where things stand.** One paragraph: what is done, committed, pushed, deployed, and the exact commit shas or version that mark the boundary. Name uncommitted files and whose they are.

**What was built.** Per component: what it does and the file that owns it. Include the non-obvious design choices with their reason, not the code shape. Mention tests and where they live.

**External systems and access.** Accounts, ids, scopes, tokens, endpoints, environments the work depends on. Include how to re-authenticate or re-consent and what a failure looks like. Never paste secrets; name the variable or file that holds them.

**Decisions the user made.** Each one on its own line, phrased as the decision, not the discussion. Include things the user declined and alternatives that were ruled out, so the next session does not re-propose them.

**Assumptions and heuristics.** Any rule, threshold, pattern list or estimate baked into the work that the user might want to tune, and where it lives.

**Local setup.** How to run and test this locally: commands, ports, database, env overrides, test data. Include the workarounds you needed and why.

**Deploy and operations.** How it ships, what needs to be on PATH or in env, what broke during deploys and how it was fixed, anything left running.

**Not done and open.** The most important section. For each item: what it is, why it was not done (deferred, blocked, declined, out of time, never asked), and what the next concrete step is. Include work you shipped but could not verify, naming the specific unverified thing. Include the last thing the user asked about that has no answer yet.

## Rules

- Be specific over general: a sha, a path, a number, an error message verbatim. "The sync sometimes fails" is useless; "run 2 stuck in `running` after the edge dropped the request; marked failed by hand" is a handover.
- Report faithfully. If a step was skipped, say skipped. If something was not tested, say not tested and why. Do not round unverified work up to done.
- Convert relative time to absolute dates.
- Write for a reader who knows the domain and the codebase's conventions but not this session. Expand abbreviations you coined during the session, or drop them.
- Do not include the conversation's history, false starts you fully reverted, or praise for the work. Include false starts only when the next session might repeat them.
- Length follows content. A one-hour fix is a screen; a multi-day feature may be several. Cut by leaving things out, never by compressing sentences into fragments.
