---
argument-hint: [create]
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(gh pr create:*), AskUserQuestion
---

Analyze the current branch changes compared to main and generate a minimal PR description.

Run `git diff main...HEAD` and `git log main..HEAD --oneline` to understand the changes.

Write a short, direct description:
- Use "Adds", "Fixes", "Updates", "Removes" style language
- One line per distinct change
- No fluff, no "this PR", no verbose explanations

If $ARGUMENTS contains "create":
1. Show the description and ask if it looks good or needs changes using AskUserQuestion
2. After approval, create the PR with `gh pr create`

Otherwise, just output the description text ready to copy.
