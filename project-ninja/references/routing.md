# Routing Reference

The complete table for deciding which docs (and which sections within them) to load. Rule of thumb: load 1–3 docs per task, never the whole set, and read only the section anchor specified.

## How to use the routing table

The `Load` column lists docs with optional section anchors. Format:

- `API.md` → load the whole file (rare)
- `API.md#endpoints` → load only the "Endpoints" section
- `API.md#endpoints + #conventions` → load both named sections, nothing else
- `+ grep all docs for X` → in addition to listed docs, search all `.md` files for the given term

If a section anchor is given, **read only that section.** Loading the whole file when an anchor was specified is a token-waste violation.

## Tier 1 (the spine — always exists)

These docs anchor the project. INIT creates them first.

- `AGENTS.md` — agent briefing packet, single source of truth for tooling/commands/conventions
- `CLAUDE.md` — pointer to AGENTS.md (one line)
- `GEMINI.md` — pointer to AGENTS.md (one line)
- `README.md` — for humans
- `docs/PRODUCT.md` — what we're building, for whom, scope
- `docs/ARCHITECTURE.md` — high-level technical structure
- `docs/DECISIONS.md` — settled architectural decisions

## Tier 2 (create when relevant)

- `docs/API.md` — only when there's a backend API
- `docs/DATABASE.md` — only when there's a DB
- `docs/SCHEMA.md` — only when DB has non-trivial schema
- `docs/COMPONENTS.md` — only when there's a UI component library
- `docs/SECURITY.md` — recommended for any production app
- `docs/TESTING.md` — only when test strategy is non-default

## Tier 3 (create only when explicitly needed)

- `docs/DESIGN.md` — when UI system has explicit token rules
- `docs/BRAND.md` — when there's a defined brand identity
- `docs/UX.md` — when user flows have explicit rules

## Routing table — task → docs (and sections) to load

### Code-writing tasks

| User intent / signal                          | Load                                                                                  |
|-----------------------------------------------|---------------------------------------------------------------------------------------|
| "Add feature X"                               | `PRODUCT.md#in-scope` + `ARCHITECTURE.md#layers` + `DECISIONS.md` (scan Accepted)     |
| "Build a new page/screen"                     | `PRODUCT.md#in-scope` + `UX.md#core-flows` + `COMPONENTS.md#base-components` + `DESIGN.md#layout-rules` |
| "Remove / delete / clean up X"                | `PRODUCT.md#in-scope` + `DECISIONS.md` + grep all docs for X                          |
| "Refactor X"                                  | `DECISIONS.md` only (scan for relevant entries)                                       |
| "Fix bug in X"                                | None — unless bug reveals doc is wrong                                                |
| "Migrate from A to B"                         | `ARCHITECTURE.md#patterns-we-use` + `DECISIONS.md` + the relevant tier-2 doc          |

### Layer-specific tasks

| Layer / area                  | Load                                                                                          |
|-------------------------------|-----------------------------------------------------------------------------------------------|
| Authentication / sessions     | `SECURITY.md#hard-rules` + `SECURITY.md#authentication` + `ARCHITECTURE.md#cross-cutting-concerns` + `DATABASE.md#access-policies` |
| Authorization / permissions   | `SECURITY.md#authorization` + `DATABASE.md#access-policies`                                   |
| New API endpoint              | `API.md#conventions` + `API.md#do--dont` + `SECURITY.md#hard-rules` + `DECISIONS.md`          |
| Modifying existing endpoint   | `API.md#endpoints` (find the specific endpoint section)                                       |
| DB migration                  | `DATABASE.md#migrations` + `SCHEMA.md` + `DECISIONS.md`                                       |
| New table / column            | `SCHEMA.md#conventions` + `DATABASE.md#multi-tenancy-strategy`                                |
| Access policy change          | `DATABASE.md#access-policies` + `SECURITY.md#authorization`                                   |
| New UI component              | `COMPONENTS.md#base-components` + `COMPONENTS.md#prop-api-rules` + `DESIGN.md#patterns` + `BRAND.md#voice-rules` (if user-facing copy) |
| New state container / store   | `ARCHITECTURE.md#layers`                                                                      |
| Page / route change           | `UX.md#core-flows` + `ARCHITECTURE.md#layers`                                                 |
| Email / notification change   | `UX.md#notifications` + `BRAND.md#voice-rules`                                                |
| Test for new feature          | `TESTING.md#what-to-test` + `TESTING.md#conventions`                                          |
| New CI step                   | `TESTING.md#ci` + `AGENTS.md#commands`                                                        |

### Conversational signals

| Phrase from user                              | Load                                                              |
|-----------------------------------------------|-------------------------------------------------------------------|
| "What did we decide about..."                 | `DECISIONS.md` (scan for keyword)                                 |
| "Is X in scope"                               | `PRODUCT.md#in-scope` + `PRODUCT.md#explicitly-out-of-scope`      |
| "What's our convention for..."                | `AGENTS.md#conventions` + relevant tier-2 doc                     |
| "Why does X work this way"                    | `DECISIONS.md` + `ARCHITECTURE.md#patterns-we-use`                |
| "Is this consistent with our brand"           | `BRAND.md#voice-rules` + `DESIGN.md#patterns`                     |
| "Is this allowed by our security rules"       | `SECURITY.md#hard-rules`                                          |

## Anti-patterns (do not do these)

- ❌ Loading PRODUCT, ARCHITECTURE, DECISIONS, API, DATABASE, SCHEMA all at once "to be safe"
- ❌ Loading the full `API.md` when the routing table specified `API.md#endpoints`
- ❌ Loading docs you won't actually consult before writing code
- ❌ Loading SCHEMA.md to fix a CSS bug
- ❌ Loading BRAND.md to write a database migration

## Edge cases

**The task spans layers.** Example: "Add a feature where users get an email when their report is ready."
- Spans: PRODUCT (scope), ARCHITECTURE (where the trigger lives), API (new endpoint?), DATABASE (queue table?), UX (when shown), BRAND (email tone).
- Don't load all six at once. Plan the change in 3 lines first, then load only the docs needed for the layer you're starting with. Load others only when you reach that layer.

**Unsure which doc applies.** Ask: *"For this task, I think I need to consult <X> and <Y> — anything else you think is relevant?"* One question beats six unnecessary doc loads.

**Doc doesn't exist yet.** Proceed with code. In UPDATE mode, propose creating the doc.

**Section anchor missing in a doc.** If a routing entry says `COMPONENTS.md#base-components` but COMPONENTS.md doesn't have that section header (e.g., it's an older or custom doc), fall back to reading the table of contents and finding the closest match. Never re-read the whole file.

## Stack-specific extensions

Projects can extend this routing table with stack-specific signals. Add a section to your project's `AGENTS.md` called "Project-specific routing" with rows like:

```
| User intent / signal              | Load                                                  |
|-----------------------------------|-------------------------------------------------------|
| "Add background job"              | ARCHITECTURE.md#background-jobs + DATABASE.md         |
| "Add LLM agent capability"        | ARCHITECTURE.md#external-services + SECURITY.md#hard-rules |
```

The skill picks up these rows during CONSULT mode if `AGENTS.md` is loaded.
