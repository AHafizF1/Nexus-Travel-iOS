# Learnings

## 2026-08-24

- Backend contract truth lives in `C:\Users\Afiz\Documents\nexus-travel-backend`; similarly named Desktop folder contains no source.
- Network contract order: backend controllers/DTOs/e2e tests, deployed read-only probe, Android remote adapters.
- Android health route is stale: production/backend use `/api/v1/health`.
- Launch auth is email/password only; backend has no Google or Apple provider.
- Booking hold, passport upload, and account deletion require stable operation-scoped idempotency keys.
- Do not extract shared cache mechanics before third same-domain instance; keep different cache semantics separate.
