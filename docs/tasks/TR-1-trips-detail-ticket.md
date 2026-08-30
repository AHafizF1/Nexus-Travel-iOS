# TR-1 — Trips list, detail, and ticket

## Outcome

Replace Trips placeholder with authenticated/guest list, cached trip detail, and locally cached e-ticket PDF access.

## Truth sources

- Android `domain/trips/TripsModels.kt`
- Android `data/trips/{TripsCache,RemoteTripsRepository}.kt`
- Android `feature/trips/{TripsViewModel,TripsScreen,TripDetailViewModel,TripDetailScreen}.kt`
- Backend customer-trips controller, DTO, service, repository, and tests.
- Backend authenticated ticket-document controller/service and ownership/security e2e tests.

## Acceptance

- Guest prompt and authenticated Action needed/Upcoming/Past/Cancelled filters preserve Android behavior and copy.
- List and detail decode current backend DTOs, ignore additive fields, reject missing required fields, attach bearer, and preserve ownership-hiding `404`.
- Cache uses five-minute fresh and 24-hour stale windows; stale data remains visible with honest offline/last-updated state.
- List/detail expose loading, content, empty, and error states; refresh preserves valid content and cancellation never becomes visible failure.
- Detail shows status, flights, seats, tickets, amount, notice, and Android action policy.
- Ticket flow resolves authenticated signed URL, downloads without bearer, stores PDF in app support, then opens native preview/share path. No third-party dependency.
- Icon-only controls labeled; Dynamic Type-safe layout; no debug, beta, or placeholder copy.
- Tests cover DTO/route/auth mapping, cache windows, ownership errors, ticket authorization separation, ViewModel transitions, action policy, duplicate prevention, stale response protection, and cancellation.

## Owned paths

- `Sources/{Domain,Data}/Trips/**`
- `Sources/Feature/Trips/**`
- Trips composition in `Sources/App/**`
- Matching tests and coordinator ledger updates.
