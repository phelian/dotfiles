---
argument-hint: <peer-session-name><newline>[task/context]
description: Coordinate directly with another running Claude Code session over Ghostty, instead of relaying messages through the user
---

The first line of "$ARGUMENTS" is the peer session's name (as shown by `claude agents`). Any following lines are the task/context to open with.

Reach the peer with:

    notify-peer <peer-name> "<message>"

Messages arrive at the peer prefixed with `[from <sender-session-name>]`, resolved automatically — no need to introduce yourself or resolve your own name. When you receive such a message, reply to the name in the prefix. Keep messages single-line; newlines are flattened to spaces.

Open with what you want to coordinate on. Keep exchanging messages with the peer via `notify-peer` until the task is resolved — don't relay through the user unless you're stuck or need a decision only they can make.

`notify-peer` finds the peer's Ghostty surface by title, which only matches when the peer was started with `claude --name <peer-name>`. It falls back to matching the peer's working directory, which is ambiguous when several surfaces share a directory. If it reports that, tell the user to restart the peer with an explicit `--name`.
