# API.md

> Backend API contract. Endpoint shapes, error format, auth.

## Conventions

- Base URL: TODO(<owner>): e.g., `/api/v1`
- Auth: TODO(<owner>): e.g., Bearer token in `Authorization` header
- Content-Type: `application/json`
- Naming: TODO(<owner>): `snake_case` or `camelCase` — pick one and stick to it

## Do / Don't

**Do:**
- Return errors in the response body using the standard error shape (below). Never throw exceptions that bypass it.
- Validate every input at the API boundary, before any business logic runs.
- Make GET, PUT, DELETE idempotent. Same request → same response, no side effects beyond the first.
- Use cursor-based pagination for list endpoints (or document the alternative below).
- Version breaking changes, never silently change response shape.

**Don't:**
- Don't expose internal IDs (DB sequences) — use opaque IDs or UUIDs externally.
- Don't return different status codes for "not found" vs "not authorized to see" — pick one to avoid leaking existence.
- Don't break a contract without a deprecation period documented in `DECISIONS.md`.
- Don't accept input you don't validate, even if it "looks safe."
- Don't return raw exception messages to clients.

## Standard error shape

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Human-readable message",
    "details": {}
  }
}
```

TODO(<owner>): Adjust to match actual implementation. List standard error codes.

## Idempotency policy

TODO(<owner>): Which methods are idempotent and what tokens (e.g., `Idempotency-Key` header) clients can use to make POST safely retryable.

## Pagination policy

TODO(<owner>): Cursor or offset? Parameter names? Default and max page size?

## Deprecation procedure

TODO(<owner>): How a breaking change ships. Example pattern:
1. Add new endpoint or field alongside old
2. Mark old with deprecation header (`Deprecation`, `Sunset`)
3. Document in `DECISIONS.md` with sunset date
4. Remove only after sunset date

## Endpoints

### Resource: TODO(<owner>): e.g., Reports

#### `GET /reports`
- Auth: required
- Query params: TODO(<owner>)
- Response 200:
  ```json
  TODO(<owner>): example
  ```

#### `POST /reports`
TODO(<owner>): Add as endpoints exist.

---

TODO(<owner>): Add other resource sections as needed.

## Rate limiting

TODO(<owner>): Per-route limits and what error response a rate-limited client sees. Threat-model rationale lives in `SECURITY.md`.

## Versioning policy

TODO(<owner>): How major/minor changes are handled.
