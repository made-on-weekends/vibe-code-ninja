---
name: project-ninja
description: Maintain alignment between code and project documentation across AGENTS.md, CLAUDE.md, GEMINI.md, README.md, and the docs/ folder (PRODUCT, ARCHITECTURE, API, DATABASE, SCHEMA, DESIGN, BRAND, UX, COMPONENTS, DECISIONS, SECURITY, TESTING). Stack-agnostic — works for any language or framework. Use this skill at the start of any non-trivial coding session to load ONLY the relevant docs (token-efficient routing), before adding or removing features (to prevent scope drift and accidental deletions), and after changes are merged (to update only the docs that actually need updating). Trigger this skill whenever the user mentions align, drift, scope, documentation, project setup, init, update docs, refactor, or any feature add or remove — even if they do not explicitly ask for documentation work. Also trigger on phrases like "is this in scope", "did we decide", "what's the convention", or any time the user is about to delete code.
---

# project-ninja

Keeps a project's code and canonical docs in sync without burning tokens. Stack-agnostic.

## Mandatory pre-flight (every invocation)

Before doing anything else, complete these three steps in order. Do not skip.

**Step 1 — Pick the mode.** Match the user's intent to one row:

| User intent                                | Mode      | Read this reference                                  |
|--------------------------------------------|-----------|------------------------------------------------------|
| New project, or repo missing AGENTS.md     | INIT      | `references/init.md`                                 |
| About to write/change/delete code          | CONSULT   | `references/consult.md` + `references/routing.md`    |
| Just finished merging a change             | UPDATE    | `references/update.md` + `references/cross-references.md` |
| Periodic health check, doc feels stale     | AUDIT     | `references/audit.md`                                |

If the change is purely internal (rename a local variable, fix a typo, reformat) → skip CONSULT entirely. Just do it.

**Step 2 — INIT guard.** If you matched INIT but `AGENTS.md` already exists at repo root, STOP. Surface to the user: *"AGENTS.md already exists. INIT is a one-time scaffold. Did you mean UPDATE (after a change) or AUDIT (drift check)?"* Do not proceed without explicit confirmation that the user really wants to re-run INIT.

**Step 3 — Load only the reference for your matched mode.** Do not pre-load the others. Each reference contains the full procedure for that mode.

## Token-waste prevention rules (binding, all modes)

These rules govern every action this skill takes. Violating them is the failure mode this skill exists to prevent.

1. **Routing is mandatory in CONSULT mode.** Read `references/routing.md` and load only the docs whose triggers match the task — never all docs "to be safe."
2. **Read only the section pointed to by the routing table.** If the routing entry says `COMPONENTS.md#base-components`, read only that section. If you can't name which section a doc's content will inform the current task, you shouldn't have loaded it.
3. **Never read a doc you're not going to act on.** Loading PRODUCT.md commits you to running the scope check. Otherwise skip the load.
4. **Never regenerate a doc from scratch when a surgical edit will do.** Surgical = modify only the specific sentences/rows/code-blocks whose facts changed. No "while I'm here" cleanup.
5. **Never create empty/stub docs to "fill out the structure".** Empty docs teach false confidence. Use TODO markers instead.
6. **Never duplicate content across docs.** `references/cross-references.md` is the ownership table — every topic has exactly one owner.
7. **CLAUDE.md and GEMINI.md are pointers.** One line, pointing at AGENTS.md. Never let them grow.
8. **If unsure whether to update a doc, ask one question rather than write a guessing update.**

## The canonical doc set

```
/
├── AGENTS.md          # canonical agent briefing packet
├── CLAUDE.md          # one-line pointer → AGENTS.md
├── GEMINI.md          # one-line pointer → AGENTS.md
├── README.md          # human quickstart
└── docs/
    ├── PRODUCT.md       # scope (what we're building, for whom)
    ├── ARCHITECTURE.md  # technical structure
    ├── API.md           # backend contract
    ├── DATABASE.md      # DB strategy
    ├── SCHEMA.md        # table-by-table reference
    ├── DESIGN.md        # all design tokens
    ├── BRAND.md         # identity (voice, naming, positioning)
    ├── UX.md            # flows and behavior rules
    ├── COMPONENTS.md    # reusable UI component rules
    ├── DECISIONS.md     # ADR log (append-only)
    ├── SECURITY.md      # security rules (Hard Rules at top)
    └── TESTING.md       # test strategy
```

## Reference files

Load only the one(s) needed for your matched mode:

- `references/init.md` — INIT procedure (one-time scaffold)
- `references/consult.md` — CONSULT procedure (anti-drift checks before code)
- `references/update.md` — UPDATE procedure (surgical edits after a change)
- `references/audit.md` — AUDIT procedure (drift check, read-only)
- `references/routing.md` — task → doc mapping (loaded by CONSULT and UPDATE)
- `references/cross-references.md` — ownership table (loaded by INIT and UPDATE)
- `references/anti-drift.md` — drift-detection patterns (deeper detail for CONSULT)
- `references/workflows.md` — extended procedures (rarely needed; references above are usually sufficient)

Templates live in `templates/` and are loaded only by INIT.
