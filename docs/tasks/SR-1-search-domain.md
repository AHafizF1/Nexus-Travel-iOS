# SR-1: Search models, codec, and display mapper

## Ownership

- PLAN task: `SR-1`
- Branch: `codex/sr-1-search-domain`
- Requires merged HM-1 types: `LocalDate`, `TripType`, `CabinClass`, `TravelerCounts`, `Money`.
- Agent owns local RED/GREEN commits only. Coordinator owns push, PR, CI loop, merge, PLAN, ARCHIVE.

Production:

- `Sources/Core/DateTime/LocalTime.swift`
- `Sources/Domain/Search/FlightSearchModels.swift`
- `Sources/Domain/Search/SearchResultsModels.swift`
- `Sources/Data/Search/Fake/NexusSearchIdCodec.swift`
- `Sources/Feature/SearchResults/SearchResultsDisplayModels.swift`

Tests mirror those areas under `Tests/`. Everything else read-only. Never edit PLAN/ARCHIVE/packet/project.yml/xcodeproj.

## Truth sources

Read completely before Swift:

- Android `domain/search/FlightSearchRepository.kt`
- Android `domain/search/SearchResultsModels.kt`
- Android `domain/search/SearchResultsRepository.kt`
- Android `data/search/fake/NexusSearchIdCodec.kt`
- Android `feature/searchresults/SearchResultsDisplayModels.kt`
- Android `feature/searchresults/SearchResultsUiState.kt`
- Android `feature/searchresults/SearchResultsViewModel.kt` only to confirm mapper/filter/sort consumers
- related Android tests and fake data located by `rg`
- `AGENTS.md`, `docs/PORTING.md`, `docs/CONVENTIONS.md`

Android controls behavior/copy. Backend DTOs, remote repositories, cache, ViewModel, booking status, screen, and legacy artifacts are excluded.

## Skills

Use `ponytail`, `write-swift`, `swift-expert`, `swift-api-design-guidelines`, `test-driven-development`, `improve-codebase-architecture`, `code-structure`, `dry-principle`, `swift-architecture`, `ux-copy`, and `ui-typography`. No SwiftUI/concurrency/network/animation work.

## Date/time value

Add minimal validated `LocalTime(hour:minute:)` value: hour `0...23`, minute `0...59`, `Comparable`, `Codable`, `Hashable`, `Sendable`, exact `HH:mm` parse/format. It is wall-clock time, never `Date`, instant, locale formatter, or time zone.

## Domain contracts

Mirror Android names and stored fields:

- `FlightSearchLeg`
- `FlightSearchRequest` with one-way, round-trip, and multi-city valid states; factory returns nil for missing round-trip return date or multi-city leg count outside `2...3`, never traps
- `FlightSearchResult`
- `AirlineBrand`, `FlightOfferReference`, `FlightProvider`
- `SearchResultsQuerySummary`, `FlightOffer`, `FlightLeg`, `FlightStop`
- `FlightOfferBadge`, `SearchWarning`, `SearchFilter`, `SortOption`, `SearchResultsResult`

Preserve defaults, raw source data, names, labels, and ordering. `FlightLeg.stopCount` uses `reportedStopCount ?? stops.count`. `SortOption.next()` cycles recommended → best price → fastest → departure early → recommended. Do not add repository protocols until remote/fake adapter task proves need; result enums are data only here.

Use value types. Add protocols only where packet explicitly requires none. Every non-private declaration gets `///` summary. No third-party dependency.

## Search ID codec

Static `NexusSearchIdCodec`:

- Encode exact underscore fields: `search`, trip code, uppercase origin/destination, departure ISO date, return ISO or `none`, normalized adult/child/infant counts, cabin code, `cheapest|normal`.
- Trip codes: `oneway`, `roundtrip`, `multicity`; cabin codes: `economy`, `premiumeconomy`, `business`, `first`.
- Decode fewer than 10 parts or wrong prefix to deterministic fallback injected with `today`; fallback is round trip ADD→DXB, departure today + 7, return + 14, one adult, economy.
- Unknown trip code → one way; unknown cabin code → economy; malformed counts → 1/0/0 then normalize; missing cheapest part → false.
- Malformed encoded ISO date must return same deterministic fallback, not reproduce Kotlin parse crash.
- Preserve original search ID in decoded summary. No clock singleton, UUID, JSON, percent encoding, or backend inference.

## Display mapper and collection transform

Mirror `SearchResultsDisplayState`, `SearchResultUiOffer`, `SearchResultUiLeg`, offer-to-display mapping, booking-status copy transform, filters, and sort.

Exact rules:

- Strip only exact `"<currency> "` prefix from current/old formatted price.
- Price meta: `"<currency> · One way|Round trip|Multi-city"`.
- Digit count ignores leading minus; duration is `"<hours>h <minutes>m"`; time is zero-padded `HH:mm`.
- Stop labels: zero `Non-stop`; known stop list `N stop · <first airport>`; otherwise singular/plural `N stop(s)`. Compact nonzero stays `N stop`, matching Kotlin.
- Seats: `N seats left`; badge uses enum label; booking status defaults nil.
- Fastest key sums every display leg duration; early key uses outbound time.
- Filters compose: non-stop requires all legs zero, one-stop requires any leg exactly one, morning outbound hour `5...11`. Best-price filter itself does not remove offers.
- Sort must remain stable: recommended preserves input; other options ascending by price, total duration, or outbound time. Equal keys preserve original order.

## TDD

Commit tests first. Windows expected RED = missing production symbols; do not push RED alone.

Cover:

- `LocalTime` validation, exact parsing/formatting, ordering, Codable;
- request factory defaults/valid shapes plus safe invalid round-trip/multi-city inputs;
- labels, next cycle, reported stop count;
- codec exact IDs, normalization, uppercase route, round-trip/multi-city, fallback with injected date, unknown codes/counts, malformed date;
- every mapper string/boundary, all-leg construction, negative digit count;
- each filter alone/composed, morning endpoints, all sort modes, stable ties.

No ceremonial stored-property tests.

## Exclusions

No repositories/adapters beyond codec, backend DTO/mappers, cache, fake offer inventory, ViewModel, state machine, navigation, booking repository, SwiftUI, networking, async, assets, or screen copy outside mapper contract.

## Done

- [ ] RED precedes production.
- [ ] Exact models/defaults compile.
- [ ] Codec edge matrix passes deterministically.
- [ ] Display mapping/filter/sort matrix passes.
- [ ] No duplicated HM-1 type or out-of-scope abstraction.
- [ ] Latest PR-head CI green after coordinator push.
