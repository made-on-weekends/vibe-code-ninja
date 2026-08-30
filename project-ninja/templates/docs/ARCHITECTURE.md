# ARCHITECTURE.md

> Technical structure. How the pieces fit together. Not how to use the project (see AGENTS.md).

## High-level diagram

```
TODO(<owner>): ASCII diagram. Example:

  ┌──────────┐    ┌──────────┐    ┌──────────┐
  │  Client  │ →  │   API    │ →  │    DB    │
  └──────────┘    └──────────┘    └──────────┘
```

## Layers

### Frontend (or client layer)
TODO(<owner>): What technology, what patterns, where pages live, where components live, how state flows.

### Backend / API layer
TODO(<owner>): Routes location, error handling pattern, auth middleware.

### Data layer
TODO(<owner>): DB engine, ORM/query builder, migrations strategy. Cross-link `DATABASE.md` and `SCHEMA.md`.

### External services
TODO(<owner>): Third-party APIs, queues, storage, LLM providers. Note auth method per service.

## Request lifecycle

TODO(<owner>): Trace a typical request from entry point to response. Include error paths.

```
TODO(<owner>): example flow

1. Request arrives at <entry point>
2. <middleware/auth/validation steps>
3. <handler logic>
4. <data layer access>
5. <response shape>

Error paths:
- Validation failure → <how it's returned>
- Auth failure → <how it's returned>
- Internal error → <how it's logged and returned>
```

## Cross-cutting concerns

- **Auth:** TODO(<owner>): Pattern (JWT, sessions, etc.) and where it lives. Mechanics owned by `SECURITY.md`.
- **Logging/observability:** TODO(<owner>): What we use.
- **Background jobs:** TODO(<owner>): If applicable.
- **Caching:** TODO(<owner>): If applicable.
- **Feature flags:** TODO(<owner>): If applicable.

## Multi-tenancy / isolation (if applicable)

TODO(<owner>): How tenants are isolated at the data layer, the API layer, and the frontend. This is one of the most-changed areas, so be precise.

## Patterns we use

TODO(<owner>): The patterns the codebase commits to. Examples:
- Repository pattern for data access
- Result types instead of exceptions for expected failures
- Composition over inheritance
- Single responsibility per module

## Patterns we avoid

TODO(<owner>): The patterns we explicitly reject and why. Examples:
- Service locator / global container — reason: <why>
- Active record — reason: <why>
- Mixed concerns in route handlers — reason: <why>

This list is the framework-of-the-month protection. When an agent or contributor proposes a pattern that's listed here, it's a `DECISIONS.md` conversation, not a silent change.

## Deployment

TODO(<owner>): Environments, host, deploy command, rollback approach.
