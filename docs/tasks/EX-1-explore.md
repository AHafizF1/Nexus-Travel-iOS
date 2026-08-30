# EX-1 — Explore list, details, and cache

## Goal

Port Android Explore home, destination detail, package detail, filtering, search handoff, and persistent offline cache against current anonymous backend endpoints.

## Truth sources

- All Android `domain/explore`, `data/explore`, and `feature/explore` Kotlin files.
- Backend content mobile controller, service, repository, DTO, media presenter, fare service, and related tests.
- Existing iOS navigation, HTTP transport, Home search state, design tokens, PORTING and CONVENTIONS.

## Required behavior

- GET anonymous `/api/v1/mobile/explore`, `/explore/destinations/:id`, and `/explore/packages/:id`; ignore additive fields, reject missing required fields, map `404` to unavailable.
- Mirror destination/package/banner models and Android filters: all, packages, destinations.
- Four home/detail states: loading, content, empty, error; refresh preserves content and cancellation preserves prior valid state.
- Persistent cache keyed `explore:home` and `explore:destination:<id>` with exact 10-minute fresh and one-hour stale windows; stale fallback only after network failure; signed image URL cache keys retained.
- Destination detail strips cheapest fare until backend supplies current detail fare; package detail includes destination.
- Destination/package CTAs hand airport code to Home search without inventing booking/package purchase behavior.
- Native SwiftUI, Dynamic Type, accessible images/controls, Android code-derived tokens and strings, no new dependency.

## Tests/evidence

- RED first: exact routes, DTO mapping, missing fields, `404`, cache TTL/cold recreation/stale fallback, filters, state transitions, cancellation, and route handoff.
- Adversarial source comparison after implementation; latest PR-head macOS CI green.
- Device/visual evidence deferred to Phase 8 per user direction.

## Owned paths

- New `Sources/{Domain,Data,Feature}/Explore/`, matching tests, minimal App composition/navigation, PLAN/ARCHIVE reconciliation, this packet.

## Excluded

- Backend edits, admin content, fare-service invention, package checkout, custom image loader, third-party dependencies, Phase 8 device work.
