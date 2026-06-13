# Workflows: Common Failure Modes

This file is an escape valve for when something has gone wrong and you need a quick reference for the fix. Mode procedures themselves live in the per-mode files (`init.md`, `consult.md`, `update.md`, `audit.md`).

## Failure modes table

| Failure                                              | Fix                                                                |
|------------------------------------------------------|--------------------------------------------------------------------|
| Loaded all docs at session start                     | Use `references/routing.md`; load 1–3 docs max, with section anchors |
| Loaded full doc when routing specified an anchor     | Re-read only the named section; cite the anchor in your output     |
| Generated doc content from imagination               | Use `TODO(<owner>):` markers; ask the user instead of guessing     |
| Updated docs for a no-op refactor                    | Apply the UPDATE filter in `update.md`; most changes need no update |
| Edited DECISIONS.md history (other than Status)      | Append-only; supersede with new entry; only Status of past entry can change |
| Quietly let scope expand                             | Run scope check from `consult.md`; surface PRODUCT.md mismatch     |
| Deleted code without updating docs that referenced it| Run deletion check from `consult.md`                               |
| CLAUDE.md or GEMINI.md grew beyond a pointer line    | Truncate back to pointer; move content to AGENTS.md                |
| Duplicated content across BRAND.md and DESIGN.md     | Use `cross-references.md`; topics have one owner                   |
| Re-ran INIT on a project that already has AGENTS.md  | INIT guard should have caught this; if not, undo via git           |
| Auto-loaded mode-specific reference for wrong mode   | Re-read the SKILL.md mode table; load only the matched mode's file |
| Ran AUDIT after every UPDATE                          | AUDIT cadence is ~4 weeks; remove from routine                     |

## When to read this file

- An anti-drift check produced unexpected output
- A token-waste rule was violated and you need to recover
- The user asks why something went wrong in a previous session

For normal operation, the per-mode files are sufficient. Don't load this file preemptively.
