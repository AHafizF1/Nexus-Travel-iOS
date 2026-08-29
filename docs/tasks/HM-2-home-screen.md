# HM-2: Home screen and orchestration

## Ownership and truth

- Branch `codex/hm-2-home-screen`; requires HM-1, NV-1, HD-1, SR-2.
- Own `Sources/Feature/Home/**`, smallest production dependency wiring and `AppShell` under `Sources/App/**`, and matching `Tests/Feature/Home/**` / app-wiring tests. Do not edit generated `NexusTravel.xcodeproj`.
- Read completely before Swift: Android `feature/home/{HomeUiState,HomeViewModel,HomeSearchValidator,HomeMultiCityState,HomeScreens}.kt`; every Android design-system token/component referenced by Home; existing Swift Home domain/data, Router/AppShell, auth/search repositories, `PORTING.md`, and `CONVENTIONS.md`.
- Android code is sole visible design/behavior truth. Do not inspect or port legacy images. Replace Android hero drawable with code-defined page background; remote destination images may use native `AsyncImage` because URLs are backend data, not legacy design assets.
- Use mandatory Swift, architecture/DRY, strict-concurrency, TDD, SwiftUI/Apple design, UX-copy/typography, and project frontend-design skills. No new dependency.

## State and ViewModel contract

- Add Android-name-parity `HomeSheet`, `HomeService`, `HomeUiEvent`, `HomeNavigationEvent`, and `@MainActor @Observable final HomeViewModel`. Root owns it with `@State`; child views receive it explicitly.
- Dependencies enter initializer by roles: `homeRepository`, `airportRepository`, `flightSearchRepository`, `authRepository`, `searchValidator`, injected `today` clock. Concrete production root composes existing remote adapters once; no service locator, global mutable state, or protocol added without proven variation.
- Init does not launch unowned work. `load()` is async and called by `.task`; cancellation propagates. Load greeting from local session, airports, then Home. Preserve selected service/sheet across reload. Success uses content; network/unknown use airport fallback plus exact Android messages. Dates derive from injected today (+7/+14), never wall-clock inside tests.
- Match every Android event and transition: service selection; typed sheet presentation; trip type; airport selection/query; swap; date changes; multi-city add/remove/linking; travelers/ages normalization; cabin; trending/recent prefills; prefill origin/destination; validation; search.
- Airport query work cancels prior task and rejects stale response overwrite. View-owned task has explicit cancellation ownership. Cancellation never becomes user message.
- Search builds exact `FlightSearchRequest`; validates before request; only round-trip sends return date; multi-city maps complete ordered legs. Success emits one typed navigation event containing search ID. Network and unknown copy match Android. Prevent duplicate submit while searching.
- Navigation consumption must be deterministic/testable; avoid lossy Boolean flags. Home route maps search success to `.searchResults`, Package to Explore tab/filter using existing Router APIs or smallest explicit Router extension.

## SwiftUI surface

- Replace Home tab placeholder with production `HomeRoute`/`HomeScreen`. Use existing Nexus tokens/components/icons only; no raw colors/font sizes/spacing values outside DesignSystem. Preserve Android composition: greeting, notifications action, Flight/Hotel/Package launcher, expandable search panel, trip selector, fields, search CTA, trending section, recent searches when nonempty.
- Explicit four screen states: loading skeleton/progress; content; empty trending explanation with usable search controls; error/offline banner with Retry. No stub, beta, lorem, or generic “Content unavailable” on Home.
- Use native Apple mechanics: one existing `NavigationStack`; enum `.sheet(item:)`; `DatePicker` instead of custom calendar; native controls where equivalent; immediate press feedback; restrained interruptible transitions; Reduce Motion crossfade/static alternative. No decorative infinite shimmer when Reduce Motion is enabled.
- Sheets: airport search/list/empty, departure/return/multi-city date, travelers with child/infant ages, cabin class, hotel-coming-soon. Sheet dismiss clears query. Keep mutually exclusive presentation in one enum.
- Accessibility: icon-only notification/swap controls labeled; all controls >= tokenized minimum hit target; Dynamic Type wraps without clipping; image accessibility uses destination identity; decorative icons hidden; loading announced; errors readable and associated with fields. Support Dark Mode and increased contrast through semantic tokens.
- Copy matches Android unless Apple tone requires grammar-only adaptation. Required exact error/status messages remain unchanged because tests/backend behavior depend on them.

## Root dependency graph

- Compose one `AppDependencies`/equivalent concrete graph only if it materially shortens `NexusApp`; otherwise initialize concrete role dependencies directly. Share one `HTTPTransport`, `KeychainAuthSessionStore`, `AirportCache`, and `SearchResultsCache` across corresponding adapters.
- `AppShell` accepts Home model/dependency through explicit initializer. Gallery launch stays isolated and must not instantiate production Home work unnecessarily.
- Production origin remains `AppConfiguration.production`. No secrets, preview network, or new environment config.

## TDD and acceptance

- Tests-only RED commit first, then minimum GREEN. Test ViewModel load success/offline/error/empty; greeting; preserved modal/service; every event family; same-airport validation; date correction; traveler normalization/ages; prefill; airport cancellation/stale suppression; search request shapes/results/errors/duplicate prevention/navigation; Router handoff; cancellation.
- Add construction/state tests for loading/content/empty/error and every sheet without snapshotting private SwiftUI structure. Existing 179 tests remain green.
- Adversarial pass compares every event, state default, copy string, route, field, sheet, and edge case against all Android truth. Record intentional Apple adaptations in PR evidence.
- CI gate: generated project compiles under Swift 6 strict concurrency; full `xcodebuild test` and gallery capture green on latest PR SHA. Visual parity and real-device accessibility remain follow-up evidence if unavailable in CI; never claim them verified.

## Exclusions

- No legacy/local image assets, custom calendar, notification screen, Explore/results/details UI, auth UI, analytics, persistence, backend edits, retries, performance claims, or third-party packages.
