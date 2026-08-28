# DS-4: Design-system gallery and icon catalog

## Ownership

- PLAN task: `DS-4`
- Branch: `codex/ds-4-gallery`
- Base: merged DS-3 commit `1ad5ca8`.
- Coordinator owns PLAN, ARCHIVE, packet, push, PR, CI loop, merge.
- Feature agent must not edit coordinator-owned files.

## Exclusive ownership

- Production:
  - `Sources/Core/DesignSystem/Icon/NexusIcon.swift`
  - `Sources/Core/DesignSystem/Gallery/DesignSystemGalleryScreen.swift`
  - `Sources/App/NexusApp.swift` only to make gallery reachable during Phase 1.
  - `Sources/Core/DesignSystem/Component/NexusButton.swift` only for an opt-in `fillsWidth` input proven by Android gallery callers.
  - `.github/workflows/ios.yml` only to capture light/dark gallery screenshots after successful tests using already-booted simulator.
  - DS-3 empty-accessory fix already committed as `fe515d0`; review but do not broaden it.
- Tests:
  - `Tests/Core/DesignSystem/Icon/NexusIconTests.swift`
  - `Tests/Core/DesignSystem/Gallery/DesignSystemGalleryContractsTests.swift`
- Read-only: all other production/tests, `project.yml`, generated project, PLAN, ARCHIVE, packet, conventions.

## Outcome

Native SwiftUI `DesignSystemGalleryScreen` mirrors Android code-defined gallery sections, labels, component examples, status data, spacing, safe-area behavior, and icon inventory. Gallery becomes temporary app root so macOS simulator CI can compile it and later Mac evidence can inspect Dynamic Type, accessibility, and component parity. No legacy visual artifact controls any value.

## Truth sources -- read completely

- Android `core/designsystem/gallery/DesignSystemGalleryScreen.kt`.
- Android `core/designsystem/icon/NexusIcon.kt`.
- DS-1/DS-2/DS-3 Swift production and tests.
- `AGENTS.md`, `docs/PORTING.md`, `docs/CONVENTIONS.md`.
- Excluded: PNG, mockup, board, PDF, DOCX, handbook, screenshot.

## Required skills

Use `ponytail`, `write-swift`, `swift-expert`, `swift-api-design-guidelines`, `test-driven-development`, `swiftui-ui-patterns`, `apple-design`, `design-system`, `design-taste-frontend`, `emil-design-eng`, `impeccable`, `ux-copy`, `ui-typography`, `improve-codebase-architecture`, `code-structure`, `dry-principle`, and `swift-architecture`. No concurrency, motion-audit, Instruments, App Store, or SwiftLint work exists.

## Icon contract

- Mirror exact `NexusIconName` type and all 50 Kotlin cases in Swift lower-camel spelling.
- Each case maps once to closest semantically equivalent native SF Symbol name. Mapping may change glyph mechanics for Apple idiom but not product meaning.
- `NexusIcon` is smallest SwiftUI view wrapper around `Image(systemName:)`; accepts name and optional accessibility label. Nil label makes decorative image accessibility-hidden; nonnil label exposes that label.
- Default rendering remains caller-controlled through `foregroundStyle`; no tint manager, protocol, image asset, package, or custom SVG.
- Tests assert exact case count, unique case raw names, nonempty SF Symbol mapping, and construction of decorative/labeled forms. Simulator evidence later confirms symbol resolution; do not use legacy image assets.

## Gallery contract

- Exact visible copy from Kotlin:
  - `Nexus design system`
  - `Debug gallery`
  - `Icons`, `Buttons`, `Feedback`
  - button labels and four `GalleryStatus` labels/messages exactly as source.
- Layout:
  - scrollable full-screen page, page background, safe-area aware;
  - horizontal 24, top 24, section gap 24;
  - header internal gap 8;
  - adaptive icon grid with minimum cell width 64, horizontal/vertical gap 12;
  - icon tile surface, radius `md`, padding 12, gap 8, 24-point icon, one-line case label;
- buttons vertical gap 12; primary/secondary full width; matching leading icons;
  - feedback renders four banners then horizontally scrollable/wrapping-safe chips. Android Row overflows narrow width; Apple deviation must keep all chips reachable without clipping.
- Use `NexusText.styles.screenTitle`, `.body`, `.sectionTitle`, `.caption` as closest existing explicit roles instead of inventing Material aliases.
- Use native `ScrollView`, `LazyVGrid`, `GridItem(.adaptive(minimum:))`, safe-area padding, buttons, and components.
- `GalleryStatus` stays private value enum/data. No ViewModel: gallery has no mutable business state/effects.
- `NexusApp` temporarily launches gallery directly. Comment one sentence that Phase 4 app shell replaces root; no debug flag/config layer now.
- Gallery accepts an internal evidence-section value (`top`, `buttons`, `feedback`). `top` renders full Android gallery; focused modes compose only same existing section views for deterministic CI screenshots. App reads one explicit process argument only for this temporary Phase 1 gallery root. Do not duplicate section implementations.
- Primary/secondary button API may add `fillsWidth: Bool = false`; when true, styled label/background accepts full proposed width. Default preserves intrinsic-width callers. Do not redraw button chrome in gallery.
- No custom animation. No async states. No backend access.

## CI visual evidence

- Reuse simulator already booted by `xcodebuild test`; do not add UI-test target or second build.
- After tests pass: create evidence directory; capture top, buttons, and feedback in light appearance plus feedback in dark appearance by relaunching with deterministic initial-section arguments.
- Upload four PNGs as `DesignSystemGalleryEvidence` on successful DS-4 run. Screenshot capture failure must fail job; evidence is gate, not best effort.
- Keep commands direct and deterministic. No arbitrary long sleeps; poll launched app/readiness only if first run proves capture races.
- Future app-root changes may remove/replace this temporary gallery capture in their own task.

## Accessibility and Dynamic Type

- Icon tiles label icon once; decorative button/banner/chip icons are hidden so enclosing text/control carries meaning.
- Long labels/messages wrap; no fixed text height. Icons retain touch/accessibility behavior through components.
- Grid adapts to width. Large accessibility sizes may reduce columns; content stays reachable.
- Dark Mode uses existing static Kotlin-defined semantics only. Do not invent missing dark roles. Record limitation.

## TDD

Windows cannot run iOS tests. Keep RED local and do not trigger CI until feature complete.

### RED

1. Add tests referencing absent `NexusIconName`, `NexusIcon`, and `DesignSystemGalleryScreen`.
2. Assert exact 50-case inventory/mapping metadata plus gallery construction.
3. Commit `PARITY DS-4: add failing gallery contracts`.

### GREEN

1. Add smallest icon catalog/gallery/root wiring.
2. Static/adversarial review against both Kotlin files.
3. Push completed branch once; open PR; repair same-branch CI until latest head green.

No ViewInspector, Mirror, snapshots, test-only presentation descriptors, package, or RED-only PR.

## Acceptance

| Case | Expected | Evidence |
|---|---|---|
| Icon inventory | exact 50 Kotlin names, one native mapping each | table-driven test |
| Decorative/labeled icon | hidden versus one label | API compile + later VoiceOver |
| Gallery sections/copy | exact Kotlin source strings | source review + simulator |
| Adaptive grid | content reachable across widths/Dynamic Type | simulator evidence |
| Component examples | exact buttons, four banners, four chips | compile + simulator |
| Full-width buttons | opt-in primary/secondary fill includes background/border | compile + simulator |
| Dark Mode | no invented palette; limitation visible/documented | simulator evidence |
| Legacy artifacts | never read/used | scope review |

## CI and PR

- PR title: `PARITY DS-4: add design-system gallery and icon catalog`.
- Required latest-head check: `build-test` on `macos-26`, Xcode 26.6.
- CI command remains repository workflow `xcodegen generate` + `xcodebuild test` on iPhone 16e iOS 26.2.
- PR body records RED commit, native-symbol deviations, full Android comparison, DS-3 spacing fix, dark limitation, CI URL.
- Visual parity gate requires CI-produced light/dark simulator screenshots reviewed against Android code-defined states before merge/archive. CI green alone proves commands completed, not pixels; coordinator must download and inspect artifact.

## Done

- [ ] Test-first commit precedes production.
- [ ] 50 icon names and mappings pass.
- [ ] Gallery exact content/sections/components compile.
- [ ] Temporary app root opens gallery.
- [ ] Accessibility/Dynamic Type layout has simulator evidence.
- [ ] Top, buttons, feedback, and dark evidence reviewed; DS-3 empty-accessory fix remains logically reviewed and gets visual proof in first field screen.
- [ ] Latest PR-head CI green.
- [ ] Mac visual evidence linked before PLAN `[x]` and ARCHIVE entry.
