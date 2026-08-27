# DS-1: Android code-derived design tokens

## Ownership

- PLAN task: `DS-1`
- Branch: `codex/ds-1-design-tokens`
- GitHub issue: none; this packet is execution contract.
- Expected base: merged coordinator dispatch PR containing this packet and active PLAN wave.
- Wave: Phase 1 / Wave 1, parallel with DS-2.
- Merged dependencies: P0-1, P0-2.
- One agent owns branch through green CI.
- No overlap with DS-2 paths.

## Exclusive ownership

- Allowed production paths:
  - `Sources/Core/DesignSystem/NexusColors.swift`
  - `Sources/Core/DesignSystem/NexusTokens.swift`
  - `Sources/Core/DesignSystem/NexusStatus.swift`
- Allowed test paths:
  - `Tests/Core/DesignSystem/NexusColorsTests.swift`
  - `Tests/Core/DesignSystem/NexusTokensTests.swift`
  - `Tests/Core/DesignSystem/NexusStatusTests.swift`
- Coordinator-owned files — do not edit:
  - `PLAN.md`
  - `ARCHIVE.md`
  - `AGENTS.md`
  - `docs/PORTING.md`
- DS-2-owned/shared interfaces treated as read-only:
  - `project.yml`
  - `Sources/Core/DesignSystem/NexusTextStyles.swift`
  - `Sources/Core/DesignSystem/Resources/Fonts/`
  - `Tests/Core/DesignSystem/NexusTextStylesTests.swift`

## Outcome

Swift exposes exact primitive/semantic color, size, adaptive-spacing, motion, and status values declared by Android Kotlin. Callers stop embedding these values. No elevation API is added because Android code defines no elevation token; inventing one would violate product truth.

## Truth sources — read completely

- `C:\Users\Afiz\Desktop\Nexus-Travel-Android\app\src\main\java\com\nexustravel\app\core\designsystem\NexusColors.kt`
- `C:\Users\Afiz\Desktop\Nexus-Travel-Android\app\src\main\java\com\nexustravel\app\core\designsystem\NexusTokens.kt`
- `C:\Users\Afiz\Desktop\Nexus-Travel-Android\app\src\main\java\com\nexustravel\app\core\designsystem\NexusStatus.kt`
- `AGENTS.md`: Truth sources, architecture/code shape, Swift language/API, Apple interaction rules.
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
- `apple-design` for accessibility-sensitive size/motion semantics only; it must not replace Kotlin token values.

Do not load concurrency, Instruments, App Store, SwiftLint, animation-audit, or SwiftUI-screen skills: this task touches none of their routed concerns.

## Interface and invariants

- Use caseless namespace enums or equally small value namespaces. No singleton lifecycle, DI, protocol, actor, observable model, or package.
- DI naming audit: tokens are dependency-free values, so adding injected containers/managers would violate `docs/CONVENTIONS.md`.
- Follow Swift lower-camel member naming while preserving Kotlin type/concept names: `NexusColors.blue50`, `NexusSpacing.space16`, and so on.
- Dimensional values use `CGFloat`; motion millisecond values remain integer milliseconds. Do not hide exact values behind animation behavior yet.
- Colors use native SwiftUI `Color`. One internal hexadecimal conversion mechanism is allowed; raw color literals remain only in `NexusColors.swift`.
- Preserve alias identity semantically: aliases resolve to canonical properties instead of duplicating literals.
- `NexusSpacingMode` has exactly `.compact`, `.regular`, `.spacious`.
- Adaptive spacing is pure and deterministic. Exact mode boundaries:
  - compact when width `<= 360` OR height `<= 720`
  - spacious when width `>= 430` AND height `>= 840`
  - regular otherwise
- Invalid geometry is outside UI input, but pure resolver must reject non-finite or non-positive values without crashing. Smallest accepted design: failable initializer or documented fallback tested explicitly. Never silently select spacious.
- `NexusStatus` has exactly info, success, warning, error, empty, offline, restored, loading.
- Success/restored share mapping. Status translucent borders preserve alpha `0.28`; overlay scrim preserves alpha `0.60` (`0x99`).
- No elevation/shadow token, theme environment, component, view, preview, animation, or typography in this PR.
- All public declarations receive concise `///` summaries.

## Exact token contract

### Primitive colors

| Member | ARGB |
|---|---|
| blue50 | `FFEAF2FF` |
| blue100 | `FFD8E7FF` |
| blue500 | `FF0B63F6` |
| blue600 | `FF0052CC` |
| blue700 | `FF0046B8` |
| navy950 | `FF07162F` |
| neutral900 | `FF111827` |
| neutral700 | `FF4B5B73` |
| neutral500 | `FF6B7280` |
| neutral300 | `FFDDE6F2` |
| neutral200 | `FFE6EDF7` |
| neutral100 | `FFF3F6FA` |
| white | `FFFFFFFF` |
| background | `FFF8FAFC` |
| success50 / successText | `FFECFDF3` / `FF15803D` |
| warning50 / warningText | `FFFFF7ED` / `FFB45309` |
| error50 / errorText / errorStrong | `FFFEF2F2` / `FFDC2626` / `FFB91C1C` |
| disabledText / disabledBg | `FF9AA7B8` / `FFEEF2F7` |
| overlayScrim | `9907162F` |
| etAirlineGreen / Yellow / Red | `FF2E7D32` / `FFFBC02D` / `FFD32F2F` |

Port every compatibility alias and every `NexusSemanticColors` mapping from Kotlin verbatim by reference to canonical properties. Tests must cover each literal once plus every alias/semantic mapping.

### Scalar tokens

- Spacing: `0, 2, 4, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64`.
- Radius xs/sm/md/lg/xl/xxl/xxxl: `4, 8, 12, 16, 20, 24, 32`.
- Layout screenMargin/screenMarginCompact/inputHeight/buttonHeight/authControlHeight/touchMin/touchRecommended/bottomCtaMinHeight/iconDefault/iconSmall/iconLarge/contentMaxWidth/formMaxWidth: `24, 16, 56, 56, 60, 44, 48, 88, 24, 20, 32, 480, 360`.
- Border hairline/focus/iconStroke/focusOffset: `1, 2, 2, 2`.
- Icon xs/sm/md/lg/xl/xxl: `16, 20, 24, 32, 40, 48`.
- Motion fast/base/sheet/success/shimmer milliseconds: `120, 180, 250, 300, 1400`.

### Adaptive spacing arrays

Property order: screenMargin, screenTopPadding, sectionGap, sectionGapCompact, componentPadding, componentPaddingCompact, formFieldGap, formGroupGap, listGap, rowPaddingH, chipGap, bottomSheetPaddingH, stickyCtaPaddingH, stickyCtaPaddingV, stickyCtaZoneMinHeight, contentBottomPaddingWithCta.

- compact: `16,16,24,16,16,14,12,20,12,16,8,16,16,12,88,112`
- regular: `24,24,32,24,20,16,16,24,16,16,8,24,24,12,96,128`
- spacious: `24,32,40,32,24,20,16,32,16,20,12,24,24,16,104,144`

## TDD proof

Windows cannot run iOS Swift tests. Preserve test-first commit order locally; remote CI starts only after implementation and self-review are complete.

### RED

1. Add smallest table-driven Swift Testing tests referencing missing token APIs.
2. Commit `PARITY DS-1: add failing token contracts`.
3. Record expected missing symbols and why tests fail before implementation in commit/PR evidence.
4. Do not push or open PR yet. No macOS CI run exists solely to prove RED.

Boundary tests required before production code: `(360, 1000) -> compact`, `(1000, 720) -> compact`, `(430, 840) -> spacious`, `(429, 840) -> regular`, `(430, 839) -> regular`, ordinary regular, invalid geometry. Add representative color/alias/status failures in same RED run.

### GREEN

1. Add minimum three production files.
2. Run formatter only if already installed/configured; do not add tooling.
3. Complete adversarial self-review, then push branch and open PR once.
4. Wait for latest PR-head SHA `build-test` green; fix real failures on same branch.
5. Record run URL and test summary in PR body.

### REFACTOR

Only remove duplication visible across three or more declarations. Preserve public names and values. Push and reverify if code changes.

## Acceptance matrix

| Scenario | Input | Expected state/output | Evidence |
|---|---|---|---|
| Color literal | every canonical Kotlin color | exact RGBA components | table-driven unit tests |
| Alias/semantic | every Kotlin alias/mapping | canonical token equality | unit tests |
| Compact boundary | width/height threshold | compact exact array | boundary tests |
| Regular boundary | neither compact nor spacious | regular exact array | boundary tests |
| Spacious boundary | width >= 430 and height >= 840 | spacious exact array | boundary tests |
| Invalid geometry | zero/negative/non-finite | documented safe rejection/fallback | unit tests |
| Status | all eight cases | exact container/content/border | table-driven tests |
| Motion | all five values | exact integer milliseconds | unit tests |
| Loading/empty/offline/cancellation | not stateful/async | N/A; no behavior added | scope review |

## CI gates

- CI generates project: `xcodegen generate`.
- Exact CI test command:

  `xcodebuild test -project NexusTravel.xcodeproj -scheme NexusTravel -destination 'platform=iOS Simulator,name=iPhone 16e,OS=26.2' -resultBundlePath TestResults.xcresult CODE_SIGNING_ALLOWED=NO`

- Required check: latest PR-head SHA `build-test` on `macos-26` with Xcode 26.6.
- No screenshot required; task adds no UI.

## Adversarial review

Fresh pass compares every property and branch against the three Kotlin files. Search new Swift files for numeric/color literals; each must trace to this packet/Kotlin. Confirm no legacy artifact influenced code. List mismatches in PR body; fix all unexplained mismatches.

## PR contract

- Title: `PARITY DS-1: add Android code-derived design tokens`.
- Body links this packet, RED run/error, GREEN run, exact parity review, risks.
- Agent watches latest PR-head SHA CI, reads full failing logs, fixes root cause, and pushes same branch until green.
- Max three recurrences of same root cause; third recurrence reports blocker with logs. Never weaken/delete contract tests.
- Feature agent never edits PLAN/ARCHIVE or merges PR.

## Done

- [ ] Test-first commit records missing production contract before implementation.
- [ ] Exact canonical colors, aliases, and semantic mappings are tested and green.
- [ ] All scalar and adaptive-spacing values are tested and green.
- [ ] Every adaptive boundary and invalid geometry is tested.
- [ ] Every status mapping, including alpha, is tested.
- [ ] No elevation token or excluded artifact appears.
- [ ] Public APIs are documented and minimal.
- [ ] Latest PR SHA has green `build-test`.
