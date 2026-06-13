# INIT Mode Procedure

Loaded only when the user is scaffolding a new project's doc set.

## Pre-flight check (mandatory)

Before any other step, verify INIT is the right mode:

- Does `AGENTS.md` already exist at repo root? → STOP. INIT is a one-time scaffold. The user likely wants UPDATE (after a change) or AUDIT (drift check), or wants to add a single missing doc (which is a manual step, not a re-INIT).
- Surface: *"AGENTS.md already exists. INIT is a one-time scaffold. What do you actually want to do?"*

Only proceed if the user explicitly confirms they want to scaffold (e.g., `AGENTS.md` was deleted, or this is genuinely a new project).

## The read-then-ask rule (governs every field)

For each field in a template, classify what evidence the codebase provides, then act accordingly:

| Evidence            | Action                                                                                  |
|---------------------|-----------------------------------------------------------------------------------------|
| Unambiguous         | Fill the field. Example: `package.json` has `"packageManager": "pnpm@9.0"` → fill `pnpm`. |
| Partial/conflicting | Ask one targeted question. Example: both `pnpm-lock.yaml` and `package-lock.json` exist → "I see both lockfiles — which is canonical?" |
| Absent              | Leave `TODO(<owner>): <specific question>` and add to the post-scaffold TODO list.      |

**Never pick the most-likely answer for the partial/conflicting case.** The cost of asking is one user message. The cost of a confident wrong guess is misaligned docs that propagate for weeks. This is the central rule of INIT mode.

## Procedure

### Step 1 — Inventory the codebase

Run `ls` at repo root. Read manifest files (`package.json`, `pyproject.toml`, `Gemfile`, `go.mod`, `Cargo.toml`, `composer.json`, etc.). Inspect any existing `AGENTS.md`/`README.md`. Skim top-level directory structure. Note what you found.

Do NOT start filling templates until this pass is complete.

### Step 2 — Read the cross-references table

Read `references/cross-references.md` once. This tells you which doc owns which topic, so you don't accidentally put color hex values in BRAND.md or test commands in TESTING.md.

### Step 3 — Create Tier 1 files (the spine)

In order, applying the read-then-ask rule per field:

1. `AGENTS.md` — populate from manifest scripts, observed framework versions, and one user interview question: "What's your one-line stack summary?"
2. `CLAUDE.md` — single line pointing at AGENTS.md
3. `GEMINI.md` — single line pointing at AGENTS.md
4. `README.md` — minimal: title, one-paragraph description, quickstart command, link to AGENTS.md
5. `docs/PRODUCT.md` — interview the user: "What does this product do, for whom, and what is explicitly NOT in scope?" Capture answers verbatim.
6. `docs/ARCHITECTURE.md` — diagram the layers: frontend, backend, DB, hosting. ASCII diagram is fine.
7. `docs/DECISIONS.md` — start with one entry: "0001 — Project initialized" — date, context, no actual decision yet, just the anchor.

### Step 4 — Ask before each Tier 2/3 file

Don't batch-create. For each, ask one at a time:

*"Should I scaffold `<file>` now? (yes if you have <criterion>)"*

- API.md — ask if backend exists
- DATABASE.md, SCHEMA.md — ask if DB exists
- COMPONENTS.md — ask if there's a component library
- SECURITY.md — strongly recommended for any production app
- TESTING.md — ask if non-default test strategy
- DESIGN.md, BRAND.md, UX.md — only on explicit user request or when artifacts exist to capture

Empty templates are noise. Batched questions get half-answered.

### Step 5 — Output the TODO list

After scaffolding, output the TODO list as a single block:

```
Created N files. M TODOs to fill in:
- AGENTS.md:23 — confirm Node version
- PRODUCT.md:8 — define out-of-scope items
- ARCHITECTURE.md:14 — confirm hosting target
- DECISIONS.md:11 — list any pre-existing decisions
```

The user can resolve them in one pass.

## Token usage notes

INIT is the most expensive mode in this skill. It's also one-time. The cost is justified because:
- The codebase inventory pass is done once and produces the spine
- Every subsequent CONSULT/UPDATE benefits from accurate scaffolding
- Wrong scaffolding compounds; right scaffolding compounds more

Do not optimize for token count during INIT at the expense of accuracy. Use the read-then-ask rule rigorously. A confident wrong guess at INIT time costs more in future sessions than the question you avoided.

## What INIT does NOT do

- Does not generate doc content from imagination — use TODO markers when evidence is absent
- Does not pad templates with assumptions about the framework
- Does not create Tier 2/3 docs the user didn't agree to
- Does not run AUDIT or CONSULT checks during scaffolding
