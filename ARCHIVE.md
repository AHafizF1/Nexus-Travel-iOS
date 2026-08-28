# Nexus Travel iOS archive

Append-only evidence for completed work. An entry is allowed only after PR merge and latest PR-head SHA CI success. Local tests, open PRs, and active work do not qualify.

## P0-1 — Bootstrap reproducible PR verification

- Completed: 2026-08-24
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/1
- Merge commit: `12f7abb`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/32711766001
- Evidence: pinned XcodeGen generated project; Xcode 26.6 built app and passed three Swift Testing deployment-contract tests.
- TDD: run 32708381635 failed because `AppConfiguration` was absent; implementation made same tests pass.
- Adversarial review: corrected XcodeGen release ZIP nesting; retained backend-first network contract and Android-first behavior contract.
- Known deviations: no feature or visual parity claimed by bootstrap task.

## P0-2 — PLAN/ARCHIVE stateless agent workflow

- Completed: 2026-08-26
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/2
- Merge commit: `0cd014a6fbd3df018153213800d28e91fc7e0a9b`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/32962895860
- Evidence: XcodeGen generation, Xcode 26.6 build, and Swift Testing suite passed on latest task SHA.
- Migration audit: all 31 original roadmap IDs preserved exactly once; P0-2 added; every checked task has archive evidence; task links resolve; `git diff --check` passes.
- Adversarial review: removed speculative scheduler, issue bot, machine index, and per-task progress ledgers; PLAN/ARCHIVE are coordinator-only, while detailed packets remain agent-owned execution context.
- Known deviations: Android/backend were not reread because this task changed orchestration documentation only, not product behavior or network contracts.

## DS-1 — Android code-derived design tokens

- Completed: 2026-08-27
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/5
- Merge commit: `aed3e5518740409d8def45715c16810707551b5c`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33060960917
- Evidence: Xcode 26.6 generated project, compiled app, and passed exact color, alias, semantic, scalar, adaptive-spacing, invalid-geometry, and status tests on PR head `dc1efd7`.
- TDD: commit `b582e82` added contracts against missing production symbols before implementation; Windows could not execute Apple-platform tests, so first remote run occurred only after feature completion.
- Adversarial review: zero Kotlin-code mismatches across 27 canonical colors, 69 alias/semantic mappings, 42 scalar tokens, three 16-field adaptive profiles, exact thresholds, and eight status mappings.
- Known deviations: no elevation token because Android Kotlin defines none. No legacy design artifact was used. Theme composition remains DS-3 scope.

## DS-2 — Android typography and Dynamic Type

- Completed: 2026-08-27
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/6
- Merge commit: `c02b5b66a0f0d9bd7fbea03aab3eed084924648e`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33061846353
- Evidence: Xcode 26.6 generated project, compiled app, registered five embedded Plus Jakarta Sans faces, proved accessibility-size scaling, and passed all 26 role/seven tabular-role contracts plus full regression suite on PR head `1ef506a`.
- TDD: commit `77fff7c` added missing typography/font contracts before implementation. First CI exposed Swift Testing macro handling of a `rethrows` expression; commit `1ef506a` isolated the nonthrowing Bool and retry passed.
- Asset integrity: all five copied TTF SHA-256 values match Android sources. Bundled OFL 1.1 normalized text matches official Tokotype source.
- Adversarial review: zero Kotlin-code metric/weight/tabular mismatches; no typography manager, protocol, duplicate Material scale, fixed-size-only font, package, or generated Xcode project edit.
- Known deviations: Apple semantic Dynamic Type roles govern scaling while Android base metrics remain exact. DS-4 supplies visual clipping evidence.

## DS-3 — Native SwiftUI component primitives

- Completed: 2026-08-27
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/7
- Merge commit: `1ad5ca86a5a312013e26f08e06a95ca0735d9df9`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33064276336
- Evidence: Xcode 26.6 generated project, compiled all 12 component APIs, and passed compile-contract plus regression tests on PR head `9f18000`.
- TDD: commit `7d52475` referenced all absent component symbols before implementation; Windows could not execute Apple-platform tests, so remote CI began only after completed feature and adversarial review.
- Adversarial review: Android code-defined loading, disabled, selected, error, focus, status, variant, slot, geometry, color, and typography behavior covered without protocols, managers, type erasure, packages, or generated-project edits.
- Apple deviations: native `ToolbarContent` preserves localized system back/swipe behavior; persistent external field label favors native editing, Dynamic Type, and VoiceOver; native `ProgressView` supplies spinner stroke. DS-4 owns visual/interaction evidence.
- Known limitation: Android components consume static semantic colors and provide no complete code-defined dark-role mapping; no palette was invented.

## DS-4 — Design-system gallery and icon catalog

- Completed: 2026-08-28
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/8
- Merge commit: `98d56b8f0ce77fe278884016134dfe9fe9e253f5`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33068852237
- Evidence: Xcode 26.6 generated project, compiled app, passed exact 50-icon inventory/mapping and gallery contracts, then uploaded reviewed top-light, buttons-light, feedback-light, and feedback-dark simulator captures on PR head `c8a5a89`.
- TDD: RED commits `cecb71b`, `5b32c05`, and `afc209a` established absent icon/gallery, full-width-button, and focused-evidence contracts before their production implementations.
- CI repair loop: fixed ambiguous banner overload, booted test-shutdown simulator, then replaced nondeterministic lazy-grid scrolling with focused reuse of same section views after artifact review exposed wrong captures.
- Adversarial review: exact ordered 50-case Kotlin icon inventory, 16 gallery strings, section/component composition, token geometry, accessible labels, full-width button chrome, four banners, and reachable horizontal chips confirmed. No legacy visual artifact or third-party dependency used.
- Apple deviations: SF Symbols replace Android glyph mechanics; adaptive grid replaces fixed-height nested grid; horizontal chip scrolling prevents narrow-width overflow.
- Known limitation: feedback dark capture matches light because Android code provides only static semantic roles. No dark palette was invented; first product theme task must resolve this from new code truth/ADR.
