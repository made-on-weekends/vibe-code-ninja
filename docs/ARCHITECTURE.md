# ARCHITECTURE.md

> Technical structure. How the pieces fit together. Not how to use the project (see AGENTS.md).

## High-level diagram

```
                  ┌──────────────────────┐
                  │ User Coding Activity │
                  └──────────┬───────────┘
                             │
                             ▼
                 ┌───────────────────────┐
                 │  AI Coding Assistant  │
                 └─────┬─────┬─────┬─────┘
                       │     │     │
       ┌───────────────┘     │     └──────────────┐
       ▼                     ▼                    ▼
┌─────────────┐       ┌─────────────┐      ┌─────────────┐
│project-ninja│       │skill-logger │      │skill-review │
└──────┬──────┘       └──────┬──────┘      └──────┬──────┘
       │                     │                    │
       ▼ (consult/update)    ▼ (appends)          ▼ (graduates)
┌─────────────┐       ┌─────────────┐      ┌─────────────┐
│ Project Repo│       │~/.agents/   │      │~/.agents/   │
│ docs/ & code│       │  gaps.md    │      │  skills/    │
└─────────────┘       └─────────────┘      └─────────────┘
```

## Layers

`vibe-code-ninja` is a serverless, environment-agnostic markdown skill suite. It executes in the context of the AI agent host.

### project-ninja (Architect)
- **Role:** Handles workspace initialization, architectural alignment, and anti-drift validation.
- **Components:**
  - `SKILL.md`: Core mode-routing instructions (INIT, CONSULT, UPDATE, AUDIT).
  - `references/`: Detailed, single-concern procedure files loaded dynamically based on mode.
  - `templates/`: Base skeleton layouts for bootstrapping new project documentation.

### skill-ninja-logger (Observer)
- **Role:** Actively monitors or receives explicit requests to log developer friction and manual workflow patterns.
- **Target:** Appends structured YAML/Markdown items to the global `~/.agents/skill-gaps.md` file.

### skill-ninja-review (Evolver)
- **Role:** Periodic review processor.
- **Action:** Groups logger entries, applies graduation algorithms, and creates new skill structures under a quarantine layout.

## Request lifecycle

### 1. project-ninja CONSULT flow
```
1. User requests code change ->
2. project-ninja CONSULT mode triggered ->
3. Load project-ninja/references/routing.md and identify relevant docs ->
4. Load identified docs (e.g. PRODUCT.md for scope, ARCHITECTURE.md for layers) ->
5. Validate if change is in scope and doesn't contradict past Decisions ->
6. If violation is detected: Halt and alert human ->
7. If valid: Proceed with code edits.
```

### 2. skill-ninja-logger Friction logging flow
```
1. Developer/Agent detects friction ("I keep doing X manually") ->
2. skill-ninja-logger writes gap metadata (project tag, description, context) ->
3. Appended to global ~/.agents/skill-gaps.md ->
4. Flow terminates.
```

### 3. skill-ninja-review Weekly graduation flow
```
1. Run "weekly skill review" ->
2. Load ~/.agents/skill-gaps.md ->
3. Group entries by similarity ->
4. Apply thresholds: Recurrence (>=3 times across >=7 days), Specificity, non-overlap, sensitivity ->
5. Scaffold SKILL.md in ~/.agents/skills/_quarantine/<name>/ ->
6. Promote pre-existing quarantined skills (older than 7 days) to main directory.
```

## Cross-cutting concerns

- **State Management:** All state is local and file-based. There are no relational or database servers.
- **Scope Verification:** Enforced during the project-ninja CONSULT phase prior to modifying any source code.
- **Security:** `skill-ninja-logger` checks entries for potential PII or secrets. High sensitivity items are flagged `contains-pii-or-secret` and excluded from auto-graduation.

## Patterns we use

- **Context Routing:** Rather than loading the entire `docs/` folder, the agent only reads files containing context directly relevant to the current task to preserve token budgets.
- **Quarantine Isolation:** Auto-graduated skills are placed in a quarantined folder for 7 days, allowing safe testing before formal integration.
- **Append-only Decision Records (ADRs):** Decisions in `docs/DECISIONS.md` are sequential and append-only. Past decisions are never deleted or modified; instead, new entries supersede old ones.

## Patterns we avoid

- **Speculative features:** No skills are built without historical evidence of friction logged in `skill-gaps.md`.
- **Monolithic documentation:** We avoid bloating `README.md` or `CLAUDE.md` with deep architecture details, keeping them as high-level quickstarts and pointers respectively.
- **Automatic execution:** Skills do not run background cron jobs or execute code automatically without user authorization.
