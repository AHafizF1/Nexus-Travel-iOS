# NV-1: Typed app shell and independent tab navigation

## Ownership and truth

- Branch `codex/nv-1-app-shell`; requires merged AU-3.
- Own `Sources/Core/Navigation/**`, `Sources/App/NexusApp.swift`, and matching `Tests/Core/Navigation/**` tests. Touch `project.yml` only if a compiler setting required by existing conventions is absent; regenerate project, never edit `.xcodeproj`.
- Android truth: `core/navigation/NexusRoutes.kt`, `core/navigation/MainBottomBar.kt`, and `MainActivity.kt`, read completely before Swift. Apple interaction rules may change mechanics while preserving product routes and tab intent.
- Use mandatory Swift, TDD, architecture/DRY, SwiftUI, Apple design, and UI quality skills. Android Kotlin code is sole visual/product truth; no legacy assets.

## Required model

- Mirror Android names: `MainTab` cases home/explore/trips/profile; route value types `HomeRoute`, `ExploreRoute`, `DestinationDetailRoute`, `PackageDetailRoute`, `TripsRoute`, `TripDetailRoute`, `ProfileRoute`, `EditProfileRoute`, `SavedTravelersRoute`, `SettingsRoute`, `LanguageRoute`, `CurrencyRoute`, `ThemeRoute`, `HomeAirportRoute`, `NotificationSettingsRoute`, `SecurityRoute`, `DeleteAccountRoute`, `MainAuthRoute`, `SearchResultsRoute`, `FlightDetailsRoute`, `PassengerDetailsRoute`, `BookingAuthRoute`, `SeatSelectionRoute`, `BookingReviewRoute`, `PaymentProofRoute`; `ExploreFilter` all/packages/destinations with matching visibility rules.
- Routes are immutable `Hashable & Sendable` values. Associated IDs remain nonblank-preserving data; validation belongs to owning feature/adapter, not router.
- `Router` is one `@MainActor @Observable final` app-owned reference. It owns selected tab plus four independent typed paths. No singleton, service locator, notification bus, or environment-global mutable state.
- Selecting another tab preserves every path. Selecting current tab pops that tab to root, matching native tab-bar convention. `push`, `pop`, and `popToRoot` affect only selected tab. Empty-path pop is safe no-op.
- Model auth return intent explicitly as optional pending tab. Completing main auth selects pending tab or Home, clears intent, and leaves unrelated histories intact. Booking auth returns to current booking path; no auth UI/network work enters NV-1.

## SwiftUI shell

- App owns router with `@State`. Render native `TabView` with exactly four tabs and one `NavigationStack` per tab, bound to that tab's path. Use system tab semantics, SF Symbols mapped from Android icon intent, safe areas, Dynamic Type, VoiceOver labels, and existing design tokens only.
- Root content and destination rendering enter through small explicit view-building seams so later feature tasks replace them without changing router mechanics. Production shell may show restrained semantic unavailable content for not-yet-implemented roots, but no lorem, beta/debug/test copy, fake data, or navigation dead controls.
- Keep existing design-system gallery reachable only through its explicit launch argument. Default launch enters app shell.
- No custom bottom-bar clone, custom animation, deep-link parser, persistence/restoration serialization, split view, social auth, feature ViewModels, repository calls, or third-party dependency.

## TDD and acceptance

- Tests-only RED commit before production symbols. Cover complete route inventory and payload equality; ExploreFilter rules; initial Home selection/empty paths; independent histories; cross-tab retention; reselect-to-root; selected-path push/pop/root; safe empty pop; pending-auth completion/fallback/clearing; unrelated-history preservation.
- SwiftUI structure contract verifies four native tabs/stacks and gallery argument preservation where stable without brittle pixel/string-source tests. Prefer state tests over UI implementation inspection.
- Adversarial pass compares every Android route/tab and root-tab behavior. Record intentional Apple difference: independent stacks plus current-tab reselect pop.
- Feature-complete push once; latest-SHA macOS CI must compile and pass all tests before merge. Simulator evidence remains Phase 4 exit gate if CI cannot prove interaction history visually.
