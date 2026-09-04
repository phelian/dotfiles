---
name: gh-triage
description: "Triage open GitHub issues and PRs against the repo's own issue templates, PR templates, and CONTRIBUTING.md. Scores completeness, flags missing fields, label gaps, stale items, and issue-first gate violations, and optionally labels or closes. Use when asked to triage the inbox, review open issues, check PR compliance, or clean up a GitHub repo's open items."
argument-hint: "[--issues] [--prs] [--label] [--close-incomplete] [--repo owner/repo]"
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
  - AskUserQuestion
---

# GitHub Triage

One-command triage of a repo's open issues and PRs. Every check is derived from the templates the repo actually ships, so nothing is assumed about label names or field names.

## Flags

- `--issues` review only issues
- `--prs` review only PRs
- `--label` apply recommended labels after the report
- `--close-incomplete` close items that fail template compliance, with an explaining comment, after confirmation
- `--repo owner/repo` override the auto-detected repository

Default with no flags: review both, report only.

## Process

### 1. Preflight

```bash
gh auth status
gh repo view --json nameWithOwner --jq '.nameWithOwner'
```

Stop with instructions if `gh` is missing or unauthenticated, or if no GitHub remote is found and `--repo` was not given.

### 2. Discover the rules

Read whatever exists of:

- `.github/ISSUE_TEMPLATE/*.yml` and `*.md`, plus `config.yml` for blank-issue settings
- `.github/PULL_REQUEST_TEMPLATE.md` or `.github/PULL_REQUEST_TEMPLATE/*.md`
- `CONTRIBUTING.md`
- `.github/labels.yml` or `gh label list --limit 200` for the label vocabulary

From each issue template, extract the form fields or headings and which are marked required, the labels the template auto-applies, and the template name. From each PR template, extract the checklist items and headings. From CONTRIBUTING.md, note any issue-first rule, approval labels, changelog or changeset requirement, and stale policy.

If the repo has no templates at all, fall back to a minimal baseline: an issue needs a description and, for bugs, reproduction steps and expected behavior. A PR needs a non-trivial title and a body.

### 3. Fetch

```bash
gh issue list --state open --limit 200 --json number,title,labels,body,author,createdAt,updatedAt
gh pr list --state open --limit 200 --json number,title,labels,body,author,headRefName,baseRefName,isDraft,createdAt,updatedAt,reviewDecision,statusCheckRollup
```

Skip either call when the matching flag excludes it.

### 4. Classify

Match each issue to a template by its auto-applied labels first, then by the template's distinctive headings appearing in the body. Match each PR to a PR template by its headings. Mark anything unmatched as unclassified. Note PRs that still contain unedited template placeholder text.

Extract linked issues from PR bodies with `Closes`, `Fixes`, or `Resolves` followed by an issue number.

### 5. Review

For each item, check every required field or checklist entry from its template. A field counts as present only if it has real content, not placeholder text, "N/A" without explanation, or an empty heading.

Cross-cutting PR checks regardless of template:

- Title is descriptive, not just "fix" or "update"
- One concern per PR
- CI status from `statusCheckRollup`
- Review decision
- Changelog fragment or equivalent label, only if CONTRIBUTING.md requires one

Score each item as present divided by required, then bucket: COMPLETE at 100, MOSTLY COMPLETE from 75, INCOMPLETE from 50, REJECT below 50.

### 6. Gates

Only when CONTRIBUTING.md defines an issue-first rule or approval labels. For each PR, confirm it links an issue and that the linked issue carries the approval label the rule names. Report violations first, since they block the pipeline.

### 7. Report

Print to the console in this shape, omitting empty sections:

```
GITHUB TRIAGE  {repo}  {date}

SUMMARY
Open issues: {n}    Open PRs: {n}
{counts per detected template type, plus unclassified}

GATE VIOLATIONS
#{number} {title}
  Problem: {what is missing}
  Action:  {what to do}

ISSUES NEEDING ATTENTION   (lowest score first)
#{number} [{type}] {title}
  Score: {pct}%   Missing: {fields}
  Labels: {current} -> suggested: {recommended}
  Age: {days}d

PRS NEEDING ATTENTION   (lowest score first)
#{number} [{type}] {title}
  Score: {pct}%   Missing: {items}
  CI: {state}   Review: {decision}   Linked: #{issue} ({state})
  Age: {days}d

READY TO MERGE
#{number} {title}

STALE   (no activity in 30+ days)
#{number} {title}   {days}d
```

Never write the report to a file unless asked.

### 8. Actions

Only with `--label` or `--close-incomplete`.

Labels come from the repo's own vocabulary discovered in step 2. Suggest a triage label for unclassified items and a review label for items awaiting approval, using the names the repo actually has. Never create labels.

```bash
gh issue edit {number} --add-label "{label}"
gh pr edit {number} --add-label "{label}"
```

For closing, list every candidate with its reason, then ask with AskUserQuestion whether to close all, pick individually, or skip. Close with a comment that names the missing fields and points to the template or CONTRIBUTING.md. Never close without confirmation.

```bash
gh issue close {number} --comment "{reason}"
gh pr close {number} --comment "{reason}"
```

### 9. Wrap up

Print counts for reviewed, gate violations, ready to merge, needing attention, and stale, followed by the suggested order of work: gates, incomplete submissions, merges, unclassified.
