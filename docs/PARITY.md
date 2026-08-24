# Parity queue

Status: `☐ queued` · `◐ active` · `☑ complete` · `⊘ blocked`.

Every active row must have `docs/tasks/<ID>-*.md` created from TASK-TEMPLATE before code. Agent owns row through green PR or records genuine blocker.

| ID | Phase | Slice | Android/backend truth | Status |
|---|---:|---|---|---|
| P0-1 | 0 | Docs, task contract, XcodeGen shell, PR CI | AGENTS, backend contract, GitHub/Apple CI docs | ☑ complete |
| DS-1 | 1 | Color, spacing, radius, elevation, motion tokens | `core/designsystem/NexusTokens.kt`, foundation boards | ☐ queued |
| DS-2 | 1 | Typography tokens + Dynamic Type | `NexusTextStyles.kt`, typography board | ☐ queued |
| DS-3 | 1 | Button/text field/top bar/feedback primitives | `core/designsystem/component/*`, anatomy boards | ☐ queued |
| DS-4 | 1 | DesignSystemGalleryScreen | Android gallery + all token boards | ☐ queued |
| AU-1 | 2 | Auth models, validator, error presenter | `domain/auth/*`, `feature/auth/AuthErrorPresenter.kt` | ☐ queued |
| HM-1 | 2 | Home models, multi-city state, search validator | `domain/home/*`, `feature/home/Home*State.kt` | ☐ queued |
| SR-1 | 2 | Search models, codec, display mapper | `domain/search/*`, `NexusSearchIdCodec.kt`, results mapper | ☐ queued |
| FD-1 | 2 | Flight details models + mapper | `domain/flightdetails/*`, feature mapper | ☐ queued |
| BK-1 | 2 | Passenger/booking models + validation | `domain/booking/*`, passenger validation | ☐ queued |
| NT-1 | 3 | App config + HTTP transport classification | backend config/controllers/tests, Android core network | ☐ queued |
| AU-2 | 3 | Keychain session store | Android AuthSessionStore implementations | ☐ queued |
| AU-3 | 3 | Remote auth Adapter + contract fixtures | Better Auth backend + Android RemoteAuthApi | ☐ queued |
| NV-1 | 4 | Route, Router, per-tab NavigationStack shell | `NexusRoutes.kt`, `MainBottomBar.kt`, PORTING §3 | ☐ queued |
| HM-2 | 5 | Home loading/content/empty/error | Android HomeScreen/ViewModel + mockups | ☐ queued |
| SR-2 | 5 | Remote search Adapter | backend flights DTO/controllers/tests | ☐ queued |
| SR-3 | 5 | Search results screen | Android SearchResults* + mockups | ☐ queued |
| FD-2 | 5 | Flight details screen | Android FlightDetails* + mockups | ☐ queued |
| BJ-1 | 6 | Booking journey Module/state transitions | BookingFlowState, MainActivity booking routes | ☐ queued |
| PD-1 | 6 | Passenger details screen + passport upload | Android passenger files + backend passport tests | ☐ queued |
| ST-1 | 6 | Seat selection screen | Android seats + backend seat tests | ☐ queued |
| BR-1 | 6 | Booking review + stable hold idempotency | Android booking review + backend hold tests | ☐ queued |
| PP-1 | 6 | Payment proof signed upload | Android proof + backend upload flow | ☐ queued |
| TR-1 | 7 | Trips list/detail/ticket | Android trips + backend customer-trip tests | ☐ queued |
| PR-1 | 7 | Profile/preferences/security | Android profile + backend profile tests | ☐ queued |
| PR-2 | 7 | CRITICAL async account deletion | backend deletion controller/tests + Apple policy | ☐ queued |
| EX-1 | 7 | Explore list/details/cache | Android explore + backend content tests | ☐ queued |
| QA-1 | 8 | Accessibility and Dynamic Type pass | all screens, anatomy/mockups | ☐ queued |
| QA-2 | 8 | Motion audit/plans/execution | all interactive screens | ☐ queued |
| QA-3 | 8 | Offline/retry/cancellation/performance | transport + all async screens | ☐ queued |
| AS-1 | 9 | Privacy/App Store/TestFlight release gate | current Apple sources + exact archive | ☐ queued |
