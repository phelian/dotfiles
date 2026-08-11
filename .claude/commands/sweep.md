---
description: "Fan out every applicable specialist agent over the whole codebase and file the findings as GitHub issues"
argument-hint: "[--dry-run] [--no-file] [scope hint, e.g. 'backend + infra only']"
---

Run a full multi-dimensional audit by fanning out specialist agents in parallel, then file every
surviving finding as a GitHub issue.

This is the heavyweight sweep — a dozen agents, whole-codebase scope, issues filed at the end.
For a quick pass over a diff, use `/complete-review` instead.

Parse `$ARGUMENTS`: `--dry-run` or `--no-file` means do everything except create issues (print
the table instead). Anything else is a scope hint — honour it when narrowing the fleet.

## 1. Recon before dispatching anything

Do this yourself, in parallel where possible. It is short and it decides everything after it.

- Repo layout: what languages and surfaces exist (`find`, skip `node_modules`/`.git`). The
  surfaces you find are the fleet you dispatch — do not spawn a frontend agent at a repo with
  no frontend.
- `git remote -v`, `gh auth status`, `git status --short`, recent commits.
- Project instructions: `CLAUDE.md`, `.github/copilot-instructions.md`, `CONTRIBUTING.md`.
- **Every issue ever filed**, open and closed:
  `gh issue list --limit 300 --state all --json number,title,state,labels --jq '.[] | "#\(.number) [\(.state)] \(.title) — labels: \([.labels[].name]|join(","))"' > "$SCRATCH/existing-issues.txt"`
- Any prior review artefacts in the repo (`REVIEW.md`, `*-REVIEW.md`, `.planning/`, audit docs).
- `gh label list --limit 100`.

The closed issues matter as much as the open ones. On a repo that has been audited before, most
obvious findings are already fixed, and an agent that re-reports them wastes the whole run.

Use the session scratchpad directory for all working files. Call it `$SCRATCH` below.

## 2. Write one shared brief

Write `$SCRATCH/BRIEF.md` once and point every agent at it. It must contain: the repo layout
and what each directory is; the absolute path to `existing-issues.txt` and the prior review
docs; the instruction to grep that file before reporting anything, and to verify in current
code whether a CLOSED issue's fix actually landed (a real regression is worth reporting — say
so and cite the number); what counts as a finding; the severity scale; and the output contract.

Severity: `high` = data loss, auth bypass, or broken for every user. `medium` = breaks in a
realistic case, or a real security weakness. `low` = edge case, polish, maintainability with
teeth.

Every finding must cite `path:line` and describe a concrete failure — inputs or state leading
to a wrong outcome. No style preferences, no speculative refactors, no "consider adding a
comment".

Require this exact JSON array per agent, written to its own file:

```json
[{ "title": "", "severity": "high|medium|low", "area": "backend|frontend|ios|infra|design|ux|a11y|tests|security",
   "locations": ["path:line"], "body": "markdown: what is wrong, how it fails, why it matters, what to do. Quote the code.", "duplicate_of": null }]
```

Tell agents to match the repo's existing issue titles in voice — read `existing-issues.txt` for
tone. Declarative sentences, no `[BUG]` prefixes. And: **return only a one-paragraph summary
plus a count**, never the findings themselves. The JSON file is the channel; this is what keeps
a twelve-agent sweep inside one context.

Close with: quality over quantity, ten real findings beat forty padded ones, `[]` is a fine
answer.

## 3. Dispatch the fleet — one message, all agents

Pick from these by what the repo actually contains. Give each a scoped brief naming the
specific files and the specific failure modes to hunt; a vague brief returns vague findings.

| Agent | Beat |
|---|---|
| `general-purpose` (security brief) | authz/IDOR **route by route**, authn, tokens, injection, uploads, secrets, rate limits |
| `ts_backend` / language equivalent | transactions, races, schema, N+1, money, dates, external calls |
| `code-reviewer-frontend` | stale state, fetch ordering, optimistic rollback, form correctness |
| `gsd-ui-auditor` | visual design, tokens, computed contrast, states, responsive |
| `frontend` (a11y brief) | keyboard, screen reader, focus, semantics, live regions |
| `innovator` | product flows, first run, dead ends, mobile/offline reality |
| `silent-failure-hunter` | swallowed errors, masking defaults, unawaited promises |
| `pr-review-toolkit:pr-test-analyzer` | coverage by risk, tests that assert too little, what CI never runs |
| `terraform` | IaC, CI, containers, deploy/rollback, backups, observability |
| `general-purpose` (mobile) | iOS/Android client, if one exists |
| `pr-review-toolkit:type-design-analyzer` | drift between independent models of one API |
| `code-reviewer` | the cross-cutting beat: uncommitted changeset as a whole, stale docs, dead code, repo hygiene |

Give the generalist an explicit list of what the specialists already cover, so it goes hunting
where they will not look. Tell every agent to verify by reading code, not by assuming, and not
to run destructive commands (`tofu apply`, migrations, deploys).

## 4. Consolidate

Merge the JSON files. Then:

- **Dedupe across agents.** The same defect found by two or three agents is the strongest signal
  in the run — keep the best-argued version and note the corroboration. Do not file both.
- **Drop what you can disprove** by reading the code.
- **Spot-verify the highs yourself.** Do not file a high on an agent's say-so; check the claim
  against the file. Report how many you verified.
- Assign labels: area + severity + `bug`/`enhancement`/`documentation`. Create any label that
  does not exist (`gh label create`).

## 5. File

Write each body to a file and use `--body-file` — bodies are long and shell-quoting will bite.
Add a provenance footer with the locations and which pass found it. Then file with retry and a
pause between creates; GitHub throttles bulk creation at roughly 80/minute.

```bash
url=$(gh issue create --title "$title" --label "$labels" --body-file "$SCRATCH/body.md")
```

Run the loop in the background and report the OK/FAIL tally when it finishes. On `--dry-run`,
print the title/label table instead.

## 6. Report

Lead with the highs, with issue numbers and one line each on why they matter. Then the counts
by severity and area.

Then say **what the sweep did not find** — the authz that was clean, the injection that was not
there, the conventions that held. On a well-maintained repo this is the more useful half of the
result, and it is the part that tells the reader how much to trust the rest.

Finally, state your own confidence honestly: how many findings you verified yourself versus
took on an agent's word, and which categories to treat as leads rather than facts.
