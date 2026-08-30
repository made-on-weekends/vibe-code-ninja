# skill-ninja-review

Weekly review skill that turns gap-log entries into actual skills, autonomously, with guardrails.

## How it works

1. Every week, you invoke this skill: "weekly skill review"
2. It reads `~/.agents/skill-gaps.md` and groups recurring patterns
3. Patterns that pass four thresholds (recurrence, specificity, non-overlap, sensitivity) get auto-graduated into new skills
4. New skills land in a 7-day quarantine before promotion to active
5. Ambiguous patterns go to a review queue you decide on manually

## Why "autonomous with guardrails"

Pure manual review creates friction that decays the system. Pure autonomous creation produces a graveyard of bad skills that mislead agents. Quarantine + thresholds is the middle path:

- **You don't have to approve** every graduation — the threshold does that
- **Bad auto-skills can't damage** anything for 7 days — quarantine isolates them
- **Ambiguous cases** get human decision rather than guesses

## Trigger phrases

- "weekly skill review"
- "review skill gaps"
- "graduate skills"
- "process gap log"

## Files it reads/writes

| File                                 | Read | Write | Purpose                          |
|--------------------------------------|------|-------|----------------------------------|
| `~/.agents/skill-gaps.md`            | yes  | append-only notes | gap log from logger |
| `~/.agents/skill-review-queue.md`    | yes  | yes   | manual-decision queue            |
| `~/.agents/skills/_quarantine/`      | yes  | yes   | new global skills (7-day quarantine) |
| `~/.agents/skills/<name>/`           | yes  | yes   | promotes quarantined skills here |
| `<project>/.agents/skills/_quarantine/` | yes | yes  | new project-specific skills      |
| `<project>/.agents/skills/<name>/`   | yes  | yes   | promotes project-specific skills |

## Graduation thresholds

A pattern auto-graduates only if **all** are true:
1. ≥3 occurrences across ≥7 days (recurrence)
2. Pattern describable in one sentence with a concrete artifact and action (specificity)
3. No substantial overlap with existing skills (non-overlap)
4. No PII or secrets in any contributing log entry (sensitivity)

## Three-signal routing

Routing decision (global / project-specific / manual review) uses three signals:
- Project-noun density
- Cross-project recurrence
- Vocabulary portability

See SKILL.md for the routing table.

## Quarantine

Auto-graduated skills land in `_quarantine/` for 7 days. They're invokable (otherwise you can't test them) but path-isolated. After 7 days, the next review session promotes them to the main skills directory.

If a quarantined skill misbehaves, edit it or delete it. Deletion of the same pattern repeatedly converts it to manual-review-only.

## Cadence

Run weekly. Set a calendar reminder. The `Last reviewed:` header in `~/.agents/skill-review-queue.md` tracks when this last ran.

## What this skill does NOT do

- Does not run automatically on a timer (skills don't have schedulers — this is what your calendar reminder is for)
- Does not skip the sensitivity check
- Does not promote out of quarantine early
- Does not delete from the queue without confirmation or auto-discard rule
