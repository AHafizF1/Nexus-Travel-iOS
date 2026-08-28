# HM-1: Home models, multi-city state, and search validation

## Ownership

- PLAN task: `HM-1`
- Branch: `codex/hm-1-home-domain`
- Base: shared Phase 2 dispatch commit from merged DS-4.
- Parallel with AU-1; paths do not overlap.
- HM-1 must merge before SR-1.
- Agent owns local RED/GREEN commits only. Coordinator owns push, PR, CI loop, merge, PLAN, ARCHIVE.

Production:

- `Sources/Core/DateTime/LocalDate.swift`
- `Sources/Domain/Home/HomeModels.swift`
- `Sources/Feature/Home/HomeUiState.swift`
- `Sources/Feature/Home/HomeMultiCityState.swift`
- `Sources/Feature/Home/HomeSearchValidator.swift`

Tests:

- `Tests/Core/DateTime/LocalDateTests.swift`
- `Tests/Domain/Home/HomeModelsTests.swift`
- `Tests/Domain/Home/TravelerCountsTests.swift`
- `Tests/Feature/Home/HomeMultiCityStateTests.swift`
- `Tests/Feature/Home/HomeSearchValidatorTests.swift`

Everything else read-only. Never edit PLAN/ARCHIVE/packet/project.yml/xcodeproj.

## Truth sources

Read completely before Swift:

- Android `domain/home/HomeModels.kt`, `HomeRepository.kt`, `AirportRepository.kt`
- Android `feature/home/HomeMultiCityState.kt`, `HomeSearchValidator.kt`, `HomeUiState.kt`, `HomeViewModel.kt`
- Android `TravelerCountsTest.kt`, `HomeSearchValidatorTest.kt`, `HomeMultiCityStateTest.kt`, `HomeViewModelSearchActionsTest.kt`
- Home fake airport/content files and search request callers found by `rg`
- `AGENTS.md`, `docs/PORTING.md`, `docs/CONVENTIONS.md`

Android Kotlin code controls behavior/copy. Legacy artifacts excluded. Repositories/async/UI excluded.

## Skills

Use `ponytail`, `write-swift`, `swift-expert`, `swift-api-design-guidelines`, `test-driven-development`, `improve-codebase-architecture`, `code-structure`, `dry-principle`, and `swift-architecture`. No SwiftUI/copy/concurrency/network/motion work.

## Shared local-day type

Android `LocalDate` is day-only. Swift `Date` is an instant and must not represent these fields. Add minimal `LocalDate` value:

- validated `year`, `month`, `day` storage;
- `Comparable`, `Equatable`, `Hashable`, `Codable`, `Sendable`;
- stable ISO `yyyy-MM-dd` parse/format;
- `addingDays(_:)` using deterministic Gregorian calendar/UTC mechanics;
- no current-date global, locale formatting, time zone state, clock protocol, or `Date` storage exposed.

Invalid components/ISO return nil or throw a small explicit parse error—never force unwrap/precondition. Tests cover leap day, month/year rollover, ordering, invalid input, round trip. SR-1 later adds separate `LocalTime`; do not add it now.

## Models

- `Airport(code, city, name, country, displayName)`; preserve stored Kotlin `displayName` default derived as `City (CODE)` while allowing explicit decoded value only if model contract needs it.
- `Money(amount: Int, currency: String, formatted: String)`
- `TrendingEscape(id, airport, tags, startingPrice, imageName)`
- `RecentSearch(id, originCode, destinationCode, dateRange)`
- `TripType`: `oneWay`, `roundTrip`, `multiCity`
- `CabinClass`: `economy`, `premiumEconomy`, `business`, `first`; exact labels.
- `TravelerCounts(adults: 1, children: 0, infants: 0)`
- `FlightSearchQuery`: trip type, nonoptional origin/destination/departure, optional return, travelers, cabin class. Do not invent multi-city legs.
- `HomeContent`: exact display-string fields and arrays from Kotlin.
- `MultiCityLegUiState`: optional origin/destination/date, `originAutoLinked = false`.
- `HomeValidationError`: all eight lower-camel cases.
- Minimal validator-required `HomeUiState` only; do not port sheets/services/events/factories.

Use value conformances per conventions; every non-private declaration gets `///` summary.

## Traveler behavior

- `total` and `summary()` use raw stored values until caller normalizes.
- `normalized()` exact order: adults clamp 1...9; children clamp 0...(9-adults); infants clamp >=0, <= adults, <= remaining seats.
- `summary()` always adults, conditionally children/infants, separator ` · `, exact singular/plural words.
- Prove negative counts, >9 adults, remaining-seat priority, infant caps, idempotence, singular/plural/order.

## Multi-city behavior

- Initial state always two legs; second origin auto-links destination; second date is first +7 days; nil stays nil.
- Origin selection replaces matching leg and clears auto-link. Invalid index no-op, matching Kotlin `mapIndexed`.
- Destination selection updates selected leg; next origin updates only when nil/auto-linked and becomes auto-linked.
- Date selection propagates nondecreasing dates through all later legs: nil/earlier becomes prior date; equal/later stays.
- Add: valid invariant is 2...3 legs; at 3 unchanged; append previous destination/date and auto-link flag.
- Remove: at <=2 unchanged; invalid index unchanged; otherwise remove only, no relinking.
- Kotlin direct-index crashes are unsafe API behavior. Swift uses no-op for invalid destination/date/add-empty inputs; record explicit safety deviation and test it. No `precondition` crash API.
- Trip-type transition: entering multi-city initializes only when legs empty; leaving/re-entering preserves; switching one-way clears only return-before-departure error.

## Validation

Use injected `today: LocalDate` in tests/API; no global clock abstraction.

Normal precedence:

1. missing origin
2. missing destination
3. same case-sensitive code
4. missing departure
5. departure before today
6. one-way valid and ignores return
7. round-trip missing return
8. return must be strictly after departure; equal/before -> `returnBeforeDeparture`

Multi-city bypasses top-level route/date fields:

1. count outside 2...3 invalid
2. each leg in order needs origin/destination/date, different case-sensitive codes, date >= today, and nondecreasing versus previous
3. all failures collapse to `invalidMultiCityLegs`; equal dates valid.

## `HomeUiState` defaults

Mirror validator/multi-city fields and defaults: loading true, user `Traveler`, one-way, nil route/dates, default travelers, empty age arrays/legs/content/airports, economy, empty airport query, nil validation/message, searching false. Exclude `HomeSheet`, `HomeService`, event/navigation types unless compilation proves required.

## TDD

Windows cannot run Swift. Commit tests first, expected missing symbols; no RED-only push.

RED covers:

- LocalDate validity/ISO/order/addition;
- airport display, cabin labels, model defaults;
- all traveler boundaries/summary/idempotence;
- every transition above including invalid-index safety deviation;
- validation precedence, today/past, round-trip equality, one-way ignored return, multi-city count/field/code/date/order cases.

Commit `PARITY HM-1: add failing home domain contracts`, then smallest production commit. Avoid test-only descriptors/helpers.

## Exclusions

No HomeViewModel, repositories/fakes, async loading/search, auth greeting, airport search, search request/result/codec/mappers, navigation/events, sheets/screens, fallback factories, backend DTOs, or UI.

## Done

- [ ] RED precedes production.
- [ ] LocalDate day semantics pass.
- [ ] Exact shared models/defaults/labels pass.
- [ ] Traveler normalization/summary pass.
- [ ] Multi-city transitions and safe invalid inputs pass.
- [ ] Search validation precedence passes with fixed today.
- [ ] No overlap with AU-1/SR-1 or speculative repository seam.
- [ ] Latest PR-head CI green after coordinator push.
