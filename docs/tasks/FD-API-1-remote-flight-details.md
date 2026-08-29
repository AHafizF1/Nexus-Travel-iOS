# FD-API-1 — Remote flight details adapter

## Outcome

Price or revalidate one selected search offer through backend `POST /api/v1/mobile/flights/details`, strictly decode canonical details, and map transport/status outcomes into `FlightDetailsResult`.

## Dependencies

FD-1, NT-1, SR-3 merged.

## Truth sources

- Backend `flights.controller.ts`, `flight-details.service.ts`, service tests, and `flights.e2e.test.ts`.
- Android `data/flightdetails/{api,dto,mapper,repository}`.

## Scope

- Endpoint, request/response DTOs, strict mapper, remote repository, contract fixtures/tests.
- Preserve cancellation; 401 auth, 404/503 unavailable, 410 expired, offline/timeout network, other/malformed unknown.
- Request contains only `searchSessionId` and `offerId`; endpoint is anonymous and sends no bearer.
- Additive JSON fields decode; missing required details fail mapping.

## Exclusions

No screen/ViewModel, retry engine, cached fallback, booking repository, backend edits, dependency, or generated Xcode project edit.

## Verification

Swift Testing covers request shape/path, confirmed and price-changed mapping, detailed legs/segments/rules/availability, strict/additive decoding, status matrix, network errors, and cancellation. Push only after feature-complete self-review; latest PR-head CI must pass before merge.
