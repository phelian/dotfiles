---
description: "Bring in The Innovator — an expert product designer who studies the project and proposes UI/UX innovations grounded in current research"
argument-hint: "[file, surface, or theme]  (default: the whole project)"
---

Dispatch the `innovator` agent with a single `Agent` call. Do not do this analysis yourself — the value is the agent's independent perspective.

## Scope

Parse `$ARGUMENTS`:

- a path → focus the review on that file or directory, but read enough of the surrounding app to place it in the product's core loop.
- a theme (e.g. "onboarding", "mobile", "the map") → focus on that experience wherever it lives in the code.
- empty → review the whole project.

## Brief

Give the agent, in its prompt:

- The repo path and the scope resolved above.
- What the product is and who uses it, as far as you can tell from the code — and tell the agent to correct you if the code says otherwise.
- The stack and its constraints: languages, frameworks, styling approach, and the current dependency count. The agent is instructed to respect the grain of the project, so it needs to know what that grain is.
- The main UI surfaces and their relative size, so it knows where the complexity sits.
- An instruction to follow its full process — reconstruct the product, inventory the experience, research current practice with WebSearch/WebFetch before making substantive claims, generate at all three altitudes, then rank and report in its standard output format.
- An instruction to return the report as its final message.

## After it returns

Relay the report in full — it is the deliverable, and the user cannot see the agent's output otherwise. Do not summarise it away.

Then add your own short reaction: where you agree, where you think the agent is wrong about this codebase, and which proposal you would start with. You know the project's history; it does not.

The agent is read-only. If the user wants a proposal implemented, that is a separate step they ask for.
