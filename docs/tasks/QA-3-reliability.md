# QA-3 — Offline, retry, cancellation, and performance validation

## Goal

Audit shipped async flows, fix confirmed stale-state/retry/offline defects, and define honest device profiling evidence without speculative optimization.

## Truth sources

- All iOS async ViewModels, repositories, transport, caches, and their tests.
- Completed feature task contracts plus Android offline/retry behavior.
- Swift 6 strict-concurrency and Apple Instruments requirements.

## Required behavior

- Cancellation restores prior valid state only when request remains current; stale requests never overwrite newer results.
- Retry reuses operation identity where required and preserves valid content during refresh.
- Offline fallback uses only contract-approved fresh/stale caches and reports offline state honestly.
- View-owned unstructured tasks are canceled or superseded at lifecycle/input boundaries.
- No performance claim or optimization without Release/device trace evidence.

## Tests/evidence

- RED first with controllable continuations; no timing-based async tests.
- Latest PR-head macOS build/test green.
- Device gate: Time Profiler, SwiftUI/Hitches, Allocations/Leaks, Network, and Power traces remain required before release.

## Owned paths

- Confirmed async ViewModels/repositories, focused reliability tests, PLAN/ARCHIVE, and this packet.

## Excluded

- New product features, backend edits, third-party dependencies, speculative performance refactors, and claims unsupported by trace/device evidence.
