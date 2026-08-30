# CONSULT Mode Procedure

Loaded before any non-trivial code change. This is the most-invoked mode and the one where token efficiency matters most.

## What counts as "non-trivial"

Run CONSULT if any of these apply:
- Adding or removing a named export, route, page, component file, table, column, env var, or third-party dependency
- Changing a public API shape (request/response, function signature visible across modules)
- Adding new user-facing behavior

If the change is purely internal (rename a local variable, fix a typo, reformat) → skip CONSULT entirely. Just do it.

## Procedure

### Step 1 — Identify task type and route

Read `references/routing.md`. Match the user's request to one row in the routing tables. Note the docs (and section anchors) listed in the `Load` column.

If multiple rows match, pick the narrowest set. If no row matches, ask the user: *"For this task, I think I need to consult <X> and <Y> — anything else you think is relevant?"* One question beats six unnecessary doc loads.

### Step 2 — Load only the routed sections

For each doc in the `Load` column:
- If the routing table specified an anchor (e.g., `COMPONENTS.md#base-components`), read only that section
- If no anchor was specified, read the doc's table of contents first, then load only the section relevant to the task
- Never load the full doc unless the routing table explicitly says so

If you can't name which section of a loaded doc will inform the current task, you shouldn't have loaded it.

### Step 3 — Run anti-drift checks

Run these in order. Do not skip the procedure in favor of a gut-check.

**A. Scope check (against PRODUCT.md):**
- Read PRODUCT.md's `In scope` and `Out of scope` sections explicitly.
- For each user-facing capability the request implies (a new page, a new field, a new notification, a new permission), check whether it appears in `In scope`.
- If the capability is not listed in `In scope`, treat it as scope expansion regardless of how minor it sounds. Surface verbatim:
  > *"This looks like it expands scope beyond PRODUCT.md. Specifically: <what's new>. Confirm before I proceed; if yes, we update PRODUCT.md as part of this change."*

**B. Hard rules check (SECURITY.md, when relevant):**
- If the task touches auth, data, input handling, or any security-relevant area, read SECURITY.md's Hard Rules block.
- If the proposed approach violates any hard rule, STOP. A hard rule cannot be violated without a DECISIONS.md entry that supersedes it.

**C. Decision check (DECISIONS.md):**
- Scan `Status: Accepted` entries for keyword overlap with the change area (e.g., "auth", "Pinia", "schema", the relevant table or component name).
- For each match, read the entry in full.
- If the proposed approach contradicts the decision's `Decision` field, surface:
  > *"DECISIONS.md #<N> (<date>) decided <X>. The approach I had in mind contradicts it. Two options: (a) follow the existing decision, (b) supersede #<N> with a new entry. Which?"*

**D. Deletion check (when removing a non-trivial code unit):**
- Define non-trivial: any named export, route, page, component file, table, column, env var, or third-party dependency.
- Grep all `.md` files in the repo for the name being removed. Also grep test files.
- For each match, surface:
  > *"`<X>` is referenced in `<file>:<line>`. Removing it will leave the reference stale. Confirm and I'll update both, or I'll leave the code."*

These four checks are why CONSULT exists. Do not skip them, and do not approximate them.

### Step 4 — Proceed with code

Now write/modify code. The docs gave you scope + conventions + decisions. Apply them.

### Step 5 — Note pending updates (do NOT update yet)

As you work, mentally note any doc that will need updating in UPDATE mode. **Do not update docs in CONSULT mode.** CONSULT only reads. Updates happen after the change is real.

## When to read `references/anti-drift.md`

Most CONSULT sessions don't need it. Read it when:
- An anti-drift check surfaces something ambiguous and you need the deeper pattern
- The user asks about a drift type by name
- You're investigating recurring drift in a project (this is closer to AUDIT territory)

For 90% of CONSULT sessions, the four checks above are sufficient.

## Token usage notes

A typical CONSULT session loads:
- This file (consult.md): ~80 lines
- routing.md: ~100 lines (skim, jump to matching section)
- 1–3 docs, only the relevant section of each

Total: usually 200–400 lines of doc content per session. Compared to v3 which loaded SKILL.md (~200 lines) + potentially full docs, this is roughly 30–50% of the cost.

If you find yourself loading more than 3 docs, stop and re-check the routing table. The right answer is almost always 1–3.

## What CONSULT does NOT do

- Does not modify any docs (UPDATE does that, after the change ships)
- Does not run AUDIT-style sampling
- Does not load templates
- Does not pre-load other reference files "in case they're needed"
