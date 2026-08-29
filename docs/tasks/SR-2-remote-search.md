# SR-2: Remote flight search and in-memory results cache

## Ownership and truth

- Branch `codex/sr-2-remote-search`; requires merged SR-1 and NT-1.
- Own `Sources/Domain/Search/FlightSearchRepository.swift`, `Sources/Data/Search/{API,DTO,Mapper,Repository,Cache}/**`, and matching `Tests/Data/Search/**`. Existing domain models and shared transport are read-only unless a proven contract defect requires the smallest upstream correction.
- Network truth order: backend `flights.controller.ts`, `flights.dto.ts`, `flights.service.ts`, `test/flights.e2e.test.ts`; then Android `RemoteFlightSearchRepository`, Nest DTOs/mappers/cache. Read all completely.
- Use mandatory Swift, TDD, architecture/DRY, and concurrency skills. No UI.

## Request and endpoint

- Anonymous POST mobile target `flights/search` (resolved once under `/api/v1/mobile`), JSON body, 30-second shared transport default.
- Encode exact backend keys: `tripType`, `from`, `to`, `departureDate`, `returnDate`, `legs`, `adults`, `children`, `infants`, `childAges`, `infantAges`, `cabinClass`, `cheapestFirst`.
- Codes uppercase. Dates use `yyyy-MM-dd`. Trip values `ONE_WAY`, `ROUND_TRIP`, `MULTI_CITY`; cabin values `ECONOMY`, `PREMIUM_ECONOMY`, `BUSINESS`, `FIRST`.
- One-way/round-trip send root route fields and omit `legs`; multi-city sends only `legs` and omits root route/date fields. Round trip includes return date only. Normalize traveler counts before encoding; preserve supplied age arrays. No bearer.

## Response mapping and cache

- Strictly decode required top-level `sessionId`, `expiresAt`, and `offers`; ignore additive JSON. Required offer: id, currency, expiresAt, monetary minor fields; airline/fare/itinerary structures follow current backend optionality.
- Map Android-compatible `SearchResultsResult.success`: query summary from original request; offer reference uses session ID + offer ID/token, Travelport GDS provider, `TRAVELPORT` source, response/product/terms/brand empty, server offer expiry.
- Carrier precedence: nonblank itinerary marketing carrier, then validating carrier, then `Airline`; airline name/logo use resolved optional payload. First itinerary leg wins outbound, second wins inbound; all response legs preserved. If legs absent, use itinerary aggregate; missing aggregate itinerary makes response malformed, never invent a route. Parse ISO-8601 with/without fractional seconds; reject invalid required timestamps/times.
- Price amount remains backend `totalAmountMinor`; formatted text uses currency code plus locale-aware major units. Seats use optional `remainingSeats`; refundable false; no badge/warnings unless backend supplies them.
- `SearchResultsCache` is an actor-backed in-memory dictionary keyed by exact session ID. `RemoteFlightSearchRepository` maps and stores success before returning search ID. `RemoteSearchResultsRepository` returns cached success or `.empty`. No disk cache, TTL timer, eviction, stale refresh, or duplicate network call.

## Errors and concurrency

- Repository preserves Android product result cases but is narrowly `async throws` so cancellation propagates: connectivity/timeout -> `.networkUnavailable`; malformed JSON, invalid required data, HTTP 4xx/5xx, cache/mapping unknown -> `.unknownError`. Rethrow `CancellationError`; never convert cancellation into a user-visible result.
- No unstructured tasks, locks, `@unchecked Sendable`, retries, reachability, logging of request/user data, or mutable global state.

## TDD and acceptance

- Tests-only RED commit, then minimum GREEN. Cover URL/method/no-auth; all trip/cabin shapes; uppercase/date encoding; normalized travelers and ages; strict/additive DTO decoding; aggregate and multi-leg mapping; carrier precedence; money/seat/expiry; empty offers success; cache hit/miss/isolation; full transport/status/malformed matrix; cancellation behavior; no cache write on failure.
- Contract fixtures derive from backend e2e/service output, including 201 success, three-leg multi-city, absent optional airline/fare data, additive fields, and missing-required rejection.
- Adversarial review compares every backend field and Android mapping/cache behavior. Feature-complete push once; latest-SHA macOS CI green before merge.
- Exclude Home UI/ViewModel, airport/home-content APIs, search-results screen, details/price endpoints, persistence, retries, auth, and backend edits.
