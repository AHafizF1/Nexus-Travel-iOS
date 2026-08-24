# P0-1: Bootstrap reproducible PR verification

## Ownership

- PARITY row: `P0-1`
- Branch: `parity/p0-1-bootstrap-ci`
- One agent owns branch through green CI.

## Outcome

Fresh GitHub macOS 26 runner generates project, builds iOS app, runs config contract tests. Pull request cannot claim completion before checks pass.

## Truth sources — read completely

- `AGENTS.md`, `docs/PORTING.md`, accepted ADRs.
- Backend `src/modules/config/app.config.ts`, `src/modules/health/health.controller.ts`, `test/health.e2e.test.ts`.
- Android `app/build.gradle.kts`, `data/common/api/MobileApiRoutes.kt`.
- GitHub runner/status-check docs and Apple xcodebuild CI docs linked in PR.

## Required skills

`ponytail`, `test-driven-development`, `swift-api-design-guidelines`, `write-swift`, `swift-expert`, `swift-concurrency-pro` only if concurrency appears.

## Interface and invariants

- `AppConfiguration` is single source for production origin and route prefixes.
- Production origin: `https://api.travelwithnexus.com`.
- Mobile base path: `/api/v1/mobile`.
- Health path: `/api/v1/health`.
- URL construction rejects malformed config; no force unwrap.

## Scope

Docs, Git/GitHub config, `project.yml`, minimal app shell, `AppConfiguration`, config tests. No feature UI, transport, auth, design tokens, lint dependency.

## TDD proof

1. Commit tests referencing missing `AppConfiguration`; PR CI must fail for missing type. This proves judge catches absence.
2. Add minimum `AppConfiguration`; rerun CI.
3. Do not weaken test or hardcode URL separately in app.

## CI gates

- Runner: `macos-26`; select installed Xcode 26.6.
- Generate with pinned XcodeGen `2.44.1`.
- Build/test on available iPhone 16e iOS 26.2 simulator.
- Upload `.xcresult` on failure.
- Cancel superseded runs per PR branch.

## Done

- [x] RED CI failure observed: [run 32708381635](https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/32708381635).
- [x] GREEN build/test observed: [run 32708474046](https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/32708474046).
- [x] App config contract tests cover origin, mobile base, health path.
- [x] PARITY row complete and PROGRESS appended.
