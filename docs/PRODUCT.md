# PRODUCT.md

> What we're building, for whom, and what is explicitly NOT in scope.
> This is the canonical scope document. Agents must check here before adding features.

## Product

A stack-agnostic Markdown-based suite of AI coding assistant skills (`project-ninja`, `skill-ninja-logger`, `skill-ninja-review`) to keep AI-assisted coding sessions aligned, observant, and continuously improving.

## Target user

AI coding assistants (Claude Code, Antigravity, Cursor, Codex, Gemini CLI) and the software developers who pair-program with them.

## Anti-persona

- Developers looking for a black-box auto-coder that edits and commits code without human-in-the-loop review.
- Non-technical users looking for code-generation interfaces.

## Core value

Ensures code-to-documentation alignment to prevent architectural drift, while logging workflow friction to automatically evolve reusable agent skills under safe, quarantine-backed guardrails.

## In scope (current phase)

- **project-ninja:** Scaffolding the 16 canonical project files (like `AGENTS.md` and `docs/`) and routing precise context by task to save tokens.
- **skill-ninja-logger:** Appending friction observations to the global `~/.agents/skill-gaps.md` log.
- **skill-ninja-review:** Weekly review logic to group gap log entries, evaluate graduation thresholds, and generate new skills in a 7-day quarantine directory.

## Explicitly out of scope

- **Auto-execution of system scripts:** The skills must never execute arbitrary system commands or run code without the user's explicit approval.
- **Immediate promotion:** Bypassing the 7-day quarantine for auto-graduated skills is forbidden.
- **IDE integrations:** Building native VS Code or JetBrains extensions. The project is strictly standard-compliant markdown skills.

## Non-goals

- Not a build tool or test runner.
- Not a replacement for version control or CI/CD pipelines.

## Success criteria

- Complete initialization of Project Ninja across repositories.
- Zero architectural drift in projects using `project-ninja` in CONSULT/UPDATE modes.
- Reusable skills generated from recurring friction logs without polluting active skill directories.
