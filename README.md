# 🥷 Vibe Code Ninja

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Standard: SKILL.md](https://img.shields.io/badge/Standard-SKILL.md-success.svg)](https://github.com/agent-skills/skill-md)

> **A powerful suite of agent skills designed to keep AI-assisted coding sessions aligned, observant, and continuously improving.**

**Vibe Code Ninja** is tool-agnostic. It works seamlessly with modern AI coding assistants that support the `SKILL.md` standard, including **Claude Code, Antigravity, Cursor, Codex, and Gemini CLI**.

---

## ✨ What's Inside?

The suite is composed of three core skills, designed to work independently but compose beautifully:

### 📐 `project-ninja`
**The Architect.** Prevents architectural drift and maintains code-doc alignment.
Instead of loading your entire codebase, it manages 16 canonical project documents (like `AGENTS.md` and `docs/ARCHITECTURE.md`) and intelligently routes context by task to save tokens. It runs mandatory *scope*, *decision*, and *deletion* anti-drift checks before making code changes.

### 📝 `skill-ninja-logger`
**The Observer.** Turns daily friction into structured insights.
Whenever you think, *"I keep doing this manually"* or *"This should be a skill,"* simply tell your AI to log it. This skill captures your observations into a structured log (`~/.agents/skill-gaps.md`) in seconds.

### 🧠 `skill-ninja-review`
**The Evolver.** Autonomously evolves your workflows.
Run weekly, this skill reads your gap log, identifies recurring friction patterns, and drafts new skills. It includes built-in guardrails: a 7-day quarantine, three-signal routing, and mandatory manual reviews to ensure only high-quality skills graduate.

> **Roadmap Note:** `code-graph-ninja`
> *Currently deferred to uphold our evidence-driven philosophy.* A code-mapping skill will only be built if `skill-ninja-logger` reports ≥10 instances of "AI reads ≥3 files to locate one symbol" within 30 days.

---

## 💻 Installation

We recommend installing these skills in the open standard directory (`~/.agents/skills/`), which Cursor reads natively and other tools can access via symlinks.

```bash
# 1. Extract the archive and enter the directory
cd vibe-code-ninja

# 2. Install to the open standard directory (native to Cursor)
mkdir -p ~/.agents/skills
cp -r project-ninja skill-ninja-logger skill-ninja-review ~/.agents/skills/
```

<details>
<summary><b>3. Click to expand setup for your specific AI Tool</b></summary>

**For Claude Code:**
```bash
mkdir -p ~/.claude/skills
ln -s ~/.agents/skills/project-ninja ~/.claude/skills/
ln -s ~/.agents/skills/skill-ninja-logger ~/.claude/skills/
ln -s ~/.agents/skills/skill-ninja-review ~/.claude/skills/
```

**For Antigravity:**
```bash
mkdir -p ~/.gemini/antigravity/skills
ln -s ~/.agents/skills/project-ninja ~/.gemini/antigravity/skills/
ln -s ~/.agents/skills/skill-ninja-logger ~/.gemini/antigravity/skills/
ln -s ~/.agents/skills/skill-ninja-review ~/.gemini/antigravity/skills/
```

**For Codex:**
```bash
mkdir -p ~/.codex/skills
ln -s ~/.agents/skills/project-ninja ~/.codex/skills/
ln -s ~/.agents/skills/skill-ninja-logger ~/.codex/skills/
ln -s ~/.agents/skills/skill-ninja-review ~/.codex/skills/
```

**For Gemini CLI:**
```bash
mkdir -p ~/.gemini/skills
ln -s ~/.agents/skills/project-ninja ~/.gemini/skills/
ln -s ~/.agents/skills/skill-ninja-logger ~/.gemini/skills/
ln -s ~/.agents/skills/skill-ninja-review ~/.gemini/skills/
```
</details>

<br>

**Verify Installation:** Restart your AI tool and ask: *"What skills do you have available?"* All three skills should be listed.

---

## 🚀 Quick Start Guide

Maximize your workflow by following this recommended loop:

1. **Install the Suite**: Setup is quick and works across multiple AI assistants.
2. **Initialize**: Run `project-ninja` in **INIT mode** on your messiest active project.
3. **Consult**: Use `project-ninja` in **CONSULT mode** before non-trivial code changes. Let the anti-drift checks protect your architecture.
4. **Log Friction**: Invoke `skill-ninja-logger` whenever you hit a repetitive task (*"log a skill gap"*).
5. **Evolve**: Run `skill-ninja-review` weekly to process your gap log and auto-generate new skills.

---

## 🏗️ Core Design Principles

Every skill in the suite is built on three foundational philosophies:

1. **Token efficiency comes from routing, not compression.**
   `project-ninja` dynamically targets 1–3 specific files per task rather than loading all 16 project documents. Loading precise context is far more effective than summarizing large amounts of text.
2. **Evidence-driven over speculative.**
   We don't build features just because they sound cool. Skills are only auto-graduated when multiple occurrences prove a pattern is real.
3. **Quarantine over approval gates.**
   New, auto-created skills land in a 7-day quarantine rather than waiting for immediate approval. This avoids prompt fatigue, letting you intervene only when something looks wrong.

---

## 📂 File Structure

```text
vibe-code-ninja/
├── project-ninja/
│   ├── references/      # Detailed procedures (init, consult, update)
│   ├── templates/       # 16 minimal markdown templates for projects
│   └── SKILL.md         # Core instructions & mode router
├── skill-ninja-logger/
│   └── SKILL.md         # Friction logging instructions
├── skill-ninja-review/
│   └── SKILL.md         # Weekly review and generation logic
└── README.md            # You are here
```

*(Each skill includes its own README for deeper technical details).*

---

## 📂 Documentation

- **For AI Coding Agents:** See [AGENTS.md](AGENTS.md) — the single source of truth for agent rules, stack, and routing.
- **Product Scope:** See [docs/PRODUCT.md](docs/PRODUCT.md) — what we are building, for whom, and what is explicitly out of scope.
- **Architecture:** See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — folder structure, file design, and how the skills execute.
- **Decisions Log:** See [docs/DECISIONS.md](docs/DECISIONS.md) — append-only log of architectural decisions.

---

## 🐛 Report An Issue

Encountered a problem or unexpected behavior? Please open an issue and follow the steps in our [Quick Guide to Reporting Issues](REPORTING.md)

## 🤝 Contributing

We’re excited to have you! Check out our [Contribution Guide](CONTRIBUTING.md) to learn how to make pull requests, and more ways to help shape this project.

## ⭐ Support Us

If **Vibe Code Ninja** has saved you tokens, prevented architectural drift, or streamlined your workflow, consider supporting the project:

- ⭐ **Star the Repo**: Help others discover the "Ninja" way.
- 📣 **Spread the Word**: Share your workflow on X/Twitter or your blog.
- ☕ **Fuel the Forge**: Consider a [donation](https://asifiqbal.rocks/donation) to fund ongoing development and open-source initiatives.

---

## 📄 License

This project is licensed under the [MIT License](https://choosealicense.com/licenses/mit).
