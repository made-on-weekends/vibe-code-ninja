# .gitignore Policy and Procedure

Comprehensive guide for generating, revising, auditing, and maintaining repository `.gitignore` files that fit the project cleanly and adhere to industry best practices.

## Contents
1. Core Principles & Philosophy
2. Stack Detection & Checking `github/gitignore` References
3. Clean Formatting & Structural Hierarchy
4. Generating a New `.gitignore` (INIT)
5. Revising & Updating an Existing `.gitignore` (UPDATE)
6. Decision Rules & User Clarification Protocol
7. Reading the Audit Report
8. Anti-Patterns to Avoid
9. Engine & Managed Blocks Integration (`scripts/gitignore-ninja.sh`)

---

## 1. Core Principles & Philosophy

- **Tailored to the repository:** The `.gitignore` must fit the actual technologies, frameworks, package managers, and build pipelines present in the repository. Avoid dumping irrelevant rules for unrepresented ecosystems.
- **Do not overwhelm with global rules:** Personal developer environment noise (e.g., specific OS desktop database files, personal editor plugins, niche terminal artifacts) belongs in each developer's global exclude file (`~/.gitignore_global` via `git config --global core.excludesFile ~/.gitignore_global`). The repository `.gitignore` should only carry a small, essential safety net (`.DS_Store`, `Thumbs.db`, `*.log`, `*.sw?`, `*~`), not pages of generic OS/IDE trivia.
- **Consult standard templates without blind copy-pasting:** Reference official community standards from [github/gitignore](https://github.com/github/gitignore) for detected technologies (Node, Python, Go, Rust, Java, C/C++, Swift, Flutter, PHP, Ruby, Terraform, etc.). Do **not** blindly copy-paste hundreds of lines of template boilerplate. Use engineering knowledge and repository inspection to curate only the rules that apply.
- **Ask the user in case of confusion:** When faced with ambiguous project artifacts, trade-offs (e.g. committing `dist/` or `vendor/`, custom local sqlite databases, private test fixture files), or conflicting stack indicators, ask the user for clarification rather than making a speculative assumption.
- **Protect secrets & agent local state:** Secrets, API credentials, private keys, and local AI agent execution/memory states must be strictly ignored.
- **Never ignore what must be shared:** Shared team documentation (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`), shared coding agent rules (`.claude/rules/`, `.cursor/rules/`, `.github/copilot-instructions.md`), package lockfiles (`package-lock.json`, `pnpm-lock.yaml`, `Cargo.lock`, `go.sum`, `poetry.lock`, etc.), and environment templates (`.env.example`) must remain tracked.
- **Human approval before modifications:** Propose `.gitignore` changes and untracking commands clearly, and obtain explicit user confirmation before applying.

---

## 2. Stack Detection & Checking `github/gitignore` References

When creating or revising a `.gitignore`, inspect the repository for manifest files, compiler outputs, and framework indicators, then cross-reference recommended rules from [github/gitignore](https://github.com/github/gitignore):

| Technology / Ecosystem | Detection Indicators | Standard Ignore Focus (from github/gitignore) | Rules to Prune / Avoid Copying |
|---|---|---|---|
| **Node.js / TypeScript** | `package.json`, `tsconfig.json` | `node_modules/`, `dist/`, `build/`, `.npm/`, `*.tsbuildinfo`, `.eslintcache` | Obsolete bundler caches, editor bloat |
| **Next.js** | `next.config.*` | `.next/`, `out/`, `next-env.d.ts` (if generated) | Redundant OS rules |
| **Python** | `pyproject.toml`, `requirements*.txt`, `setup.py`, `.venv` | `__pycache__/`, `*.py[cod]`, `.venv/`, `dist/`, `build/`, `*.egg-info/`, `.pytest_cache/`, `.ruff_cache/`, `.mypy_cache/` | Legacy toolchains (e.g. buildout, nose) not in use |
| **Rust** | `Cargo.toml` | `/target/`, `Cargo.lock` (ignore only for libraries if specified, but **keep committed for binaries/applications**) | Cross-compiler artifacts unless present |
| **Go** | `go.mod` | `/bin/`, `*.exe`, `*.test`, `vendor/` (unless using `-mod=vendor`), `/cover.out` | Broad OS patterns |
| **Java / Kotlin / JVM** | `pom.xml`, `build.gradle*` | `/target/`, `.gradle/`, `build/`, `out/`, `*.class`, `*.jar` (except wrapper jar) | 50+ lines of old IDE metadata |
| **Flutter / Dart** | `pubspec.yaml` | `.dart_tool/`, `build/`, `.flutter-plugins*`, `.packages` | User-level Dart VM files |
| **C / C++** | `CMakeLists.txt`, `Makefile`, `meson.build` | `*.o`, `*.obj`, `*.so`, `*.dylib`, `*.a`, `*.dll`, `build/`, `cmake-build-*/` | Generic IDE bloat |
| **PHP / WordPress** | `composer.json`, `wp-config.php` | `vendor/` (unless committed), `*.log`, `wp-config.php` (for WP core repos) | Legacy SVN metadata |
| **Ruby** | `Gemfile` | `/vendor/bundle`, `/bundle/`, `pkg/`, `tmp/` | Obsolete documentation caches |
| **Terraform** | `*.tf`, `.terraform.lock.hcl` | `.terraform/`, `*.tfstate`, `*.tfstate.*`, `*.tfvars`, `*.tfvars.json` | Must keep `.terraform.lock.hcl` |
| **Docker / Cloud** | `Dockerfile`, `compose.yaml`, `wrangler.toml` | `.dev.vars`, `.dockerignore` leftovers, `.terraform/` | Shared compose templates |

---

## 3. Clean Formatting & Structural Hierarchy

A clean `.gitignore` is structured into clear, readable categories using standard comment headers without ASCII art:

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

# Dependencies & Package Managers
node_modules/
.pnpm-store/
.venv/
vendor/

# Build & Output
dist/
build/
target/
*.tsbuildinfo
coverage/

# OS & Temporary Logs
*.log
.DS_Store
Thumbs.db
*.sw?
*~
```

### Formatting Best Practices
1. **Precise globs over greedy matches:**
   - Use `.env`, `.env.*`, `*.env` with explicit negation (`!.env.example`) instead of `.env*` (which accidentally ignores `.envrc`, `.environment`, `.envoy`).
   - Use explicit SSH key filenames (`id_rsa`, `id_ed25519`) instead of `id_*` (which accidentally ignores `id_mapping.json`).
2. **Anchor root-specific sensitive files:**
   - Use `/vault.txt`, `/hosts`, `/private_keys/` when rules apply strictly to the repository root.
3. **Keep package lockfiles tracked:**
   - Never ignore `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `Cargo.lock`, `go.sum`, `poetry.lock`, `uv.lock`, `composer.lock`, `Gemfile.lock`, or `.terraform.lock.hcl`.

---

## 4. Generating a New `.gitignore` (INIT)

When initializing or generating a `.gitignore` for a project:

1. **Inspect the workspace:**
   - Check directory listing, package manifests, build configuration, compiler targets, and local data folders.
2. **Determine applicable stacks:**
   - Identify active languages, frameworks, and deployment targets.
3. **Reference github/gitignore patterns:**
   - Consult relevant `.gitignore` templates from `https://github.com/github/gitignore`.
4. **Exercise engineering judgment:**
   - Include necessary build outputs (`dist/`, `build/`, `.next/`, `target/`), dependencies (`node_modules/`, `.venv/`), and test/coverage caches.
   - Omit generic bloat and unneeded global rules.
5. **Ask on ambiguity:**
   - If unsure whether an output directory or generated configuration is meant to be committed (e.g., compiled assets in a library repo vs web app), ask the user.
6. **Propose & Confirm:**
   - Show the proposed `.gitignore` content to the user for approval before writing.

---

## 5. Revising & Updating an Existing `.gitignore` (UPDATE)

When revising an existing `.gitignore`:

1. **Read the current `.gitignore`:**
   - Identify existing rules, section structure, and custom project entries.
2. **Detect drift & gaps:**
   - Check if newly introduced technologies or tools (e.g. added Next.js, added Python scripts, added Terraform) are missing ignore rules.
   - Check if greedy globs (`.env*`, `id_*`) or missing secret rules exist.
   - Check if local agent state (`.claude/settings.local.json`, `CLAUDE.local.md`, `GEMINI.local.md`, `.gemini/`, `.cursor/`, `.codegraph/`) is properly ignored.
   - Check if shared assets or lockfiles are accidentally ignored.
3. **Clean up bloat & duplicates:**
   - Consolidate duplicate entries.
   - Remove irrelevant global noise or dead ecosystem boilerplate.
4. **Preserve custom project rules:**
   - Always preserve intentional, project-specific rules, exceptions, and re-inclusions.
5. **Propose the diff:**
   - Show a clear `diff -u` of current vs proposed `.gitignore`.
   - List any tracked files that will be ignored and provide the corresponding `git rm --cached` commands.
   - Wait for human approval before applying changes.

---

## 6. Decision Rules & User Clarification Protocol

Apply the **Read-Then-Ask** rule before changing or adding controversial rules:

| Situation | Action / User Question |
|---|---|
| **Committed `vendor/` or `dist/`** | If `vendor/` or `dist/` is currently tracked, ask: *"I noticed `dist/` (or `vendor/`) is tracked in git. Is this deliberate (e.g. for release artifact distribution), or should we ignore and untrack it?"* |
| **Multiple conflicting lockfiles** | If both `package-lock.json` and `pnpm-lock.yaml` exist, ask: *"Both npm and pnpm lockfiles are present. Which package manager is canonical for this project?"* |
| **Local SQLite / Database files** | If `*.db` or `*.sqlite3` exists in repo, ask: *"Found `data.sqlite3`. Is this local development test data (to be ignored) or a seeded starter database (to be tracked)?"* |
| **Shared vs Private Agent/IDE settings** | If `.vscode/` or `.idea/` has files, keep team configs (`settings.json`, `launch.json`) committed and ignore user state (`workspace.xml`, `*.local.json`). If in doubt, ask: *"Should team VS Code settings be shared in the repo?"* |
| **Secrets or leaked credentials found** | Inform the user immediately: *"A sensitive secret pattern was found in `<path>`. Please rotate/revoke this credential first. I will add it to `.gitignore` and propose untracking it with `git rm --cached`."* (Never attempt history rewriting without explicit instruction). |

---

## 7. Reading the Audit Report

When running audit checks on `.gitignore` (via `scripts/gitignore-ninja.sh audit` or manual inspection):

- **MUST fix before next push:** Secrets tracked (`secret`), shared files or lockfiles ignored, active credentials in content, secrets in commit history.
- **SHOULD fix:** Agent-local files tracked (`agent-local`), literal tokens in configuration, stale/missing blocks, untracked lockfiles.
- **INFO:** Duplicate rules, agent-local files in past history, missing secret scanning tooling.

Row labels when classifying tracked files:
- `secret`: Untrack after approval; credential rotation required.
- `agent-local`: Untrack after approval.
- `KEEP`: Never untrack (shared file, lockfile, or submodule); fix the ignore rule instead.
- `REVIEW`: Editor or MCP config. Confirm whether team-shared and secret-free.
- `other`: Build output or temp cache; untrack after approval.

---

## 8. Anti-Patterns to Avoid

- ❌ **Blind copy-pasting:** Dumping 200+ lines from random gitignore templates without verifying relevance to the project.
- ❌ **Overwhelming with global rules:** Adding dozens of lines for Windows/macOS/Linux utility caches or personal text editors that belong in `core.excludesFile`.
- ❌ **Greedy wildcards:** Using `.env*` or `id_*` that cause false-positive ignores on valid project files.
- ❌ **Blanket agent folder ignores:** Ignoring `.claude/`, `.cursor/`, or `.gemini/` entirely, which breaks team-shared prompts, skills, and rule definitions.
- ❌ **Ignoring lockfiles:** Adding `package-lock.json`, `Cargo.lock`, or `poetry.lock` to `.gitignore`.
- ❌ **Silently modifying without diff approval:** Applying edits or running untracking commands without presenting the diff to the user.

---

## 9. Engine & Managed Blocks Integration (`scripts/gitignore-ninja.sh`)

For repositories utilizing Project Ninja's managed blocks engine:

- Managed blocks use markers: `# >>> project-ninja:<stack> v... >>>` and `# <<< project-ninja:<stack> <<<`.
- Run commands from repo root:
  - `gitignore-ninja.sh audit` — Full read-only health check and diff generation.
  - `gitignore-ninja.sh render` — Preview proposed rules.
  - `gitignore-ninja.sh blocks` — Check status (`OK`, `STALE`, `MISSING`, `EXTRA`).
  - `gitignore-ninja.sh apply --yes` — Write proposed rules after human approval (backs up to `.git/project-ninja/`).
- Project-specific rules placed at the bottom below the user separator `# ---- Project-specific rules below ... ----` are always preserved and take precedence.
