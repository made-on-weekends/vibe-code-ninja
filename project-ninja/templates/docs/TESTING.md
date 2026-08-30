# TESTING.md

> Test strategy and commands.

## Stack

- Unit: TODO(<owner>): test framework
- Component / integration: TODO(<owner>)
- End-to-end: TODO(<owner>)
- API contract: TODO(<owner>): if applicable

## Commands

```bash
TODO(<owner>): all-tests command
TODO(<owner>): unit-only command
TODO(<owner>): e2e-only command
TODO(<owner>): watch mode
TODO(<owner>): coverage report
```

(Commands are also listed in `AGENTS.md`. AGENTS owns the command list; TESTING owns strategy.)

## File layout

- Unit/component tests: TODO(<owner>): location pattern
- E2E tests: TODO(<owner>)
- Test utilities: TODO(<owner>)
- Fixtures: TODO(<owner>)

## Coverage policy

TODO(<owner>): Target percentage, what's exempt (config files, generated code).

## What to test

**Do test:**
- Business logic in core modules / functions / domain services
- API route handlers (request → response shape, error paths)
- Critical user flows via E2E (sign-up, primary product action)
- Permission boundaries (access policies, role checks)
- Anything the bug tracker has flagged as a regression risk

**Don't test:**
- Third-party libraries (test the integration, not the library)
- Trivial getters/setters
- The framework itself
- Generated code

## Conventions

- Test names: describe behavior, not implementation. ✅ "rejects when email is missing" ❌ "calls validateEmail()"
- One assertion per test where reasonable
- Use real types in test data factories — no `any` / `unknown` shortcuts
- Mock at the boundary (HTTP, DB, filesystem), not internal modules

## Test data strategy

TODO(<owner>): Factories vs fixtures vs builders. Pick one approach as default.

## Snapshot policy

TODO(<owner>): Snapshots for what (rendered output? data structures?). When they're banned (anything that changes frequently).

## Mocking philosophy

**Do:**
- Mock at the network/system boundary (HTTP requests, DB calls, time, randomness)
- Inject dependencies so tests can substitute fakes

**Don't:**
- Don't mock internal modules. If you need to mock a peer module, that's a sign of a design problem.
- Don't mock the language runtime (Date, Math.random) — abstract them and inject.

## CI

TODO(<owner>): Where tests run, what blocks merge, what's required for release.

## Flaky test policy

TODO(<owner>): How flakes are handled. Recommendation: quarantine (skip with reason + ticket) within 24h, fix within N days, or delete.
