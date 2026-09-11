# Coding agent files: ignore, commit, or review

Catalog used by the `agents` fragment (`assets/gitignore/agents.gitignore`).
Read this when classifying an agent file the audit flagged, or when the
update mode re-verifies the fragment.

Last verified: 2026-09-11. "Verified" means checked against the vendor's docs,
repo, or issue tracker on that date. "Not re-verified" entries come from prior
knowledge. Confirm them against vendor docs before changing the fragment.

## The rule behind every row

Commit what makes the agent behave the same for every collaborator:
instructions, rules, skills, commands, subagents, shared settings, and MCP
server definitions that reference secrets through environment variables.

Ignore what is personal, machine-specific, or a transcript: local overrides,
chat or input history, session databases, plan scratch, caches, and worktrees.

Review anything that can hold a literal credential, such as MCP configs and
agent config files with API keys. The fix is usually to switch the value to an
env-var reference and keep the file committed. Only untrack the file when the
tool cannot reference env vars.

Most agents keep transcripts outside the repo in the user's home directory.
The in-repo risk is concentrated in a few tools (Aider, SpecStory, Crush,
OpenCode plans) and in local-override files.

## Verified

| Agent | Ignore (in fragment) | Commit | Review |
|---|---|---|---|
| Claude Code | `**/.claude/settings.local.json`, `**/CLAUDE.local.md`, `**/.claude/agent-memory-local/`, `**/.claude/worktrees/` | `CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/settings.json`, `.claude/{rules,skills,commands,agents,output-styles,workflows}/`, `.mcp.json`, `.worktreeinclude` | `.claude/agent-memory/` is subagent-written and team-shared by design, so confirm the team wants it. `.mcp.json` must use `${VAR}` for secrets. |
| Gemini CLI | `**/.gemini/.env`, `.gemini-clipboard/` | `GEMINI.md`, `.gemini/settings.json`, `.gemini/commands/`, `.gemini/skills/`, `.geminiignore` | `.gemini/settings.json` supports `$VAR`/`${VAR}`, so flag literal keys. |
| OpenAI Codex CLI | nothing in-repo by default | `AGENTS.md`, `.codex/config.toml` (loaded only for trusted projects) | `.codex/config.toml` MCP entries with literal tokens. There is no official gitignored local-override layer yet (open feature request), so don't invent one. |
| Aider | `.aider.chat.history.md`, `.aider.input.history`, `.aider.llm.history`, `.aider.tags.cache.v*/` | `.aiderignore`, conventions files | `.aider.conf.yml` can hold API keys, so prefer `.env` plus env vars and then commit. |
| OpenCode | `**/.opencode/plans/`, `**/.opencode/node_modules/` | `opencode.json(c)`, `.opencode/{agent,agents,command,commands}/` | `opencode.json` literal keys; it supports `{env:VAR}`. |
| Crush | `.crush/` (session DB, logs) | `crush.json` / `.crush.json`, `.crushignore` | literal keys in `crush.json`. |
| Google Antigravity (verified via Google DevRel testing, Aug 2026) | nothing in-repo; state, artifacts and caches live under `~/.gemini/` | `.agents/{rules,workflows,skills,agents,plugins}/`, `.agents/hooks.json` | `.agents/mcp_config.json` literal tokens. Global skills: `~/.gemini/config/skills/` is the location all flavours load. |
| SpecStory | `**/.specstory/history/`, `**/.specstory/ai_rules_backups/` | nothing by default | The vendor suggests committing history for team context. That is a policy call; the default here keeps transcripts out of git. |

## Not re-verified (confirm before changing the fragment)

| Agent | Commit | Review / notes |
|---|---|---|
| Cursor | `.cursor/rules/`, `.cursorrules` (legacy), `.cursorignore`, `.cursorindexingignore` | `.cursor/mcp.json` often holds tokens. Chat history lives in app storage, not the repo. |
| GitHub Copilot | `.github/copilot-instructions.md`, `.github/instructions/`, `.github/prompts/`, `.github/agents/` | `.vscode/mcp.json` is ignored by the baseline `.vscode/*` rule. Re-include it only if it uses `${input:...}`/env refs. |
| Windsurf | `.windsurfrules`, `.windsurf/rules/`, `.windsurf/workflows/`, `.codeiumignore` | memories live outside the repo |
| Cline | `.clinerules` (file or dir), `.clineignore` | a `memory-bank/` folder is a team choice |
| Roo Code / Kilo Code | `.roo/rules*/`, `.roomodes`, `.rooignore`, `.kilocode/rules/` | `.roo/mcp.json`, `.kilocode/mcp.json` |
| Kiro | `.kiro/steering/`, `.kiro/specs/`, `.kiro/hooks/` | `.kiro/settings/mcp.json` |
| Continue | `.continue/rules/`, `.continue/prompts/` | `.continue/config.yaml` keys |
| Amazon Q | `.amazonq/rules/` | `.amazonq/mcp.json` |
| JetBrains Junie | `.junie/guidelines.md` | other `.junie/` contents |
| Goose / Warp / Zed / Augment / Trae | `.goosehints`, `WARP.md`, `.rules`, `.augment/rules/`, `.trae/rules/` | none known |
| Serena (MCP toolkit) | `.serena/project.yml` | `.serena/cache/` is ignored by the fragment. `.serena/memories/` is a team choice. |
| Cross-agent skills | `.agents/` (emerging shared skills dir) | none |

## Two interactions that break things

1. Some agents hide gitignored files from their own file tools. Gemini CLI
   and Crush do this by default. If you gitignore a file you want the agent
   to read, the agent silently loses it. Never ignore shared instruction
   files; the audit's section [6] errors on this.
2. `.gitignore` does not stop an agent from reading a file. OpenCode, for
   example, can discover and read `.env` even when it is gitignored. Keep
   secrets out of agent context with each tool's own controls, such as
   Claude Code `permissions.deny` on `Read(./.env*)` or `.cursorignore`,
   `.geminiignore`, `.aiderignore`, and `.crushignore`. These are separate
   from git hygiene.

Claude Code also adds `**/.claude/settings.local.json` to the user's global
git excludes the first time it writes that file. On the author's machine
that hides the problem, but collaborators without it can still commit the
file. This is why the project file carries the rule, and why the audit
evaluates proposed rules without personal global excludes.
