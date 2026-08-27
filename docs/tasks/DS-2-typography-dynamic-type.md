# DS-2: Android typography with Dynamic Type

## Ownership

- PLAN task: `DS-2`
- Branch: `codex/ds-2-typography-dynamic-type`
- GitHub issue: none; this packet is execution contract.
- Expected base: merged coordinator dispatch PR containing this packet and active PLAN wave.
- Wave: Phase 1 / Wave 1, parallel with DS-1.
- Merged dependencies: P0-1, P0-2.
- One agent owns branch through green CI.
- No overlap with DS-1 paths.

## Exclusive ownership

- Allowed production paths:
  - `Sources/Core/DesignSystem/NexusTextStyles.swift`
  - `Sources/Core/DesignSystem/Resources/Fonts/plus_jakarta_sans_regular.ttf`
  - `Sources/Core/DesignSystem/Resources/Fonts/plus_jakarta_sans_medium.ttf`
  - `Sources/Core/DesignSystem/Resources/Fonts/plus_jakarta_sans_semibold.ttf`
  - `Sources/Core/DesignSystem/Resources/Fonts/plus_jakarta_sans_bold.ttf`
  - `Sources/Core/DesignSystem/Resources/Fonts/plus_jakarta_sans_extrabold.ttf`
  - `Sources/Core/DesignSystem/Resources/Fonts/OFL.txt`
  - `project.yml` only for font resource registration.
- Allowed test paths:
  - `Tests/Core/DesignSystem/NexusTextStylesTests.swift`
- Coordinator-owned files — do not edit:
  - `PLAN.md`
  - `ARCHIVE.md`
  - `AGENTS.md`
  - `docs/PORTING.md`
- DS-1-owned/shared interfaces treated as read-only:
  - `Sources/Core/DesignSystem/NexusColors.swift`
  - `Sources/Core/DesignSystem/NexusTokens.swift`
  - `Sources/Core/DesignSystem/NexusStatus.swift`
  - their tests.

## Outcome

All Android `NexusText.styles` roles exist in Swift with exact base size, line height, weight, and tabular-number intent. Five Plus Jakarta Sans font files are copied byte-for-byte from Android resources, registered through XcodeGen config, and scale through Dynamic Type using native relative text styles.

## Truth sources — read completely

- `C:\Users\Afiz\Desktop\Nexus-Travel-Android\app\src\main\java\com\nexustravel\app\core\designsystem\NexusTextStyles.kt`
- `C:\Users\Afiz\Desktop\Nexus-Travel-Android\app\src\main\java\com\nexustravel\app\core\designsystem\NexusTheme.kt`
- `C:\Users\Afiz\Desktop\Nexus-Travel-Android\app\src\main\res\font\plus_jakarta_sans_regular.ttf`
- same font folder: medium, semibold, bold, extrabold files.
- Official license source only: `https://github.com/tokotype/PlusJakartaSans/blob/master/OFL.txt`.
- `AGENTS.md`: truth, Swift API, SwiftUI/Apple interaction, verification gates.
- `docs/PORTING.md`: sections 0 and 1.
- `docs/CONVENTIONS.md`: complete file.
- Excluded: every legacy PNG, mockup, board, PDF, DOCX, and handbook. Do not open or cite them.

## Required skills

- `ponytail`
- `write-swift`
- `swift-expert`
- `swift-api-design-guidelines`
- `improve-codebase-architecture`
- `code-structure`
- `dry-principle`
- `swift-architecture`
- `test-driven-development`
- `swiftui-ui-patterns` plus its theming guidance
- `apple-design`
- `ui-typography`

Do not load concurrency, Instruments, App Store, SwiftLint, motion-audit, or copy skills: this task adds no async behavior, tooling, animation, or user-visible strings.

## Interface and invariants

- Preserve Android type/concept names: `NexusTravelTextStyles`, `NexusText`, and every role name.
- Prefer one immutable `NexusTextStyle` value descriptor carrying only data/components views need: custom font identity/weight, base size, line height, Dynamic Type relative role, and tabular-number flag.
- DI naming audit: typography is a dependency-free value catalog, so adding injected font managers/services would violate `docs/CONVENTIONS.md`.
- `NexusTravelTextStyles` contains exactly 26 named role properties from Kotlin. `NexusText.styles` is sole shared catalog.
- Expose native SwiftUI `Font` from descriptor or a minimal view modifier. Do not build a typography manager, environment object, protocol, or UIKit wrapper hierarchy.
- Dynamic Type is mandatory. Custom fonts use native scaling relative to a semantically appropriate Apple `Font.TextStyle`; fixed-size-only `Font.custom(...fixedSize:)` is forbidden.
- Base values stay exact Android numbers at default content size. Accessibility categories may scale them.
- Preserve intended line height without hardcoding per-screen padding. If SwiftUI cannot guarantee exact absolute line height after scaling, store base line height and derive proportional line spacing at use site; document behavior and test metadata.
- Roles marked `.tabular()` in Kotlin set tabular-number intent: priceAmount, priceAmountSmall, flightTime, flightTimeCompact, durationStop, bookingReference, ticketNumber.
- Five source TTF files must be byte-for-byte copies, not downloads or substituted packages.
- Distribution must bundle official SIL Open Font License 1.1 text at `Sources/Core/DesignSystem/Resources/Fonts/OFL.txt`; license source does not control design values.
- Register filenames through `project.yml` `UIAppFonts`; never edit generated `NexusTravel.xcodeproj` or generated Info.plist directly.
- A simulator unit test must prove each expected custom face resolves through `UIFont(name:size:)`. If actual PostScript names differ from filenames, inspect registered faces and use actual embedded metadata—never guess silently.
- No colors, components, strings, theme environment, previews, or screens in this PR.
- All public declarations receive concise `///` summaries.

## Exact style contract

| Role | Weight | Size | Line height | Tabular |
|---|---:|---:|---:|---:|
| displayHero | bold | 36 | 44 | no |
| displayHeroCompact | bold | 32 | 40 | no |
| screenTitle | bold | 24 | 32 | no |
| sectionTitle | bold | 20 | 28 | no |
| sectionTitleSmall | semibold | 18 | 24 | no |
| listTitle | semibold | 16 | 22 | no |
| listTitleLarge | semibold | 18 | 24 | no |
| body | regular | 16 | 24 | no |
| bodyLarge | regular | 18 | 28 | no |
| bodySmall | regular | 14 | 20 | no |
| caption | medium | 12 | 16 | no |
| label | medium | 14 | 18 | no |
| formInput | regular | 17 | 24 | no |
| button | semibold | 16 | 20 | no |
| link | semibold | 16 | 22 | no |
| priceAmount | extrabold | 28 | 34 | yes |
| priceAmountSmall | extrabold | 23 | 29 | yes |
| currencyLabel | medium | 12 | 16 | no |
| flightTime | bold | 22 | 28 | yes |
| flightTimeCompact | bold | 21 | 27 | yes |
| airportCode | bold | 18 | 24 | no |
| durationStop | medium | 14 | 18 | yes |
| bookingReference | bold | 18 | 24 | yes |
| ticketNumber | semibold | 16 | 22 | yes |
| statusBadge | semibold | 12 | 16 | no |
| errorText | medium | 14 | 20 | no |

`NexusTheme.kt` also maps Material typography roles. Do not add duplicate Swift catalogs for those aliases in DS-2; Swift callers use semantic `NexusText.styles` roles above. This avoids two sources for same values.

## Dynamic Type mapping guidance

Use smallest semantic mapping that preserves hierarchy:

- displayHero/displayHeroCompact -> `.largeTitle`
- screenTitle -> `.title`
- sectionTitle -> `.title2`
- sectionTitleSmall/listTitleLarge/price amounts -> `.title3`
- body/bodyLarge/formInput -> `.body`
- bodySmall/errorText/durationStop -> `.subheadline`
- caption/currencyLabel/statusBadge -> `.caption`
- label/button/link/listTitle/ticketNumber -> `.headline`
- flightTime/flightTimeCompact/airportCode/bookingReference -> `.title3`

Treat mapping as Apple scaling behavior, not replacement base typography. Tests assert chosen mapping remains stable.

## TDD proof

Windows cannot run iOS Swift tests. Preserve test-first commit order locally; remote CI starts only after implementation and self-review are complete.

### RED

1. Add table-driven Swift Testing contract for all 26 absent style roles plus font registration.
2. Commit `PARITY DS-2: add failing typography contracts`.
3. Record expected missing symbols and why tests fail before implementation in commit/PR evidence.
4. Do not push or open PR yet. No macOS CI run exists solely to prove RED.

Tests must assert exact base size, line height, weight/face, relative Dynamic Type role, tabular flag, all role names, and five registered font faces.

### GREEN

1. Copy five fonts from Android paths without transforming them.
2. Add smallest descriptor/catalog implementation.
3. Add `UIAppFonts` filenames in `project.yml`; regenerate only in CI/local Mac. Do not commit generated project.
4. Complete adversarial self-review, then push branch and open PR once.
5. Wait for latest-SHA `build-test` green; fix real failures on same branch.
6. Record run URL and test summary in PR body.

### REFACTOR

Only remove proven catalog duplication. Do not derive unrelated roles from each other merely because current numbers match.

## Acceptance matrix

| Scenario | Input | Expected state/output | Evidence |
|---|---|---|---|
| Catalog parity | 26 Kotlin roles | exact weight/size/line-height | table-driven unit test |
| Tabular parity | seven marked roles | flag true only for those seven | unit test |
| Dynamic Type semantics | each role | stable relative Apple role | unit test |
| Font resources | five Android TTFs | registered faces resolve | simulator unit test |
| Resource integrity | copied files | byte-for-byte source match | SHA-256 values in PR evidence |
| Font license | official OFL text | notice committed beside distribution source | file review + source link |
| Large accessibility size | scaled custom font | larger than default, no fixed-size API | simulator test or Mac evidence |
| Loading/empty/failure/offline/cancellation | not stateful/async | N/A; no behavior added | scope review |

## CI gates

- CI generates project: `xcodegen generate`.
- Exact CI test command:

  `xcodebuild test -project NexusTravel.xcodeproj -scheme NexusTravel -destination 'platform=iOS Simulator,name=iPhone 16e,OS=26.2' -resultBundlePath TestResults.xcresult CODE_SIGNING_ALLOWED=NO`

- Required check: latest-SHA `build-test` on `macos-26` with Xcode 26.6.
- No screenshot required; DS-4 gallery will visually exercise typography.

## Adversarial review

Fresh pass compares every role and font resource against Kotlin/code assets. Confirm 26 roles, seven tabular flags, five font files, exact values, native scaling, no generated project edits, no legacy artifact use. Record SHA-256 hashes for source/copy pairs and every mismatch in PR body.

Expected Android source SHA-256 values:

- bold: `5F5342EF76862B5B5365D1DFF1A667629DFA484E388DD602552F647219C3870F`
- extrabold: `F95AF252ACB2A09E79452366D05346975E7FDA7E0A5831FF671EFFCB2568504C`
- medium: `C77BAB757D7402EC6D9341D5F7DDAAFB2474E17026792697BA4624C7DC89CAF7`
- regular: `BD6276D4060E3B1EBC45047469E0BB86B08F301BA681CDF1CEB6245EA10478D2`
- semibold: `65DBCEDB6596A41C30869729EB31CB57D1F5EDFE365684314BBA8A1994EAA4CB`

## PR contract

- Title: `PARITY DS-2: add Android typography and Dynamic Type`.
- Body links this packet, RED run/error, GREEN run, font hashes, parity review, risks.
- Agent watches latest-SHA CI, reads full failing logs, fixes root cause, and pushes same branch until green.
- Max three recurrences of same root cause; third recurrence reports blocker with logs. Never weaken/delete contract tests.
- Feature agent never edits PLAN/ARCHIVE or merges PR.

## Done

- [ ] Test-first commit records missing production contract before implementation.
- [ ] All 26 role metadata contracts are green.
- [ ] Seven tabular roles and only those roles are marked.
- [ ] Five TTFs match Android source hashes and resolve at runtime.
- [ ] Official OFL 1.1 notice is committed.
- [ ] Dynamic Type relative mapping is tested; no fixed-size-only font API.
- [ ] `project.yml` registers fonts; generated project remains untracked.
- [ ] Public APIs are documented and minimal.
- [ ] Latest PR SHA has green `build-test`.
