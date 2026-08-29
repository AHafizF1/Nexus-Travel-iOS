# SR-3: Search Results screen

## Ownership and truth

- Branch `codex/sr-3-search-results-screen`; requires SR-1, SR-2, HM-2, NV-1.
- Own `Sources/Feature/SearchResults/**`, smallest search-result dependency/destination wiring under `Sources/App/**` and `Sources/Core/Navigation/**`, matching tests. Do not edit generated Xcode project.
- Read completely: Android `feature/searchresults/{SearchResultsUiState,SearchResultsViewModel,SearchResultsDisplayModels,SearchResultsScreen}.kt`; existing Swift Search domain/display/cache/repositories, AppShell/Router/routes, PORTING and CONVENTIONS.
- Android code is behavioral/visible truth. Legacy/local image assets remain excluded. Use semantic airline identifiers or text fallback; do not port Android drawable logos.
- Apply mandatory Swift/TDD/architecture/concurrency, SwiftUI/Apple design, UX-copy/typography, and project UI polish skills. No dependency.

## ViewModel contract

- Add Android-name-parity `SearchResultsUiState`, `SearchResultsUiEvent`, `SearchResultsNavigationEvent`, and `@MainActor @Observable final SearchResultsViewModel`.
- Init takes `searchId`, role-named `repository`, optional booking-status seam only if an existing production repository already exists; do not invent booking module before BJ-1. Init launches no work. `.task` calls async `loadResults()` with cancellation propagation.
- Preserve exact load transitions/results/copy. Success maps all offers through existing display mapper. `cheapestFirst` defaults sort `.bestPrice` and adds `.bestPrice` filter. Empty, connectivity, timeout, unknown states use exact Android messages.
- Filters compose exactly: non-stop requires every leg 0 stops; one-stop requires any leg 1 stop; morning uses outbound hour 5...11; best-price selection changes sort only when adding. Sorting stays stable for ties. Toggle/sort can produce filtered Empty while retaining all offers and selected controls.
- Retry reloads. Prevent duplicate concurrent reload. Navigation queue is deterministic/non-lossy: back, modify, nearby dates, flight details with complete `FlightOfferReference`. Cancellation never becomes error or leaves loading stuck.

## SwiftUI surface

- Replace `.searchResults` placeholder with `SearchResultsRoute`/`SearchResultsScreen`, model owned in route via `@State`. Keep existing Home tab NavigationStack and hide tab bar on result/details.
- Header: native back, “Search Results”, query summary/edit action, filter/sort horizontal controls. No tappable notification no-op; omit excluded notification destination or render non-actionable labeled indicator only.
- Explicit Loading/Content/Empty/Error states. Loading uses three stable skeleton rows or native progress; any repeated motion stops under Reduce Motion. Content shows count, taxes note, active-filter banner/clear, stable-ID lazy offer rows. Empty/error actions route correctly.
- Offer rows preserve Android information hierarchy: airline name/code fallback + flight number; one-way/round-trip/multi-city leg presentation; OUT/RET labels; times/airports/duration/stops; seats/badges/booking status when present; old/current price/meta; disclosure. Do not show local airline images. Entire row is one accessible button.
- Native sheet/menu for sort is preferred over cycling only if it preserves all four options and current selection. Filters are accessible toggle controls. Clear filters must clear atomically, not emit unordered toggles.
- Dynamic Type must not clip; compact widths may stack. Semantic tokens only; no raw colors/font/spacing/motion values outside DesignSystem. Support Dark Mode, VoiceOver, Reduce Motion, Increased Contrast.

## Navigation and dependency wiring

- Share existing `SearchResultsCache` created by AppDependencies. Search Results repository must read that exact instance so Home-created search IDs resolve without network duplication.
- Extend `FlightDetailsRoute` to carry complete `FlightOfferReference`; update route inventory tests. Result selection pushes typed flight-details route. Back/modify pop to retained Home. Nearby dates currently has no destination screen: pop to retained Home and record boundary; do not invent UI.
- App destination must construct one model per route identity without recreating it during body updates. Gallery launch remains isolated from production dependencies.

## TDD and acceptance

- Tests-only RED commit first, then minimum GREEN. Cover defaults/count grammar; load success/empty/network/timeout/unknown/thrown/cancellation; cheapest defaults; every filter add/remove combination; best-price sort coupling; all stable sort modes/ties; filtered empty recovery; retry/duplicate-load; all navigation events exactly once; complete reference routing.
- Construct Loading/Content/Empty/Error screens and controls without private-view snapshots. Verify accessibility labels for row, back, edit, filters, sort, retry and empty actions; large content does not rely on one-line clipping.
- Adversarially compare every state, copy, filter, sort, result-row field, trip-type layout, and event to Android. Record Apple adaptations in PR evidence.
- Latest PR SHA must compile Swift 6 and pass full tests/gallery CI. Windows cannot claim visual/device verification.

## Exclusions

- No legacy/local images, booking-status backend/module, flight-details UI, modify-search editor, nearby-dates UI, notifications, new network request, persistence, analytics, backend edits, or third-party packages.
