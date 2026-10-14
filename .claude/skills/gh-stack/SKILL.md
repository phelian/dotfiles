---
name: gh-stack
description: "Create, adopt, submit, and verify native GitHub stacked pull requests with the gh stack extension. Use when asked to stack PRs in GitHub, turn existing PRs into a stack, or manage an existing gh stack."
---

# Native GitHub PR stacks

Use `gh stack` for GitHub's native stack relationship. A chain of PR base branches alone is **not** a native GitHub stack.

## Preflight

1. Inspect `git status --short`, `git remote -v`, `gh auth status`, `gh stack --version`, and `gh stack --help`. Stop if the extension is missing or authentication fails. Check subcommand help before using version-dependent flags.
2. Identify the intended `owner/repo`, push remote, trunk branch, PR numbers, and bottom-to-top branch order. Inspect each PR's head repository, head branch, base branch, draft state, and open/closed state with `gh pr view`. Do not infer order solely from PR numbers.
3. Check that each local branch exists, its history forms the intended stack, and its tip matches the corresponding remote branch (`git ls-remote`). If local and remote differ, report the difference before a command that could push or rewrite either.
4. For forks or multiple remotes, set `GH_REPO=owner/repo` on **each** `gh stack` operation that targets GitHub. `--remote` selects where branches are pushed; it does not reliably select the repository where the extension discovers or creates PRs. Verify the chosen repo before mutation.

## Adopt and submit existing work

Prefer an installed `gh stack link` command if it can link the existing PRs without changing their branches. If unavailable, use local branch adoption:

```bash
gh stack init --adopt --base <trunk> <bottom-branch> <next-branch> ... <top-branch>
GH_REPO=<owner/repo> gh stack submit --auto --remote <push-remote>
```

Consult `gh stack init --help` and `gh stack submit --help`: syntax and `link` availability vary by extension version. `submit` may push branches and create or update PRs. Confirm expected changes with the user if submission would alter an existing branch, PR base, draft state, title, or body beyond the requested stacking. Preserve draft PRs; do not use `--open` or otherwise publish them without authorization. Reuse existing PRs rather than create duplicates.

Do not run `gh stack sync`, `rebase`, `merge`, or `unstack` merely to establish the stack: these can rewrite branches, merge, or delete work. Do not force-push unless explicitly needed and authorized.

## Verify and report

Run `GH_REPO=<owner/repo> gh stack view --json` (or the available view format) and check that every intended PR appears in **one native stack**, in bottom-to-top order, with a stack ID/link when provided. Independently verify each PR's base branch and draft state with `gh pr view`. Report the stack link and PR order, plus any branches or PR metadata changed. If view shows only a base-branch chain or missing PRs, do not claim that the native stack is complete.
