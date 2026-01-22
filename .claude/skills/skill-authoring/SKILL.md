---
name: skill-authoring
description: "Create new Claude Code skills. Use when asked to add a skill, create a capability, or when a reusable workflow should be packaged as a skill."
---

# Skill Authoring

## When to create a skill

- User explicitly asks to create a skill
- A workflow is repeated across multiple conversations
- Domain-specific expertise should be packaged for reuse
- Claude needs to be specialized for a particular task type

## When NOT to create a skill

- One-off tasks that won't be repeated
- Simple instructions that fit in CLAUDE.md
- Tasks better suited as commands (user-invoked) or agents (Task tool)

## Skill vs Agent vs Command

| Type | Location | Trigger | Use case |
|------|----------|---------|----------|
| Skill | `.claude/skills/*/SKILL.md` | Auto-loaded when relevant | Domain expertise, workflows |
| Agent | `.claude/agents/*.md` | Explicit via Task tool | Specialized subprocesses |
| Command | `.claude/commands/*.md` | User invokes with `/name` | User-triggered actions |

## Skill structure

Create a directory in `.claude/skills/` with a `SKILL.md` file:

```
.claude/skills/my-skill/
├── SKILL.md          # Required: instructions with YAML frontmatter
├── templates/        # Optional: template files
└── scripts/          # Optional: executable scripts
```

## Required SKILL.md format

```yaml
---
name: my-skill-name
description: "Brief description of what this skill does and when to use it. Include trigger keywords."
---

# Skill Title

## When to use

[List specific situations that should trigger this skill]

## Instructions

[Step-by-step guidance for Claude to follow]

## Examples

[Optional: concrete examples of using this skill]
```

## Field requirements

- `name`: lowercase letters, numbers, hyphens only (max 64 chars)
- `description`: must include what it does AND when to use it (max 1024 chars)

## Best practices

- Write clear trigger conditions in the description
- Keep instructions concise - Claude reads them on-demand
- Use progressive disclosure: main instructions in SKILL.md, details in separate files
- Bundle scripts for deterministic operations (they run without loading into context)
- Test the skill triggers correctly by describing a relevant scenario
