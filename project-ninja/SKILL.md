---
name: project-ninja
description: Maintain alignment between code and project documentation across AGENTS.md, CLAUDE.md, GEMINI.md, README.md, and the docs/ folder (PRODUCT, ARCHITECTURE, API, DATABASE, SCHEMA, DESIGN, BRAND, UX, COMPONENTS, DECISIONS, SECURITY, TESTING). Stack-agnostic. Use at session start for token-efficient routing, before feature changes to prevent scope drift, and after merges to update docs. Also generates, revises, and audits repository .gitignore files tailored to the repo without global rule bloat, consulting https://github.com/github/gitignore best practices with engineering judgment. Trigger on align, drift, scope, documentation, project setup, init, update docs, refactor, feature add/remove, "is this in scope", "did we decide", "what's the convention", deleting code, gitignore, "generate gitignore", "update gitignore", "what shouldn't be committed", leaked keys, or agent files (.claude, .cursor, .aider, .specstory) in git.
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

## .gitignore hygiene (runs in init, audit, update, or standalone gitignore tasks)

Every Project Ninja mode includes a gitignore pass. The pass generates or revises `.gitignore` so it fits the repo precisely:

- **Tailor to repo:** Detect actual languages, frameworks, package managers, and build directories.
- **No global rule bloat:** Do not overwhelm the repo `.gitignore` with personal OS/editor rules. Personal developer environment noise belongs in `core.excludesFile` (`~/.gitignore_global`). Keep repo rules concise and relevant.
- **Reference tech best practices:** Check standard templates at `https://github.com/github/gitignore` for detected technologies without blindly copy-pasting hundreds of lines.
- **Judgment & User Confirmation:** Use codebase inspection and engineering judgment to include only relevant patterns. If ambiguous (e.g. whether `dist/` or `vendor/` is tracked for a package vs ignored for an app, or conflicting stacks), ask the user for clarification.

Before the first gitignore step in a session, read
`references/gitignore-policy.md`. Read `references/agent-files.md` when
classifying an agent file, or when running update mode.

Engine (read-only except `apply`), run from the repo root:
`S="<skill-dir>/scripts/gitignore-ninja.sh"`, where `<skill-dir>` is the
directory containing this SKILL.md (for example `~/.agents/skills/project-ninja`).
Resolve it to an absolute path. Never assume a vendor-specific skills path.

| Mode | Gitignore step |
|---|---|
| init | `$S audit`, then Gate A, `$S apply --yes`, Gate B, verify, re-audit |
| audit | `$S audit` only. Change nothing. |
| update | `$S blocks`, re-verify the agent catalog if web is available, then the init flow |

Non-negotiables:
- **Gate A:** show the section [4] diff and wait for explicit approval
  before `apply --yes`.
- **Gate B:** list the `git rm --cached` commands from section [5] and run
  only the approved ones. Never untrack rows marked KEEP. Ask about rows
  marked REVIEW.
- **Secrets:** tell the user to rotate first. Never rewrite history from
  this skill. Never commit. End with `git status --short` and a suggested
  commit message.
- **Reporting:** paste the audit sections verbatim. After them, list
  findings grouped MUST, SHOULD, INFO, each citing its section number.
  Quote the script's COUNTS line; don't recount.
- **Fragment changes** go to the skill's `assets/gitignore/` with a VERSION
  bump, never ad hoc into one project's managed blocks.

## Token-waste prevention rules (binding, all modes)

These rules govern every action this skill takes. Violating them is the failure mode this skill exists to prevent.

1. **Routing is mandatory in CONSULT mode.** Read `references/routing.md` and load only the docs whose triggers match the task — never all docs "to be safe."
2. **Read only the section pointed to by the routing table.** If the routing entry says `COMPONENTS.md#base-components`, read only that section. If you can't name which section a doc's content will inform the current task, you shouldn't have loaded it.
3. **Never read a doc you're not going to act on.** Loading PRODUCT.md commits you to running the scope check. Otherwise skip the load.
4. **Never regenerate a doc from scratch when a surgical edit will do.** Surgical = modify only the specific sentences/rows/code-blocks whose facts changed. No "while I'm here" cleanup.
5. **Never create empty/stub docs to "fill out the structure".** Empty docs teach false confidence. Use TODO markers instead.
6. **Never duplicate content across docs.** `references/cross-references.md` is the ownership table — every topic has exactly one owner.
7. **CLAUDE.md and GEMINI.md are pointers.** One line, pointing at AGENTS.md. Never let them grow.
8. **If unsure whether to update a doc or gitignore rule, ask one question rather than write a guessing update.**
9. **DESIGN.md must follow the Google Labs format.** Any edits to `docs/DESIGN.md` or its derived/override mirrors must comply with the Google Labs `design.md` specification (combining YAML frontmatter with standard sections), and should be verified using `npx @google/design.md lint <filepath>`.
10. **README.md generation and updates must follow the canonical section order and verification rules.** Always preserve existing content and tone, update equivalent sections instead of duplicating, verify relative links and exact casing, resolve all placeholders or omit optional items and report omission, and never invent URLs, licenses, or commitments.
11. **.gitignore files must be concise, clean, tailored, and noise-free.** Group into simple, compact section headers (`# Secrets & Environment`, `# Local AI Agents & IDE`, `# Dependencies & Package Managers`, `# Build & Output`, `# OS & Temporary Logs`, plus stack-specific headers). Do not add noisy ASCII banners or unneeded generic ecosystem bloat. Do not overwhelm with global OS/editor rules. Never blanket-ignore shared coding agent folders (`.claude/`, `.cursor/rules/`); selectively ignore personal agent/IDE state (`.claude/settings.local.json`, `CLAUDE.local.md`, `GEMINI.local.md`, `.gemini/`, `.cursor/`, `.codegraph/`).
12. **Avoid greedy globs and blind copy-pasting in .gitignore.** Do not copy-paste hundreds of lines from template repositories. Use knowledge to select rules that fit the repository. Avoid greedy patterns like `.env*` (matches `.envrc`, `.environment`, `.envoy`) or `id_*` (matches `id_mapping.json`, `id_config.yaml`). For environment files, use three precise patterns: `.env`, `.env.*`, `*.env` with negations for templates (`!.env.example`, `!.env.sample`, `!.env.template`). For SSH keys, list explicit names (`id_rsa`, `id_dsa`, `id_ecdsa`, `id_ed25519`). Always verify new glob patterns with `git check-ignore -v --non-matching` against edge cases before committing.

## The canonical doc set

```
/
├── .gitignore         # clean, noise-free ignore rules
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

- `references/init.md` — INIT procedure (one-time scaffold) & README generation rules
- `references/consult.md` — CONSULT procedure (anti-drift checks before code)
- `references/update.md` — UPDATE procedure (surgical edits after a change)
- `references/audit.md` — AUDIT procedure (drift check, read-only)
- `references/gitignore-policy.md` — .gitignore policy and rules (loaded for gitignore hygiene in INIT, UPDATE, AUDIT)
- `references/agent-files.md` — catalog of agent files and classification (loaded for agent file hygiene)
- `references/routing.md` — task → doc mapping (loaded by CONSULT and UPDATE)
- `references/cross-references.md` — ownership table (loaded by INIT and UPDATE)
- `references/anti-drift.md` — drift-detection patterns (deeper detail for CONSULT)
- `references/workflows.md` — extended procedures (rarely needed; references above are usually sufficient)

Templates live in `templates/` and are loaded only by INIT.
