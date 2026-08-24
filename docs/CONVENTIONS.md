# Swift conventions

AGENTS.md is controlling policy. This file adds implementation-level defaults.

## Files and names

- Mirror Android type/file names 1:1 unless PORTING.md explicitly deletes Android-only machinery.
- One primary type per file. Keep tiny private support types beside owner.
- Folder structure: `Sources/{App,Core,Domain,Data,Feature}` and matching `Tests/` path.

## Modules

- Feature ViewModel owns presentation state and orchestration when it has real behavior.
- Repository Interface represents domain outcomes. Fake and remote Adapters satisfy same seam.
- Shared transport owns HTTP mechanics only. Domain mapping remains in repository Adapter.
- No protocol for one implementation except pre-justified fake/remote repository seams.

## State

- Model mutually exclusive states with enum associated values.
- `@MainActor @Observable final class` for ViewModels and routers.
- `struct`/`enum` plus `Sendable` for data crossing isolation domains.
- View owns root observable model with `@State`; child receives explicit property.

## Errors

- Repository Interfaces return mirrored result enums; do not expose transport errors or throw across domain seam.
- Never collapse cancellation into error state.
- Never expose ownership-hidden `404` distinction.

## Tests

- Swift Testing for unit/contract/state-transition tests.
- XCTest only for UI automation and performance metrics.
- Test name states one behavior. RED evidence recorded in task/PR.
- Contract fixtures derive from backend DTO/controller/e2e truth.

## Formatting

- Four-space indentation. One statement per line. No force unwrap/try.
- Public declarations documented. Internal obvious code needs no narration comments.
- SwiftLint config arrives only through accepted ADR and pinned version.
