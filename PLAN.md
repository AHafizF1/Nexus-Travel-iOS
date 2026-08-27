# Nexus Travel iOS plan

Single source for roadmap, phases, milestones, dependencies, and live task status.

## Status

- `[ ]` queued
- `[ ] 🔄` active
- `[ ] ⛔` blocked
- `[x]` merged and verified by latest PR-head SHA CI

Only coordinator edits this file. Feature agents follow assigned `docs/tasks/<ID>-*.md` packets and never change task status themselves.

Current phase: **Phase 1 — design system**

Active wave: **DS-2 — typography and Dynamic Type verification**

## Phase 0 — Delivery foundation

Exit gate: reproducible macOS build/test, protected `main`, stateless task workflow.

- [x] [P0-1 — Bootstrap reproducible PR verification](docs/tasks/P0-1-bootstrap-ci.md)
- [x] [P0-2 — PLAN/ARCHIVE stateless agent workflow](docs/tasks/P0-2-parallel-agent-contract.md) — requires P0-1

## Phase 1 — Design system

Milestone: tokens, primitives, and gallery match Android design truth while respecting Dynamic Type and Apple accessibility.

- [x] [DS-1 — Color, spacing, radius, layout, status, and motion tokens](docs/tasks/DS-1-design-tokens.md) — requires P0-2
- [ ] 🔄 [DS-2 — Typography tokens and Dynamic Type](docs/tasks/DS-2-typography-dynamic-type.md) — requires P0-2
- [ ] DS-3 — Button, text field, top bar, and feedback primitives — requires DS-1, DS-2
- [ ] DS-4 — DesignSystemGalleryScreen — requires DS-3

Exit gate: token tests green; gallery screenshots prove Android code-defined states on Mac.

## Phase 2 — Domain models and fakes

Milestone: presentation-independent domain behavior has Swift Testing coverage.

- [ ] AU-1 — Auth models, validator, and error presenter — requires DS-4
- [ ] HM-1 — Home models, multi-city state, and search validator — requires DS-4
- [ ] SR-1 — Search models, codec, and display mapper — requires DS-4
- [ ] FD-1 — Flight details models and mapper — requires DS-4
- [ ] BK-1 — Passenger and booking models with validation — requires DS-4

Exit gate: Swift Testing suite green; no UI or network dependency in domain logic.

## Phase 3 — Transport and authentication

- [ ] NT-1 — App config and HTTP transport classification — requires Phase 2
- [ ] AU-2 — Keychain session store — requires AU-1
- [ ] AU-3 — Remote email/password auth Adapter and contract fixtures — requires NT-1, AU-2

Exit gate: backend contract fixtures green; demo email auth flow verified.

## Phase 4 — App shell and navigation

- [ ] NV-1 — Typed routes, Router, per-tab NavigationStack shell — requires AU-3

Exit gate: independent tab-history and restoration tests green; simulator evidence archived.

## Phase 5 — Search journey

- [ ] HM-2 — Home loading, content, empty, and error states — requires HM-1, NV-1
- [ ] SR-2 — Remote search Adapter — requires SR-1, NT-1
- [ ] SR-3 — Search results screen — requires SR-2, HM-2
- [ ] FD-2 — Flight details screen — requires FD-1, SR-3

Exit gate: Home → search → results → details passes parity, contract, mapper, and UI-state gates.

## Phase 6 — Booking journey

- [ ] BJ-1 — Booking journey Module and valid transitions — requires BK-1, NV-1
- [ ] PD-1 — Passenger details and passport signed upload — requires BJ-1, NT-1
- [ ] ST-1 — Seat selection — requires PD-1
- [ ] BR-1 — Booking review and stable hold idempotency — requires ST-1
- [ ] PP-1 — Payment-proof signed upload — requires BR-1

Exit gate: transition, idempotency, upload, accessibility, and CRITICAL review gates pass.

## Phase 7 — Trips, profile, and explore

- [ ] TR-1 — Trips list, detail, and ticket — requires Phase 3, NV-1
- [ ] PR-1 — Profile, preferences, and security — requires Phase 3, NV-1
- [ ] PR-2 — CRITICAL asynchronous account deletion — requires PR-1
- [ ] EX-1 — Explore list, details, and cache — requires Phase 3, NV-1

Exit gate: offline/cache behavior, ownership-hiding errors, and account-deletion evidence pass.

## Phase 8 — Reliability and polish

- [ ] QA-1 — Accessibility and Dynamic Type pass — requires all screens
- [ ] QA-2 — Motion audit, plans, and later execution — requires all screens
- [ ] QA-3 — Offline, retry, cancellation, and performance validation — requires all async flows

Exit gate: simulator and real-device evidence archived; no unresolved CRITICAL deviation.

## Phase 9 — Release

- [ ] AS-1 — Privacy, App Store, archive, and TestFlight gate — requires Phase 8

Exit gate: current Apple-policy audit, exact Release archive validation, privacy reconciliation, demo credentials, and TestFlight evidence pass.

## Task sizing and dispatch

- One task packet = one branch = one PR = one observable behavior slice.
- Target 0.5–2 agent-hours, normally no more than 8 production and 8 test files.
- Parallel tasks must have merged dependencies and non-overlapping owned paths.
- Coordinator marks `🔄` before dispatch, creates complete packet, then assigns agent.
- Coordinator marks `[x]` and appends `ARCHIVE.md` only after merge and latest PR-head SHA CI success.
