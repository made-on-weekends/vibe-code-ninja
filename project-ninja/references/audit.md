# AUDIT Mode Procedure

Loaded only when checking for drift between docs and code. Read-only by design.

## When to run AUDIT

AUDIT is **expensive on purpose** — it loads multiple docs and samples claims against the codebase. It earns its cost only periodically.

Run AUDIT when:
- The user explicitly asks ("audit the docs", "check alignment", "are docs current")
- A doc hasn't been touched in a long time and you suspect drift
- You're onboarding to a project and want to verify the docs match reality

Do NOT run AUDIT routinely. Specifically:
- Don't run it after every UPDATE
- Don't run it as part of CONSULT
- Don't run it on a fixed schedule

Recommended cadence: at most once every 4 weeks per project, unless something specific triggers it. If the user runs AUDIT more often, gently note: *"AUDIT is a sampling pass and is expensive. Last run was <N> days ago. Want me to proceed, or is there a specific doc you suspect is stale?"*

## Procedure

### Step 1 — Inventory

List all docs that exist in the repo (Tier 1 + any Tier 2/3 that exist) with last-modified dates. This is a quick `ls -lt` plus reading filenames; cheap.

### Step 2 — Sample claims

For each doc, sample claims most likely to drift. Do NOT read end to end.

| Doc            | Sample these claims                                        |
|----------------|-----------------------------------------------------------|
| AGENTS.md      | Commands match manifest scripts; version numbers; do-not-touch zones still exist |
| README.md      | Quickstart command works; structure section matches actual dirs |
| PRODUCT.md     | "In scope" list matches features actually implemented      |
| ARCHITECTURE.md| Layer descriptions match code organization; deploy steps  |
| API.md         | Endpoint shapes match route handlers; auth header matches |
| DATABASE.md    | Engine version; migration tool; multi-tenancy strategy    |
| SCHEMA.md      | Tables and columns match latest migrations                |
| DESIGN.md      | Token values match what's in code/styles                  |
| BRAND.md       | Logo paths exist; named colors still in DESIGN.md         |
| UX.md          | Documented flows still exist in routes                    |
| COMPONENTS.md  | Listed base components still exist at given paths         |
| DECISIONS.md   | Recent decisions reflected in code                        |
| SECURITY.md    | Hard rules still enforced; PII inventory matches schema   |
| TESTING.md     | Commands work; coverage policy applied in CI config       |

Pick 2–3 claims per doc. Don't go deeper.

### Step 3 — Produce the report

Format:
```
## AGENTS.md  (last touched 2026-04-12)
[OK]      pnpm dev script matches package.json
[STALE]   Claims Node 18, package.json engines says 20
[OK]      State management conventions match src/stores/

## PRODUCT.md (last touched 2026-02-03)
[OK]      Target user matches landing page copy
[MISSING] Code includes Stripe integration; PRODUCT.md doesn't mention payments
```

Status values:
- `[OK]` — doc claim matches code
- `[STALE]` — doc claims X but code does Y; one-line summary including file:line evidence
- `[MISSING]` — code does X but no doc covers it; one-line summary

### Step 4 — Surface, do not auto-fix

Present findings. Let the user decide what to fix in a follow-up UPDATE pass.

Audits are read-only by design. Reason: an audit that auto-fixes is two changes in one session (audit + update), and either step might get the other one wrong. Separating discovery from action makes both more reliable.

## Token usage notes

AUDIT is the most expensive mode after INIT. Per-doc cost is low (sampling, not reading) but multiplied by N docs.

Typical AUDIT session loads:
- This file (audit.md): ~70 lines
- Brief sample reads of every existing doc (~20–30 lines each via section reads, not full files)
- Spot checks against codebase (manifest, route handlers, migration files)

Total: usually 500–1500 lines depending on project size. This is why cadence matters.

If a project's docs are well-maintained via diligent UPDATE passes, AUDIT will find little. That's the right outcome — AUDIT exists as a safety net, not a primary mode.

## What AUDIT does NOT do

- Does not modify any docs
- Does not modify any code
- Does not run anti-drift checks (those are CONSULT's job)
- Does not deep-read any doc — sampling only
- Does not produce a report longer than the issues warrant
