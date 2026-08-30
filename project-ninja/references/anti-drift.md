# Anti-Drift Reference

The five things this skill is built to prevent. Read this when CONSULT mode flags a potential issue and you need the deeper pattern.

## 1. Scope creep (silently adding features)

### How it happens

User asks for "a small thing": add a notification when a report is ready. You build it. While building, you notice notifications could also work for failed jobs, so you add that too. Then you add user preferences for notification frequency. None of this is in PRODUCT.md.

Six weeks later: nobody knows what's in scope, the product surface has doubled, and the docs are useless.

### Detection patterns

Flag these signals in user requests:

- "While you're at it, also..."
- "It would be nice if..."
- "Quick addition:..."
- A second feature mentioned mid-task
- Generalization of a specific feature ("make it work for all X" when only one X was scoped)
- New user-facing surface area (a new page, a new email, a new notification type)

### Response

When detected, pause and surface:
> *"That looks like additional scope beyond the original task. Specifically: <what's new>. Three options:*
> *1. Defer it — finish the original task, log this as a follow-up*
> *2. Expand scope — add it to PRODUCT.md and proceed*
> *3. Replace — drop the original, do this instead*
> *Which?"*

Three options is the right shape. "Should I do this?" is too binary; "what should we do?" is too open.

## 2. Accidental deletions (removing features that mattered)

### How it happens

Refactor of the auth module. In the cleanup, a "remember me" checkbox is removed because it looked unused. Three weeks later: support tickets pile up. Turns out 30% of users relied on it.

### Detection patterns

Before any deletion of a non-trivial code unit (component, function with >5 callers, route, table, column, env var), grep for references in:

1. **Docs** — every `.md` file in the project
2. **Tests** — does any test name mention this thing?
3. **Comments** — any TODO/FIXME tied to it?
4. **Recent commits** — was this added recently with intent?

### The deletion checklist

For each deletion, verify:

- [ ] Is it in any doc? If yes, removal must include doc update.
- [ ] Is it in DECISIONS.md? If yes, this deletion may be reversing a decision — needs explicit user confirmation.
- [ ] Is it in PRODUCT.md as a feature? If yes, this is scope reduction — needs user confirmation.
- [ ] Is there a test for it? If yes, why is the test there? Removing the test alongside is fine if the feature is going; suspicious if not.

### Response

When the checklist surfaces something, surface it:
> *"`<thing>` is referenced in <docs/tests>. Confirm deletion. If yes, I'll update <doc> in the same change. If no, I'll leave it."*

Never silently delete things mentioned in docs.

## 3. Convention drift (codebase stops matching its own rules)

### How it happens

AGENTS.md says "All API errors return in response body, never throw." Six months in, half the new endpoints throw because someone copy-pasted from a tutorial and nobody flagged it.

### Detection patterns

In CONSULT mode, when about to write code, check the relevant convention doc:

- General code conventions → AGENTS.md
- API endpoints → API.md (endpoint shape conventions)
- DB queries → DATABASE.md (access patterns)
- UI components → COMPONENTS.md
- Tests → TESTING.md (framework, structure)

If your draft code doesn't match the documented convention:
- If you have a reason to deviate: surface it. *"AGENTS.md says X. I want to do Y here because Z. OK to deviate, or should I match the convention?"*
- If you have no reason to deviate: just match the convention.

### The "this is the third time" rule

If you find yourself writing similar code three times across sessions (e.g., three forms with similar structure), surface:
> *"I've now written three similar <thing>s. Worth extracting a pattern into COMPONENTS.md and a reusable component, or keep ad hoc?"*

Don't auto-extract. Surface and let the user decide.

## 4. Decision reversal without acknowledgment

### How it happens

DECISIONS.md #0003 says "Use SQLite for local dev, Postgres in production." Months later, a feature gets added that assumes Postgres-only features in dev. The decision was never reversed; it was just forgotten.

### Detection pattern

In CONSULT mode, when working in an area covered by a decision, read that decision entry. If the proposed approach contradicts it:

> *"DECISIONS.md #0003 (date) says <decision>. The proposed change would contradict it. Two options:*
> *1. Follow the existing decision*
> *2. Formally reverse it — I'll add a new entry that supersedes #0003*
> *Which?"*

Never silently overwrite a decision. The audit trail is the value.

### Hard rules in SECURITY.md

SECURITY.md hard rules are a stronger version of decisions: violating one requires a DECISIONS.md entry that supersedes the rule, with security review. Treat hard-rule violations as automatic stops.

## 5. Doc bloat (docs grow into noise)

### How it happens

Every change adds a paragraph to AGENTS.md. After a year it's 800 lines and no agent reads past the first 200.

### Detection pattern

If updating a doc would push it past these soft limits, flag it:

| Doc           | Soft limit |
|---------------|------------|
| AGENTS.md     | 200 lines  |
| README.md     | 100 lines  |
| PRODUCT.md    | 150 lines  |
| ARCHITECTURE.md | 300 lines |
| DECISIONS.md  | unlimited (append-only by design) |
| All others    | 250 lines  |

When a doc passes the soft limit, surface:
> *"Updating <doc> would push it to <N> lines, past the soft limit. Options: (a) accept the growth, (b) split into a sub-doc, (c) prune older content. Which?"*

These are soft limits, not hard. Some projects legitimately need longer docs. Just make the growth a conscious choice.

## Summary table

| Drift type             | Detect by                                    | Surface as                              |
|------------------------|----------------------------------------------|-----------------------------------------|
| Scope creep            | "Also...", "while you're at it..."           | 3-option choice                         |
| Accidental deletion    | Grep docs/tests for the thing being removed  | "Referenced in X — confirm or keep"     |
| Convention drift       | Compare draft code to AGENTS.md / Tier-2 doc | "Says X, I'm doing Y because Z"        |
| Decision reversal      | Decision touches the area being changed      | "DECISIONS.md #N — follow or supersede"|
| Doc bloat              | Doc length past soft limit                   | "Past limit — accept/split/prune"      |
