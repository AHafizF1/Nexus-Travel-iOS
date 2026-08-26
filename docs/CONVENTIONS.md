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

## Dependency injection names

- Constructor injection is default. Initializer labels and stored properties describe product role, not type: `repository`, `sessionStore`, `clock`, `configuration`.
- Context removes repetition: `SearchResultsViewModel(repository:)`, not `SearchResultsViewModel(searchResultsRepository:)`. Add a feature qualifier only when one owner has multiple same-kind dependencies.
- Protocol names are role nouns (`FlightSearchRepository`, `SessionStore`) or capability names ending in `-able`, `-ible`, or `-ing`. Never prefix `I`. Append `Protocol` only to resolve an unavoidable name collision.
- Concrete Adapter names expose mechanism: `RemoteFlightSearchRepository`, `FakeFlightSearchRepository`, `KeychainSessionStore`, `URLSessionTransport`. Never use `Impl`, `Manager`, or `Service` when a precise role exists.
- Stored protocol values spell the existential explicitly: `private let repository: any FlightSearchRepository`. Prefer a concrete type until runtime substitution or an existing fake/remote seam proves variation; do not add generics solely for DI.
- Test-double vocabulary is behavioral: `Fake` provides working deterministic behavior, `Stub` returns canned values, `Spy` records calls. Use `Mock` only for an interaction-verification object.
- Defaults are assembled at app/composition roots, previews, or tests. Feature types never hide production dependency creation in default initializer arguments.
- Pass dependencies explicitly through shallow view trees. Use `@Environment` only for app-wide values/models that distant descendants need; environment properties keep role names, key types stay private, missing required dependencies fail at composition boundary.
- Closure dependencies name event/result role (`onAuthenticated`, `onRetry`, `loadSession`), never `callback`, `closure`, or `handler` without domain meaning.

Primary guidance: [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/), [Swift boxed protocol types](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/opaquetypes/), and [Apple model-data flow](https://developer.apple.com/documentation/SwiftUI/Managing-model-data-in-your-app).

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
