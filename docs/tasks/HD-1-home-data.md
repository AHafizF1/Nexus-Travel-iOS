# HD-1: Remote Home and airport data adapters

## Ownership and truth

- Branch `codex/hd-1-home-data`; requires HM-1 and NT-1.
- Own `Sources/Domain/Home/HomeRepositories.swift`, `Sources/Data/Home/{API,DTO,Mapper,Repository,Cache}/**`, matching `Tests/Data/Home/**`, plus smallest query-item extension in `Sources/Core/Network/HTTPRequest.swift`, `AppConfiguration.swift`, and their tests.
- Network truth: backend mobile content controller/service/e2e tests, then Android `RemoteHomeRepository`, `RemoteAirportRepository`, `AirportCache`, Content DTOs/mappers, and defaults. Read completely.
- Use mandatory Swift, TDD, architecture/DRY, and concurrency skills. No UI.

## Shared query support

- Add structured `[URLQueryItem]` to `HTTPRequest`; AppConfiguration constructs/percent-encodes query without accepting path traversal or duplicating origin/mobile prefix. Empty query behaves exactly as today. No string-concatenated query values.

## Airport adapter

- Anonymous GET `airports/popular?limit=60` for blank/whitespace query; GET `airports/search?q=<original query>&limit=30` otherwise. Mapper trims only for cache-key classification; send original query so backend normalization remains authoritative.
- Strict list envelope requires `items` and `limit`; airport requires `iataCode`, `name`, `city`, `country`; ignore additive fields. Map displayName through existing domain initializer.
- Actor `AirportCache`: normalized key `popular` or `search:<trimmed lowercase query>`; default TTL exactly 10 minutes; injected clock for deterministic tests; never cache empty results. Fresh hit skips network. Stale hit revalidates. HTTP status and connectivity/timeout failures return stale cache if present, else empty. Cancellation and malformed/decoding failures throw; never disguise contract drift as empty content.

## Home adapter

- Anonymous GET `airports/popular?limit=20`, then GET `explore`. Both must succeed with 2xx and strict decodes.
- Origin precedence: ADD, first airport, built-in Addis Ababa. Destination precedence: DXB, first different airport, built-in Dubai.
- Explore home requires `destinations`, `packages`; ignores additive `banners`. Destination requires id/title/city/country/summary; airportCode/imageUrl optional. Package requires id/title/summary/priceFromMinor/currency; additive image metadata ignored.
- Preserve Android index pairing: each package becomes one `TrendingEscape`, paired destination by index; fallback destination values when absent. Preserve current Android Home mapping exactly: starting price amount `0`, package currency, empty formatted text. Do not silently reinterpret backend package price in this porting task.
- Recent searches use first three destinations and fallback origin/destination codes exactly. Keep Android display placeholders `Aug 1`, `Add return`, `1 Adult`, `Economy` because current HomeContent contract carries strings; HM-2 derives actual editable dates separately.
- `HomeRepository.getHomeContent()` is narrowly throwing for cancellation only and returns `HomeResult<HomeContent>` for success/networkUnavailable/unknownError. Connectivity/timeout -> networkUnavailable; status/malformed/mapping -> unknownError. No partial success.

## TDD and acceptance

- Tests-only RED commit then minimum GREEN. Cover percent encoding/query/path; airport blank/search route and limits; normalized cache keys; fresh/stale/empty cache; fallback on status/network; cancellation; strict/additive DTOs; ADD/DXB/default precedence; index pairing/fallbacks; first-three recents; Android zero/empty Home price mapping; complete Home error matrix; no auth headers.
- Contract fixtures derive from backend content e2e output, including image additive fields/banners, empty airports/explore, and missing required rejection.
- Exclude Home ViewModel/screens, flight search, explore screens/details, disk cache, retries, images/assets, backend edits, and third-party dependencies.
