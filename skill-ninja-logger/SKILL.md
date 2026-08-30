---
name: skill-ninja-logger
description: Capture friction observations from coding sessions into a structured gap log at ~/.agents/skill-gaps.md. Use when the user says "log a skill gap", "this should be a skill", "I keep doing this manually", "log this gap", "add to gap log", "this is repetitive", or any phrase that signals they noticed a recurring manual task that could be automated by a skill. Also passively detects specific patterns during sessions: when Claude reads ≥3 source files to locate one symbol, when the user manually formats the same data shape multiple times, when the user repeats a multi-step manual workflow. Writes one structured entry per invocation. Do not duplicate entries — check the log for similar gaps before adding new ones.
---

# skill-ninja-logger

Captures friction observations into a structured log at `~/.agents/skill-gaps.md`. Each entry is a short, structured record of a moment where the user (or Claude itself) noticed a manual workflow that could become a skill.

This skill is half of a pair. `skill-ninja-review` reads the log weekly and graduates recurring patterns into actual skills.

## When to invoke

### Explicit triggers (user-initiated)
- "log a skill gap"
- "this should be a skill"
- "I keep doing this manually"
- "log this gap"
- "add to gap log"
- "this is repetitive"

### Passive triggers (Claude-initiated)
Claude self-invokes the logger when any of these patterns occur in a session:

1. **Multi-file symbol lookup:** Claude reads ≥3 source files to locate one symbol whose location wasn't in the user's prompt. (This is the specific pattern that determines whether `code-graph-ninja` should be built.)
2. **Repeated data-shape transformation:** the user has Claude format the same data shape (CSV columns, API response, config file) ≥2 times in one session.
3. **Multi-step manual workflow:** the user walks through the same N-step process across ≥2 sessions in the past 7 days (use `recent_chats` to detect).
4. **Tool gap:** Claude attempts a task and finds no relevant skill or MCP available, and the task is something that could plausibly be skill-ified.

For passive triggers, Claude should ask once: *"This looks like a recurring pattern — should I log it as a skill gap?"* Don't log silently; the user's confirmation is part of the signal.

## What gets logged

Each entry has a fixed structure. Append to `~/.agents/skill-gaps.md` (create the file if it doesn't exist).

```markdown
## YYYY-MM-DD HH:MM — <one-line description>

**Project:** <project name from cwd or "global">
**Trigger:** <explicit | passive-symbol-lookup | passive-data-shape | passive-workflow | passive-tool-gap>
**Pattern:**
<2–4 sentences describing what the user was trying to do, what was missing, and what they did instead>

**Frequency signal:** <first-time | seen-before-in-this-session | seen-in-prior-sessions>
**Sensitivity flag:** <none | contains-project-noun | contains-pii-or-secret>
**Cross-project applicability:** <single-project | likely-multi-project | unknown>
```

## How to determine each field

### Project
Use the current working directory's basename. Example: working from `~/projects/troopersdesk` → project is `troopersdesk`. If the session is not inside a project directory, use `global`.

### Trigger
- `explicit` — user said one of the trigger phrases
- `passive-symbol-lookup` — Claude detected the multi-file lookup pattern
- `passive-data-shape` — user repeated a transformation
- `passive-workflow` — user walked through same multi-step process
- `passive-tool-gap` — no available skill/MCP fit the task

### Pattern
2–4 sentences. Concrete and specific. Bad example: "User wants help with data." Good example: "User pasted a Mercury bank CSV export and asked to format it into the chart-of-accounts schema. Claude wrote a one-off transformation. The user mentioned this is the third Mercury export this month."

### Frequency signal
- `first-time` — no similar entry exists in the log
- `seen-before-in-this-session` — same pattern happened earlier in this conversation
- `seen-in-prior-sessions` — search the log first; if a similar entry exists, mark this. (This is the signal that matters most for graduation thresholds.)

### Sensitivity flag
Critical for filtering during review:
- `none` — generic pattern, no project-specific or sensitive content
- `contains-project-noun` — refers to specific project artifacts (table names, component names, internal terminology). May still graduate as project-specific skill.
- `contains-pii-or-secret` — pattern involves real user data, credentials, financial details, or other sensitive content. **NEVER auto-graduate to a skill.** Manual review only.

### Cross-project applicability
- `single-project` — the pattern is specific to one codebase
- `likely-multi-project` — the pattern would plausibly apply to other projects
- `unknown` — not sure yet; review will decide

## Workflow

### Step 1 — Check for duplicates

Before adding a new entry, read the existing log (or use `grep` for keyword overlap). If a substantively similar entry exists from the last 30 days:
- If the new occurrence is from a different project than the existing one → add a new entry; cross-project recurrence is a strong signal
- If the new occurrence is the same project, same pattern → don't duplicate; instead, *append a one-line note to the existing entry*: `Reoccurred YYYY-MM-DD`

### Step 2 — Write the entry

Append to `~/.agents/skill-gaps.md` using the exact template above. Don't reformat or get creative.

### Step 3 — Confirm to the user

Output a one-line confirmation:
```
Logged skill gap: <one-line description>. (See ~/.agents/skill-gaps.md)
```

No more than that. The skill should add minimal flow tax — capturing should be cheap.

## Log file format

The log file lives at `~/.agents/skill-gaps.md`. If it doesn't exist, create it with this header:

```markdown
# Skill Gap Log

Captured friction observations from coding sessions. Reviewed weekly by `skill-ninja-review`.

## How to read this log

- Each entry is a structured observation, not a task.
- Entries with `Frequency signal: seen-in-prior-sessions` are graduation candidates.
- Entries with `Sensitivity flag: contains-pii-or-secret` go through manual review only.
- Entries are appended in time order; do not edit past entries except to add `Reoccurred YYYY-MM-DD` notes.

---
```

Then append entries below the `---`.

## Token-waste prevention

This skill should be cheap to invoke. Rules:

1. Don't summarize the entire conversation when logging — capture only the pattern, not the context.
2. Don't add suggestions for the skill to be created. That's `skill-ninja-review`'s job.
3. Don't read the entire log file every invocation. Use `grep` or read only the last 50 entries when checking for duplicates.
4. Don't ask follow-up questions beyond the one duplicate-check confirmation when relevant.

## What this skill does NOT do

- Does not create skills (that's `skill-ninja-review`)
- Does not analyze patterns (that's review's job)
- Does not interrupt flow with long prompts
- Does not log generic complaints — only structured patterns
