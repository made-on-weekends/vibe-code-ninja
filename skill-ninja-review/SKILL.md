---
name: skill-ninja-review
description: Weekly review of the skill-gap log at ~/.agents/skill-gaps.md. Identifies recurring patterns, autonomously creates new skills with guardrails (7-day quarantine, three-signal routing, manual review for ambiguous candidates), and maintains the review queue at ~/.agents/skill-review-queue.md. Use when the user says "weekly skill review", "review skill gaps", "check the gap log", "graduate skills", or any phrase indicating they want to process accumulated gap entries. Also surface a recommendation to run this skill if the gap log has grown by ≥5 entries since the last review.
---

# skill-ninja-review

Weekly review skill. Reads `~/.agents/skill-gaps.md`, identifies graduation-eligible patterns, and autonomously creates new skills with guardrails.

## Trigger phrases

- "weekly skill review"
- "review skill gaps"
- "check the gap log"
- "graduate skills"
- "process gap log"

## The review workflow

### Step 1 — Read the gap log and review queue

Read `~/.agents/skill-gaps.md` and `~/.agents/skill-review-queue.md` (create the queue file if it doesn't exist with the header from the "Review queue file format" section below).

Note the date of the last review (look for `## Last reviewed: YYYY-MM-DD` header in the queue file). Process entries added since then.

### Step 2 — Group recurring patterns

Group log entries by pattern similarity. Two entries are the same pattern if:
- Their `Pattern` field describes the same task type (formatting, scaffolding, querying, etc.)
- The artifact involved is the same kind (CSV exports, ADR entries, test files)
- Substituting project-specific nouns wouldn't change the underlying pattern

Use the `Reoccurred YYYY-MM-DD` notes appended by the logger as additional recurrence signals.

### Step 3 — Apply graduation thresholds

A pattern is graduation-eligible if **all** of these are true:

1. **Recurrence:** ≥3 distinct occurrences in the log (not three in one session — three across sessions). The dates of the occurrences span ≥7 days.
2. **Specificity:** the pattern can be described in one sentence that names a concrete artifact and action. "Formats Mercury CSV exports into chart-of-accounts schema" passes; "debugging stuff" doesn't.
3. **Non-overlap:** the proposed skill description doesn't substantially overlap with any existing skill in `~/.agents/skills/`. Read the index of existing skills before creating.
4. **Sensitivity:** no entries in the group have `Sensitivity flag: contains-pii-or-secret`. If any do, route to review queue regardless of other signals.

If all four pass → autonomous creation (Step 5).
If 1–3 pass but sensitivity flag is set → flag for manual review (Step 4).
If recurrence or specificity fails → leave in log for next review.
If non-overlap fails → propose update to existing skill instead (Step 4 with `update` route).

### Step 4 — Three-signal routing (global vs project-specific)

For graduation-eligible patterns, decide whether the new skill is global, project-specific, or needs manual review.

Compute three signals:

**Signal 1 — Project-noun density.** What fraction of the pattern's specification is project-specific identifiers (table names, component names, file paths under one repo, brand names, internal terminology)?
- High (>30%) → project signal
- Low (<10%) → global signal
- Mid (10–30%) → mixed

**Signal 2 — Cross-project recurrence.** Did the pattern appear in conversations spanning more than one project (check the `Project` field of each occurrence)?
- Multi-project → strong global
- Single-project → weakens global; doesn't eliminate it

**Signal 3 — Vocabulary portability.** Could the pattern's description be rewritten using only generic vocabulary without losing meaning?
- Yes → global signal
- No → project signal

### Routing decision

| Project-nouns | Multi-project? | Portable vocab? | Decision |
|---------------|----------------|-----------------|----------|
| Low           | Yes            | Yes             | Auto-create global, in quarantine |
| Low           | No             | Yes             | Auto-create global, in quarantine |
| High          | No             | No              | Auto-create project-specific, in quarantine |
| Mixed signals | —              | —               | Flag for manual review              |

### Step 5 — Autonomous creation (in quarantine)

For auto-create cases, scaffold the new skill in a quarantine directory:

**Global skill:** `~/.agents/skills/_quarantine/<skill-name>/SKILL.md`
**Project-specific skill:** `<project-root>/.agents/skills/_quarantine/<skill-name>/SKILL.md`

(`<project-root>` is determined by the project tag of the gap entries that triggered creation. Use the project's actual directory.)

The new SKILL.md must include:
- A `# Auto-generated` header at the top, before the frontmatter
- Comments linking back to the originating gap log entries (line numbers in `~/.agents/skill-gaps.md`)
- An expiry note: "Quarantined until YYYY-MM-DD. After that date, will auto-promote to active."
- A clear `description:` field with explicit trigger phrases (per the open standard format)

Example header:

```markdown
# Auto-generated by skill-ninja-review on 2026-05-02
# Triggered by gap log entries at lines 23, 47, 89
# Quarantined until 2026-05-09. Auto-promotes after that date unless moved or deleted.

---
name: <skill-name>
description: <generated from pattern description, plus explicit triggers>
---

...
```

### Step 6 — Promotion (handled at the start of the next review)

At the start of each review session, before processing new entries, check the quarantine directories:
- For each skill in quarantine where the expiry date has passed: move it to its target location (`~/.agents/skills/<name>/` for global, `<project-root>/.agents/skills/<name>/` for project-specific).
- The skill remains auto-discoverable in quarantine — promotion just removes the `_quarantine/` segment from the path.

### Step 7 — Review queue handling

For "Flag for manual review" cases, append entries to `~/.agents/skill-review-queue.md`. Each entry has the structure shown in "Review queue file format" below.

Also surface to the user during the review session: present the queued items as a list with three options each (`Make global`, `Make project-specific in <project>`, `Discard`). Update the queue based on user response.

Auto-discard rule: any queued item still pending after **two reviews** (typically 14 days at weekly cadence) gets auto-discarded. Discarded items are logged so they can resurface if recurrence picks up later. Don't silently delete — append a `Discarded: YYYY-MM-DD — reason: <reason>` note before removing from queue.

### Step 8 — Update the log

After processing, update `~/.agents/skill-gaps.md`:
- For graduated patterns: append a `Graduated: YYYY-MM-DD — created skill <name> in <quarantine path>` note to each contributing entry.
- For queued patterns: append `Queued for review: YYYY-MM-DD`.
- Don't delete entries. The log is the audit trail.

Update the queue file with `## Last reviewed: YYYY-MM-DD` at the top.

### Step 9 — Output the review summary

Show the user:

```
Skill gap review — YYYY-MM-DD

Processed N new entries since last review.

Auto-graduated (in 7-day quarantine):
- <skill-name> (global) — created at ~/.agents/skills/_quarantine/<name>/
  Triggered by N entries across N projects, M days span
- <skill-name> (project: <project>) — created at <project>/.agents/skills/_quarantine/<name>/

Promoted from quarantine (7+ days old, no objections):
- <skill-name> (global) — moved to ~/.agents/skills/<name>/

Flagged for manual review:
- <one-line pattern description> — see ~/.agents/skill-review-queue.md
  Reason: mixed signals (project-noun density 35%, single-project, partially portable vocab)

Queue items pending action:
- <one-line> — flagged 2 reviews ago, auto-discards next review unless decided

Still in log, not yet eligible:
- N patterns (insufficient recurrence)

Next review: <one week from today>
```

## Review queue file format

If `~/.agents/skill-review-queue.md` doesn't exist, create it with:

```markdown
# Skill Review Queue

Patterns that need manual decision before becoming skills. Reviewed weekly by skill-ninja-review.

Auto-discard rule: items still pending after two reviews (typically 14 days) are auto-discarded. Manual decision before then preserves them.

## Last reviewed: <date>

---
```

Each queued entry:

```markdown
## YYYY-MM-DD — <one-line pattern description>

**Source entries:** lines NN, NN, NN in ~/.agents/skill-gaps.md
**Signals:**
- Project-noun density: <fraction>
- Multi-project: <yes/no>
- Portable vocab: <yes/no>
**Reason flagged:** <why this needed manual review — sensitivity, mixed signals, overlap with existing skill, etc.>
**Decision options:**
- [ ] Make global (auto-quarantine)
- [ ] Make project-specific in <project> (auto-quarantine)
- [ ] Update existing skill: <name>
- [ ] Discard
**Reviews pending:** <number — auto-increments each review without decision; auto-discards at 2>
```

## Token-waste prevention

This skill runs once a week and processes a finite log. Rules:

1. Don't re-read entries already processed in prior reviews. Track via the `Last reviewed:` header.
2. Don't read the entire `~/.agents/skills/` directory tree every review — sample existing skill descriptions for the non-overlap check.
3. Don't be verbose in the output. The review summary is structured, not narrative.
4. Don't generate skill content speculatively. The auto-created skills should be minimal — just enough to capture the pattern. Refinement happens in usage.

## What this skill does NOT do

- Does not modify the existing project-ninja, skill-ninja-logger, or itself.
- Does not edit history in the gap log (only appends notes).
- Does not delete from the queue without user confirmation or auto-discard rule.
- Does not skip the sensitivity check. Ever.
- Does not promote skills out of quarantine before the 7-day window.

## Failure handling

If a skill in quarantine fails to work correctly (you notice it triggering wrongly, or its description doesn't match its intent), you have two options:
1. Edit the SKILL.md directly to fix it. The next review will see your edits and respect them.
2. Delete the skill folder. The auto-generated header will not be regenerated unless the pattern reoccurs.

If the same pattern keeps generating bad skills (>1 deletion of an auto-created skill for the same gap pattern), append a note to the contributing log entries: `Manual-only — auto-graduation produced incorrect skills`. Future reviews will route the pattern to manual review only.
