# skill-ninja-logger

Captures friction observations from coding sessions into a structured gap log. The first half of the autonomous skill-creation pipeline.

## How it works

1. During any session, you (or Claude) notice a recurring manual task.
2. Trigger the logger: "log a skill gap" — or it self-triggers on specific patterns.
3. The logger writes a structured entry to `~/.agents/skill-gaps.md`.
4. Once a week, `skill-ninja-review` reads the log and graduates recurring patterns into actual skills.

## Trigger phrases

- "log a skill gap"
- "this should be a skill"
- "I keep doing this manually"
- "log this gap"

## Passive triggers (Claude self-invokes)

- Claude reads ≥3 source files to find one symbol
- User repeats the same data transformation ≥2 times
- User walks through the same multi-step workflow across sessions
- Claude finds no skill/MCP fits a task

For passive triggers, Claude asks once before logging — silent logging would be invasive.

## Log location

`~/.agents/skill-gaps.md` — single global log, entries tagged by project. Searchable, append-only.

## Why a global log instead of per-project

Most useful patterns transcend projects ("format Mercury CSVs" is an Adommo task but the *skill* would be reusable). A single review surface beats hunting across many `.skill-gaps.md` files. Project tagging preserves the per-project signal where it matters.

## Privacy

Entries with `Sensitivity flag: contains-pii-or-secret` never auto-graduate. They surface in manual review only. The logger flags this conservatively — when in doubt, mark sensitive.

## Don't expect this skill alone to do anything

This skill only captures. Without `skill-ninja-review` running weekly, the log is just a record. The two skills are designed to work together.
