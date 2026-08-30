# Cross-References Ownership Table

The single source of truth for "which doc owns which topic." Loaded during INIT (to decide what content goes where) and UPDATE (to identify cross-references that need maintenance).

The rule: **every topic has exactly one owner.** Other docs may reference it but never duplicate it. When a topic changes, the owner doc is updated; cross-referenced docs are checked for stale links.

## Ownership table

| Topic                            | Owner          | Cross-referenced by                        | Notes                                            |
|----------------------------------|----------------|--------------------------------------------|--------------------------------------------------|
| Color palette (hex values)       | DESIGN.md      | BRAND.md (identity colors named only)      | DESIGN owns all values; BRAND names brand-defining choices |
| Typography scale (sizes/weights) | DESIGN.md      | BRAND.md (typeface choice named only)      | Same pattern as colors                           |
| Spacing/radii/shadow tokens      | DESIGN.md      | —                                          | Single owner                                     |
| Voice and tone rules             | BRAND.md       | UX.md (microcopy), API.md (error messages) | BRAND owns voice; usage docs link out            |
| Logo and naming                  | BRAND.md       | —                                          | Single owner                                     |
| Positioning statement            | BRAND.md       | PRODUCT.md (target user echoes)            | PRODUCT owns scope; BRAND owns identity          |
| Product scope (in/out)           | PRODUCT.md     | DECISIONS.md (scope decisions)             | Scope changes are decisions                      |
| Target user / persona            | PRODUCT.md     | UX.md (flows assume this user)             | UX patterns derive from persona                  |
| Architecture overview            | ARCHITECTURE.md| README.md (one-paragraph mention)          | README links out; ARCHITECTURE has detail        |
| Auth flow (mechanics)            | SECURITY.md    | ARCHITECTURE.md (high-level only)          | SECURITY owns mechanics; ARCH shows the layer    |
| Auth API endpoints               | API.md         | SECURITY.md (rationale only)               | API owns shape; SECURITY owns why                |
| Rate limit values                | API.md         | SECURITY.md (threat model rationale)       | API owns numbers; SECURITY owns reasoning        |
| Access policies (RLS, RBAC)      | DATABASE.md    | SECURITY.md (why we use these)             | DATABASE owns policies; SECURITY owns reasoning  |
| Schema (table-by-table)          | SCHEMA.md      | DATABASE.md (multi-tenancy strategy)       | SCHEMA = reference; DATABASE = strategy          |
| Migration strategy               | DATABASE.md    | AGENTS.md (do-not-touch rule)              | AGENTS surfaces the rule; DATABASE explains it   |
| Component reuse threshold        | COMPONENTS.md  | DESIGN.md (when patterns become tokens)    | COMPONENTS owns components; DESIGN owns tokens   |
| Component prop API rules         | COMPONENTS.md  | —                                          | Single owner                                     |
| Test commands                    | AGENTS.md      | TESTING.md (what to test)                  | AGENTS owns commands; TESTING owns strategy      |
| Test strategy                    | TESTING.md     | AGENTS.md (commands referenced)            | Mirror of above                                  |
| Settled architectural decisions  | DECISIONS.md   | (referenced from any doc)                  | Append-only; everything can reference            |
| Hard security rules              | SECURITY.md    | DECISIONS.md (overrides require entry)     | Hard rules need DECISIONS entry to violate       |
| Stack/tooling/commands           | AGENTS.md      | README.md (quickstart command only)        | AGENTS = source of truth; README links out       |
| Error response shape             | API.md         | —                                          | Single owner                                     |
| Idempotency / pagination policy  | API.md         | —                                          | Single owner                                     |
| Undo / irreversible action rules | UX.md          | —                                          | Single owner                                     |
| Empty/loading state policy       | UX.md          | DESIGN.md (visual treatment)               | UX = behavior; DESIGN = appearance               |
| PII fields                       | SECURITY.md    | SCHEMA.md (column-level marker)            | SECURITY owns inventory; SCHEMA marks columns    |

## How to use this table

### During INIT mode

When filling templates, consult this table to know what *not* to put where. Examples:
- User describes color palette → goes in DESIGN.md only; BRAND.md gets a one-line mention plus link
- User describes auth flow → mechanics in SECURITY.md, layer placement in ARCHITECTURE.md, endpoint shapes in API.md
- User describes test strategy → strategy in TESTING.md, commands in AGENTS.md

### During UPDATE mode

When a change touches a "Topic" row, check all docs in both "Owner" and "Cross-referenced by" columns. The Owner gets the update. The cross-referenced docs get a stale-reference check.

Example:
1. Change: schema for `users` table got a new column `pii_email`.
2. Owner: SCHEMA.md — update the column list.
3. Cross-referenced by: DATABASE.md (multi-tenancy strategy may reference users table) — check.
4. Also: SECURITY.md owns "PII fields" topic, and SCHEMA.md cross-references it — verify the column is marked as PII in SCHEMA.md and registered in SECURITY.md's PII inventory.

### During AUDIT mode

Verify cross-references resolve: the linked-from doc actually exists and the link target still says what was claimed. A broken cross-reference is `[STALE]`.

## When a topic isn't in the table

Default rule: ask the user where it should live. Don't invent a new placement. After the decision, propose adding the row to this table.

The table can grow over time. Add rows when a project introduces a new topic that doesn't fit existing rows. Document the addition in DECISIONS.md if the placement is contested.

## What this table prevents

- BRAND.md and DESIGN.md duplicating color hex codes
- API.md and SECURITY.md duplicating rate limit values
- ARCHITECTURE.md and SECURITY.md duplicating auth flow descriptions
- AGENTS.md and TESTING.md duplicating test commands
- General entropy where every doc grows to cover everything
