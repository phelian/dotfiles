---
argument-hint: [feature or investigation description]
allowed-tools: Bash(git add:*), Bash(git commit:*)
---

Create a markdown file in the `todo/` directory using kebab-case formatting based on the provided description.

$ARGUMENTS

Structure the document with a preliminary implementation plan. If `just static-fix` is available, run it to ensure correct formatting.

Commit the new document immediately, using "plan" as the leading verb in the commit message.

Adhere to existing git preferences strictly.
