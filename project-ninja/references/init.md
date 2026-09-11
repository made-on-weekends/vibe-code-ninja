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

1. `.gitignore` — clean, tailored, noise-free ignore rules matching project stack and agent conventions without global rule bloat, consulting github/gitignore standards with engineering judgment (see .gitignore Generation & Clean Formatting Rules below).
2. `AGENTS.md` — populate from manifest scripts, observed framework versions, and one user interview question: "What's your one-line stack summary?"
3. `CLAUDE.md` — single line pointing at AGENTS.md
4. `GEMINI.md` — single line pointing at AGENTS.md
5. `README.md` — human quickstart, following the README Generation Rules below.
6. `docs/PRODUCT.md` — interview the user: "What does this product do, for whom, and what is explicitly NOT in scope?" Capture answers verbatim.
7. `docs/ARCHITECTURE.md` — diagram the layers: frontend, backend, DB, hosting. ASCII diagram is fine.
8. `docs/DECISIONS.md` — start with one entry: "0001 — Project initialized" — date, context, no actual decision yet, just the anchor.

### Step 4 — Ask before each Tier 2/3 file

Don't batch-create. For each, ask one at a time:

*"Should I scaffold `<file>` now? (yes if you have <criterion>)"*

- docs/API.md — ask if backend exists
- docs/DATABASE.md, docs/SCHEMA.md — ask if DB exists
- docs/COMPONENTS.md — ask if there's a component library
- docs/SECURITY.md — strongly recommended for any production app
- docs/TESTING.md — ask if non-default test strategy
- docs/DESIGN.md, docs/BRAND.md, docs/UX.md — only on explicit user request or when artifacts exist to capture

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

## .gitignore Generation & Clean Formatting Rules

Whenever creating, generating, or updating a project `.gitignore` (in INIT, UPDATE, or during doc maintenance):

### 1. Structure & Compact Categories
Keep the file concise, noise-free, and organized under clean section headers without decorative ASCII banners or unused stack boilerplate:

```gitignore
# Secrets & Environment
.env
.env.*
!.env.example
!.env.sample
!.env.template
*.env
*.pem
*.key
*client_secret*.json
*service-account*.json
id_rsa
id_dsa
id_ecdsa
id_ed25519

# Local AI Agents & IDE
.claude/settings.local.json
CLAUDE.local.md
GEMINI.local.md
.gemini/
.cursor/
.codegraph/
.idea/
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json

# Dependencies & Package Managers (adapt to stack)
# node_modules/, .venv/, vendor/, .pnpm-store/, etc.

# Build & Output (adapt to stack)
# dist/, build/, target/, .next/, out/, *.tsbuildinfo, etc.

# OS & Temporary Logs
*.log
.DS_Store
Thumbs.db
*.sw?
*~
```

### 2. Core Rules for `.gitignore`
- **Tailor to repo & consult github/gitignore:** Inspect detected languages, frameworks, package managers, and directories. Cross-reference standard templates at `https://github.com/github/gitignore` for accurate syntax.
- **Never blindly copy-paste:** Include only patterns relevant to the project's tools and outputs. Prune obsolete ecosystem bloat.
- **No global rule bloat:** Personal OS and developer environment noise belongs in `core.excludesFile` (`~/.gitignore_global`). Keep the repository `.gitignore` minimal and relevant.
- **Ask on ambiguity:** If unsure whether an output or generated folder is meant to be committed (e.g., compiled assets in a library vs web app, committed vendor directories, custom SQLite files), ask the user before writing.
- **Root-anchored project secrets:** Anchor paths (`/vault.txt`, `/hosts`, `/host_vars/*/vault.yml`) when intent is repository-root specific.
- **Selective coding agent ignore:** NEVER blanket-ignore shared coding agent folders (`.claude/`, `.cursor/rules/`, `CLAUDE.md`, `GEMINI.md`, `AGENTS.md`). Selectively ignore local execution state, permission overrides, and chat history (`.claude/settings.local.json`, `CLAUDE.local.md`, `GEMINI.local.md`, `.gemini/`, `.cursor/`, `.codegraph/`, `.aider*`, `.specstory/`).
- **Preserve templates and lockfiles:** Always keep template configurations tracked (`!.env.example`, `!.env.sample`, `!.env.template`, `hosts.example`) and never ignore package lockfiles (`package-lock.json`, `pnpm-lock.yaml`, `Cargo.lock`, `go.sum`, `poetry.lock`, etc.).
- **Precise globs:** Avoid greedy globs (`.env*`, `id_*`). Use precise globs (`.env`, `.env.*`, `*.env`, explicit key names).

## README Generation & Update Rules

Whenever creating, generating, or updating a project `README.md` (in INIT, UPDATE, or during doc maintenance):

### 1. General README Principles
- **Preserve existing content and tone:** Do not discard established project context or stylistic voice.
- **Canonical section order:** Include the conditional sections in this relative order, normally placed toward the end of the README:
  1. `## 📚 Documentation`
  2. `## 🐛 Issues & Troubleshooting`
  3. `## 🤝 Contributing`
  4. `## ⭐ Support Us`
  5. `## 📄 License`
- **Update equivalent existing sections:** Update or merge into existing sections instead of creating duplicate blocks.
- **Evidence-backed inclusion:** Include a section or bullet only when it is relevant and supported by actual project information. Omit unsupported sections.
- **Path & casing verification:** Verify that linked files exist on disk and use correct relative paths (e.g. relative to the README file) with exact filename casing.
- **Established doc locations:** Use the project's actual documentation paths (e.g., root `SECURITY.md` vs `docs/SECURITY.md`, shared context repositories). Do not assume everything is under `docs/`.
- **No empty filler docs:** Do not create empty documentation or license files merely to satisfy template links.
- **Accurate descriptions:** Adapt item descriptions to the actual contents of the linked document; do not claim it covers topics it does not.
- **Resolve placeholders:** Resolve all placeholders (e.g. `%product_name%`, `%donation_link%`) before writing. If optional info is unavailable, omit the affected item and report the omission.
- **Never invent details:** Never invent URLs, policies, features, support commitments, or license terms.

### 2. Conditional Section Specifications

#### 📚 Documentation
- **Suggested introduction:**
  `For technical details, project guidelines, and development context:`
- **Relevant entries (adapt paths and descriptions based on existing files):**
  - 🤖 **For AI Coding Agents:** Refer to [AGENTS.md](AGENTS.md) for development commands, project conventions, and agent instructions.
  - 🏗️ **Architecture:** See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the system structure, major components, and data flows.
  - ⚖️ **Decision Log:** See [docs/DECISIONS.md](docs/DECISIONS.md) for architectural decisions, rationale, and established conventions.
  - 🎯 **Product Scope:** See [docs/PRODUCT.md](docs/PRODUCT.md) for product goals, supported features, and planned work.
  - 🛡️ **Security Guidelines:** See [docs/SECURITY.md](docs/SECURITY.md) for security practices and configuration guidance. *(Use actual location, e.g. root `SECURITY.md`)*
  - 🧪 **Testing Strategy:** See [docs/TESTING.md](docs/TESTING.md) for test coverage, commands, and verification procedures.
- Add other useful existing project doc links as appropriate.
- **Omission:** Omit this section entirely if no verified, useful documentation links exist.

#### 🐛 Issues & Troubleshooting
- **Suggested opening:**
  `Found a bug or have a feature request?`
- Link to an existing troubleshooting guide, FAQ, or known-issues document when available.
- If `REPORTING.md` or an equivalent guide exists, include:
  `Read the [Issue Reporting Guide](REPORTING.md) before submitting an issue.`
- Link to the verified issue tracker when available and appropriate.
- Follow any existing private vulnerability-reporting policy; never direct security reports to public issue trackers.
- Do not present `AGENTS.md` as user-facing troubleshooting guidance unless it actually contains relevant troubleshooting instructions.
- **Omission:** Omit unsupported bullets and omit the section entirely if no verified reporting or troubleshooting information is available.

#### 🤝 Contributing
- Include when the project welcomes contributions or has a documented contribution workflow.
- **Preferred copy when a guide exists:**
  `Contributions are welcome! Read the [Contribution Guide](CONTRIBUTING.md) for development setup, contribution conventions, and the pull request process.`
- Adapt text to the actual guide name/location. Do not imply private or closed-source projects accept public contributions.
- **Omission:** Omit if private/closed-source or no public contribution workflow exists.

#### ⭐ Support Us
- Include for public projects where community support is appropriate, or when explicitly requested.
- **Preferred copy:**
  ```markdown
  If %product_name% is useful to you:
  - ⭐ **Star this repository** to help others discover the project.
  - 📣 **Spread the word** by sharing it with your network.
  - ☕ **Support Our Work** — [Donate](%donation_link%) to help us maintain and grow our open-source projects.
  ```
- **Rules:**
  - Replace `%product_name%` with the verified project name.
  - Use a donation URL only when provided by the user or found in trusted project/owner configuration (preserving any tracking parameters such as UTM tags).
  - Omit the donation bullet if no verified donation URL is available.
  - Use open-source funding wording only for an actual open-source project.
  - Do not reuse product-specific claims across unrelated projects.
  - Respect existing sponsorship preferences and avoid duplicate funding sections.

#### 📄 License
- Determine licensing strictly from the repository's license files and explicit project configuration.
- Prefer linking to the actual repository license file (e.g. `[MIT License](LICENSE)`).
- **Preferred copy for verified MIT with root LICENSE:**
  `This project is licensed under the [MIT License](LICENSE).`
- Adapt wording for other licenses (Apache-2.0, BSD, GPL, Proprietary, etc.) or dual-licensing terms.
- Do not use a generic license-information website as a substitute for the project's repository license.
- Never add or change a license as part of README generation.
- If licensing is missing or conflicting, do not assert a license. Report the unresolved status in the completion summary.

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
