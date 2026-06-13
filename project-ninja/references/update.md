# UPDATE Mode Procedure

Loaded after a non-trivial code change has been merged. Updates the docs that need updating; ignores the rest.

## The minimal-update principle

Most code changes do NOT require doc updates. Updating docs for trivial changes is a major source of token waste. Apply this filter first:

| Change type                                       | Update docs? |
|---------------------------------------------------|--------------|
| Bug fix, no behavior change                       | No           |
| Internal refactor, no API/UX change               | No           |
| Renamed variable, formatting, dependency bump     | No           |
| New API endpoint                                  | Yes — API.md |
| Schema change                                     | Yes — SCHEMA.md, maybe DATABASE.md |
| New feature visible to users                      | Yes — PRODUCT.md, possibly UX.md |
| New reusable component                            | Yes — COMPONENTS.md |
| Architectural decision (DB, framework, pattern)   | Yes — DECISIONS.md (append only) |
| New auth flow, permission, or threat model change | Yes — SECURITY.md |
| Brand or visual identity change                   | Yes — BRAND.md (identity) and/or DESIGN.md (tokens) |
| Test framework or strategy change                 | Yes — TESTING.md |

If none of the trigger rows apply, skip UPDATE entirely.

## Procedure

### Step 1 — Identify which docs need updating

For each trigger that applied, identify the specific doc and the specific section that needs the update.

### Step 2 — Load cross-references

Read `references/cross-references.md`. Find the topic row for the change. Note both the Owner column and the Cross-referenced by column. The Owner gets the primary update; the cross-referenced docs get a stale-reference check.

### Step 3 — Surgical edits

For each doc:

1. Read the current content of the relevant section only — not the whole file.
2. Identify the smallest change that captures the new reality.
3. Edit only that section. Don't rewrite surrounding content.
4. **30% rule:** if the change requires more than ~30% of the doc to be rewritten, STOP and surface: *"Updating <doc> for this change would touch ~N% of the file. That signals a structural shift — should I rewrite, or is the change actually broader than we discussed?"*

Surgical, defined: modify only the specific sentences, table rows, list items, or code-block contents whose facts changed. Do not adjust surrounding text for style, flow, or "while I'm here" cleanup. If a surrounding sentence is now factually wrong because of the change, that sentence is also a surgical edit — but unrelated style improvements are not.

### Step 4 — DECISIONS.md special handling

DECISIONS.md is append-only. Never edit or delete past entries.

Exception: when superseding a past entry, you may update **only** the `Status` field of the old entry to `Superseded by #NNNN`.

New entry format:
```
## NNNN — Title

**Date:** YYYY-MM-DD
**Status:** Accepted
**Context:** <why this came up>
**Decision:** <what we decided>
**Consequences:** <what changes>
**Supersedes:** #NNNN (if applicable)
```

### Step 5 — Cross-reference check

For the docs you updated, look up each in the `Cross-referenced by` column of cross-references.md. For each cross-referenced doc:
- Quick check: does it still describe the topic correctly given the change?
- If yes → no update needed (note this in your output)
- If no → make the surgical edit there too

List the cross-references you checked, even when none needed updating, so the user can verify nothing was missed.

### Step 6 — PRODUCT.md scope guard

If the change implies a scope addition to PRODUCT.md, get explicit user confirmation before adding. Don't quietly expand scope in UPDATE mode any more than in CONSULT mode.

### Step 7 — Confirm to user

Show a one-line summary per doc:

```
Updated 2 docs:
- API.md — added POST /reports endpoint to "Report endpoints" section
- DECISIONS.md — appended #0007 (chose pgvector over Pinecone)

Cross-references checked (no updates needed):
- ARCHITECTURE.md
- SECURITY.md (rate limit rationale)
```

## Token usage notes

A typical UPDATE session loads:
- This file (update.md): ~70 lines
- cross-references.md: ~75 lines (jump to matching topic row)
- 1–2 docs, only the relevant section
- Possibly DECISIONS.md if appending an entry

Total: usually 200–350 lines per session. Most UPDATE sessions touch 1 doc + 1 cross-reference check.

## What UPDATE does NOT do

- Does not regenerate docs from scratch
- Does not "improve" prose unrelated to the change
- Does not edit DECISIONS.md history (only appends, plus the one-field Status edit when superseding)
- Does not silently expand PRODUCT.md scope
- Does not rewrite CLAUDE.md or GEMINI.md beyond their pointer-line role
