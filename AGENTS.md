# AGENTS.md

> Briefing packet for AI coding agents (Claude Code, Antigravity, Codex, Cursor, Gemini CLI, etc.).
> Humans should read README.md instead.

## Rules of engagement

These rules are the agent's first read every session. Keep this list short — 5–10 rules, each one absolute.

1. **Do** follow conventions documented in this file and the relevant `docs/` file. **Don't** invent new conventions silently.
2. **Do** check `docs/DECISIONS.md` before contradicting any documented pattern.
3. **Do** ask before expanding scope beyond `docs/PRODUCT.md`.
4. **Do** document all skill triggers in the frontmatter description of their respective `SKILL.md` files.
5. **Don't** edit templates in `project-ninja/templates/` unless intentionally modifying the scaffolds.
6. **Don't** edit files in the do-not-touch zones below.

## Stack

- Language(s): Markdown (with YAML frontmatter)
- Framework(s): Skill.md Open Standard
- Backend: None
- Database: None
- Hosting / runtime: AI coding agents (Claude Code, Antigravity, Cursor, Gemini CLI)
- Package/dependency manager: None
- Language version: N/A

## Commands

```bash
# Install skills locally (dev/testing)
mkdir -p ~/.agents/skills
cp -r project-ninja skill-ninja-logger skill-ninja-review ~/.agents/skills/

# Symlink skills for Claude Code
mkdir -p ~/.claude/skills
ln -s ~/.agents/skills/project-ninja ~/.claude/skills/
ln -s ~/.agents/skills/skill-ninja-logger ~/.claude/skills/
ln -s ~/.agents/skills/skill-ninja-review ~/.claude/skills/

# Symlink skills for Antigravity
mkdir -p ~/.gemini/antigravity/skills
ln -s ~/.agents/skills/project-ninja ~/.gemini/antigravity/skills/
ln -s ~/.agents/skills/skill-ninja-logger ~/.gemini/antigravity/skills/
ln -s ~/.agents/skills/skill-ninja-review ~/.gemini/antigravity/skills/

# Symlink skills for Codex
mkdir -p ~/.codex/skills
ln -s ~/.agents/skills/project-ninja ~/.codex/skills/
ln -s ~/.agents/skills/skill-ninja-logger ~/.codex/skills/
ln -s ~/.agents/skills/skill-ninja-review ~/.codex/skills/

# Symlink skills for Gemini CLI
mkdir -p ~/.gemini/skills
ln -s ~/.agents/skills/project-ninja ~/.gemini/skills/
ln -s ~/.agents/skills/skill-ninja-logger ~/.gemini/skills/
ln -s ~/.agents/skills/skill-ninja-review ~/.gemini/skills/
```

## Conventions

- **Frontmatter requirement:** Every `SKILL.md` file must have YAML frontmatter with `name` and `description` fields.
- **Trigger phrasing:** The `description` field in `SKILL.md` serves as both the summary and where trigger phrases live. The AI agent reads this to determine when to execute a skill.
- **Pointers:** `CLAUDE.md` and `GEMINI.md` at root are single-line pointers pointing directly to `AGENTS.md`.
- **Pure Markdown:** The repository has no build step and contains exclusively markdown documentation, procedures, templates, and instructions.
- **Scaffolding vs Docs:** Templates located in `project-ninja/templates/` are user-facing project scaffolds and should not be used as this project's documentation.

## Project-specific rules

- Every new skill folder must contain a `SKILL.md` file at its root specifying its behavior and trigger criteria.
- When generating/updating skills, adhere to the 7-day quarantine rule described in `docs/PRODUCT.md` and `skill-ninja-review/README.md`.

## Do-not-touch zones

- `.git/`
- `project-ninja/templates/` (unless intentionally modifying the project templates)

## Where to look

- Product scope: `docs/PRODUCT.md`
- Architecture overview: `docs/ARCHITECTURE.md`
- Settled decisions: `docs/DECISIONS.md`
