# project-ninja

Maintains alignment between code and project documentation across `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `README.md`, and a `docs/` folder of canonical project docs. Stack-agnostic — works for any language or framework.

## What it prevents

1. **Scope creep** — quietly adding features that aren't in `PRODUCT.md`
2. **Accidental deletion** — removing code that's referenced in docs
3. **Convention drift** — codebase stops matching its own documented rules
4. **Silent decision reversal** — overriding `DECISIONS.md` entries without acknowledging
5. **Doc bloat** — docs growing past the point of usefulness
6. **Token waste** — loading every doc on every turn instead of routing

## What it manages

```
/
├── AGENTS.md          # canonical agent briefing packet
├── CLAUDE.md          # one-line pointer → AGENTS.md
├── GEMINI.md          # one-line pointer → AGENTS.md
├── README.md          # human quickstart
└── docs/
    ├── PRODUCT.md       # scope (the most important doc)
    ├── ARCHITECTURE.md  # technical structure
    ├── API.md           # backend contract
    ├── DATABASE.md      # DB strategy
    ├── SCHEMA.md        # table-by-table reference
    ├── DESIGN.md        # all design tokens
    ├── BRAND.md         # identity (voice, naming, positioning)
    ├── UX.md            # flows and behaviors
    ├── COMPONENTS.md    # reusable component rules
    ├── DECISIONS.md     # ADR log (append-only)
    ├── SECURITY.md      # security rules (Hard Rules at top)
    └── TESTING.md       # test strategy
```

## Four modes

| Mode    | When                                       |
|---------|--------------------------------------------|
| INIT    | New project / missing files                |
| CONSULT | Before writing code (the most important)   |
| UPDATE  | After a change is merged                   |
| AUDIT   | Periodic drift check                       |

## How it saves tokens

The skill is structured so that each invocation only loads what's needed:

1. **SKILL.md is slim (~80 lines)** — contains binding rules + a routing table to mode-specific references. Loaded on every invocation.
2. **Mode-specific references** — INIT/CONSULT/UPDATE/AUDIT procedures live in separate files. Only the matched mode's reference is loaded.
3. **Section anchors in routing** — `references/routing.md` points to specific sections (e.g., `COMPONENTS.md#base-components`), so docs are read in fragments, not in full.
4. **INIT runs once** — after the doc set exists, the skill refuses to re-INIT. Ongoing use is CONSULT (1–2 docs) or UPDATE (1 doc, surgical edit).
5. **AUDIT is rare** — by design. The skill warns if AUDIT is invoked more often than every ~4 weeks.

Examples:
- "Fix CSS bug" → loads zero docs (just fix it)
- "Add a new API endpoint" → loads `consult.md` + `routing.md` + relevant sections of `API.md` and `SECURITY.md`
- "Migrate from one DB to another" → loads `consult.md` + `routing.md` + `DATABASE.md` and `DECISIONS.md`

Typical CONSULT session: 200–400 lines of doc content total.

## Files

```
project-ninja/
├── SKILL.md                       # slim core (~80 lines): rules + mode router
├── README.md                      # this file
├── references/
│   ├── init.md                    # INIT procedure (one-time scaffold)
│   ├── consult.md                 # CONSULT procedure (anti-drift checks)
│   ├── update.md                  # UPDATE procedure (surgical edits)
│   ├── audit.md                   # AUDIT procedure (drift check)
│   ├── routing.md                 # task → doc:section mapping
│   ├── workflows.md               # extended procedures (rarely needed)
│   ├── anti-drift.md              # drift-pattern detail (rarely needed)
│   └── cross-references.md        # ownership table
└── templates/                     # 16 minimal stack-agnostic templates
    ├── AGENTS.md
    ├── CLAUDE.md
    ├── GEMINI.md
    ├── README.md
    └── docs/
        ├── PRODUCT.md
        ├── ARCHITECTURE.md
        ├── API.md
        ├── DATABASE.md
        ├── SCHEMA.md
        ├── DESIGN.md
        ├── BRAND.md
        ├── UX.md
        ├── COMPONENTS.md
        ├── DECISIONS.md
        ├── SECURITY.md
        └── TESTING.md
```

## How to invoke

Trigger phrases recognized by the skill:

- **INIT:** "set up docs", "init project-ninja", "scaffold docs"
- **CONSULT:** any non-trivial code request — the skill should self-trigger
- **UPDATE:** "I just shipped X", "we merged Y", "update the docs"
- **AUDIT:** "audit the docs", "check alignment", "are docs current"

## Customizing

The templates ship lean by design and stack-agnostic. The skill instructs Claude not to pad them — if a section doesn't apply to your project, delete it; if you don't know yet, leave a `TODO(<owner>):` marker.

To add stack-specific routing rules (e.g., "if user mentions LLM agents, load SECURITY.md and ARCHITECTURE.md"), add them to your project's `AGENTS.md` under "Project-specific routing." The skill picks them up automatically during CONSULT mode.
