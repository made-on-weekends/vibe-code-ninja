# AGENTS.md

> Briefing packet for AI coding agents (Claude Code, Antigravity, Codex, Cursor, Gemini CLI, etc.).
> Humans should read README.md instead.

## Rules of engagement

These rules are the agent's first read every session. Keep this list short — 5–10 rules, each one absolute.

1. **Do** follow conventions documented in this file and the relevant `docs/` file. **Don't** invent new conventions silently.
2. **Do** check `docs/DECISIONS.md` before contradicting any documented pattern.
3. **Do** read `docs/SECURITY.md` Hard Rules before touching auth, data handling, or any input-validation code.
4. **Do** ask before expanding scope beyond `docs/PRODUCT.md`.
5. **Don't** edit files in the do-not-touch zones below.
6. **Don't** edit migrations that have already been applied to any environment — always add a new one.
7. **Don't** introduce a new third-party dependency without a `docs/DECISIONS.md` entry.
8. TODO(<owner>): add project-specific absolute rules. Examples: "Don't import from `lib/internal/*` outside its module", "Always run `pnpm typecheck` before claiming code is complete."

## Stack

- Language(s): TODO(<owner>)
- Framework(s): TODO(<owner>)
- Backend: TODO(<owner>)
- Database: TODO(<owner>)
- Hosting / runtime: TODO(<owner>)
- Package/dependency manager: TODO(<owner>) — pin one, agents guess wrong
- Language version: TODO(<owner>) — match what's pinned in your manifest

## Commands

```bash
# TODO(<owner>): replace with actual commands for this project
# Examples below — adjust to your stack.

# Dev / run
TODO(<owner>): dev command

# Build
TODO(<owner>): build command

# Type check (if applicable)
TODO(<owner>): typecheck command

# Lint / format
TODO(<owner>): lint command

# Test
TODO(<owner>): test command

# DB migrations (if applicable)
TODO(<owner>): migrate command
```

## Conventions

TODO(<owner>): Project-specific conventions. Examples:

- File naming and casing rules
- Module/import conventions
- Type-strictness expectations
- Error-handling pattern (return errors vs throw)
- Logging conventions
- Where state lives (in-memory, store, DB)
- Where shared utilities live

One real code snippet beats three paragraphs of description:

```
TODO(<owner>): paste a representative example of your component, function, or API pattern
```

## Project-specific rules

TODO(<owner>): The counterintuitive ones an agent will get wrong if not told. Examples:

- "All API errors are returned in the response body, never thrown."
- "Database access goes through `lib/db.<ext>` — do not import the driver directly."
- "All user input is validated at the trust boundary, not deeper."

## Do-not-touch zones

- TODO(<owner>): list paths/files that should never be edited
- Common examples to consider:
  - `node_modules/`, `vendor/`, `.venv/`, build output directories
  - Generated files (e.g., schema-generated types)
  - Migration files (only add new ones, never edit existing)
  - `.env*` files (use `.env.example` as the source of truth)
  - Lock files (regenerate via package manager, never edit by hand)

## Where to look

- Architecture overview: `docs/ARCHITECTURE.md`
- Settled decisions: `docs/DECISIONS.md` (read before contradicting any pattern)
- Security rules: `docs/SECURITY.md` (Hard Rules at top)
- API contract: `docs/API.md`
- Schema: `docs/SCHEMA.md`
- Test strategy: `docs/TESTING.md`

## Project-specific routing

TODO(<owner>): If your stack has signals beyond the defaults in project-ninja's routing table, add them here. Example:

```
| User intent / signal              | Load                                       |
|-----------------------------------|--------------------------------------------|
| "Add background job"              | ARCHITECTURE (jobs section), DATABASE      |
| "Add LLM agent capability"        | ARCHITECTURE, SECURITY (prompt injection)  |
```

## Pull request expectations

TODO(<owner>): Add commit/PR conventions if any. Otherwise delete this section.
