# SECURITY.md

> Security rules and threat model. Cross-references `DATABASE.md` for access policies and `API.md` for auth shape.

## Hard Rules

These rules are **absolute**. Violating any of them requires a `DECISIONS.md` entry that explicitly supersedes the rule, with security review. The rules listed here are not the project's complete security posture — they are the floor below which behavior is considered a defect.

1. **Never** log PII, secrets, tokens, or credentials — even at debug level.
2. **Never** trust client-side validation as a security control. Always re-validate at the trust boundary.
3. **Never** string-concatenate SQL or shell commands. Always use parameterized queries / safe APIs.
4. **Always** validate every input at the API boundary, before any business logic runs.
5. **Always** enforce authorization at the data layer (access policies / RBAC), not only at the API layer.
6. **Never** disable security middleware, CSP, or HTTPS for "local convenience" in any path that ships.
7. **Never** commit secrets to the repo. Use `.env.example` as the template and a secrets manager for real values.
8. TODO(<owner>): add project-specific hard rules.

Hard rule violations stop the agent in CONSULT mode. They cannot be "worked around" without a formal decision.

## Authentication

- Method: TODO(<owner>): e.g., JWT-based, session-based, third-party (Auth.js, Clerk, Supabase Auth)
- Session lifetime: TODO(<owner>)
- Refresh strategy: TODO(<owner>)
- Where session is checked: TODO(<owner>): middleware path / server-side guard

## Authorization

- Model: TODO(<owner>): Access-policy-based / role-based / both
- Roles: TODO(<owner>): list and what each can do
- Where checks happen: TODO(<owner>): data layer / API layer / both
- Why: TODO(<owner>): the threat model rationale (cross-link `DATABASE.md` for the policy mechanics)

## Secrets management

- Local: `.env` (never commit)
- Production: TODO(<owner>): e.g., platform env vars, secrets manager
- Rotation policy: TODO(<owner>)

## Sensitive data inventory

PII, financial, or health data fields. Cross-references `SCHEMA.md` (which marks the columns).

| Table.column          | Type of sensitivity | Encryption at rest | Notes                  |
|-----------------------|---------------------|--------------------|------------------------|
| TODO(<owner>)         |                     |                    |                        |

## Encryption

- At rest: TODO(<owner>): default DB encryption + any application-layer encryption
- In transit: HTTPS-only, HSTS

## Input validation

- Server: TODO(<owner>): e.g., schema validation at API boundary, no exceptions
- Client: validation is UX, not security — never trust client-side checks

## Rate limiting

TODO(<owner>): Threat-model rationale for current limits. Concrete values live in `API.md`.

## CORS

TODO(<owner>): Allowed origins, exceptions

## Content Security Policy

TODO(<owner>): If set

## Threat model — top concerns

TODO(<owner>): The 3–5 attack vectors most relevant to this product. Examples for a multi-tenant SaaS:
- Cross-tenant data leakage — mitigation: every tenant table has access policies, tested in CI
- Token theft — mitigation: short-lived tokens, secure cookies
- Prompt injection in user-uploaded content — mitigation: TODO

## Incident response

Short checklist for when something goes wrong:

1. **Detect** — what triggered the alert (log, user report, monitoring)
2. **Contain** — stop the bleeding (revoke token, disable endpoint, scale down)
3. **Notify** — affected users / teammates / authorities per applicable policy
4. **Investigate** — root cause analysis
5. **Postmortem** — append decision to `DECISIONS.md` with what changed

## Data retention

TODO(<owner>): What we keep, for how long, how it's deleted, and how we handle deletion requests (GDPR / CCPA / etc.).

## Reporting vulnerabilities

TODO(<owner>): Contact + policy

## Audit log

TODO(<owner>): What's logged, where, retention
