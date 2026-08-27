# DS-3: Native SwiftUI component primitives

## Ownership

- PLAN task: `DS-3`
- Branch: `codex/ds-3-primitives`
- GitHub issue: none; this packet is execution contract.
- Expected base: merged DS-1 and DS-2 on `main`.
- Wave: Phase 1, sequential after DS-1 and DS-2.
- One agent owns branch through local implementation review. Coordinator owns push, PR, CI repair loop, merge, PLAN, and ARCHIVE.

## Exclusive ownership

- Allowed production paths:
  - `Sources/Core/DesignSystem/Component/NexusButton.swift`
  - `Sources/Core/DesignSystem/Component/NexusControls.swift`
  - `Sources/Core/DesignSystem/Component/NexusTextField.swift`
  - `Sources/Core/DesignSystem/Component/NexusTopBar.swift`
  - `Sources/Core/DesignSystem/Component/NexusFeedback.swift`
  - `Sources/Core/DesignSystem/Component/NexusIconButtons.swift`
- Allowed test paths:
  - `Tests/Core/DesignSystem/Component/NexusComponentContractsTests.swift`
- Coordinator-owned files -- feature agent must not edit:
  - `PLAN.md`
  - `ARCHIVE.md`
  - `AGENTS.md`
  - `docs/PORTING.md`
  - `docs/CONVENTIONS.md`
  - this packet after dispatch.
- Shared DS-1/DS-2 files and `project.yml` are read-only.
- Never edit generated `NexusTravel.xcodeproj`.

## Outcome

Reusable native SwiftUI buttons, fields, top bar, icon actions, banner, and status chip preserve Android code-defined product states and measurements while using Apple-native accessibility, focus, navigation, progress, and control semantics. Primitives contain no business logic, network dependency, service layer, theme manager, or third-party package.

## Truth sources -- read completely

- `C:\Users\Afiz\Desktop\Nexus-Travel-Android\app\src\main\java\com\nexustravel\app\core\designsystem\component\NexusButton.kt`
- same component folder: `NexusControls.kt`, `NexusTextField.kt`, `NexusTopBar.kt`, `NexusFeedback.kt`, `NexusIconButtons.kt`.
- `C:\Users\Afiz\Desktop\Nexus-Travel-Android\app\src\main\java\com\nexustravel\app\core\designsystem\NexusTheme.kt`
- representative usage only:
  - `feature/auth/AuthScreens.kt`
  - `feature/searchresults/SearchResultsScreen.kt`
  - `feature/booking/PassengerDetailsScreen.kt`
  - `feature/trips/TripDetailScreen.kt`
  - `core/designsystem/gallery/DesignSystemGalleryScreen.kt`
- `AGENTS.md`: truth, Swift API, SwiftUI/Apple interaction, accessibility, and verification gates.
- `docs/PORTING.md`: complete file before Swift.
- `docs/CONVENTIONS.md`: complete file.
- Excluded: every legacy PNG, mockup, board, PDF, DOCX, handbook, and screenshot. Do not open or cite them.

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
- `swiftui-ui-patterns`
- `apple-design`
- `design-system`
- `emil-design-eng`
- `impeccable`
- `ux-copy`
- `ui-typography`

Do not load concurrency, Instruments, App Store, SwiftLint, or motion-audit skills: this task adds no async work, performance diagnosis, release config, lint config, or motion audit. Native control feedback is enough; no bespoke animation is in scope.

## Architecture and API constraints

- Preserve Android public concept names where Swift grammar permits: `NexusPrimaryButton`, `NexusSecondaryButton`, `NexusTextButton`, `NexusIconButton`, `NexusIconActionButton`, `NexusIconButtonVariant`, `NexusTextField`, `NexusAuthTextField`, `NexusTopBar`, `NexusTopBarTitleAlignment`, `NexusStatusChip`, and `NexusBanner`.
- Prefer concrete SwiftUI `View` structs and value enums for finite variants.
- Add a pure state value only when it directly drives multiple rendering branches. One `isEnabled && !isLoading` expression does not justify `NexusButtonState`; standard/auth fields have different behavior and must not share a false visual-state abstraction.
- Do not add protocols, managers, services, factories, dependency containers, type erasure, `AnyView`, UIKit wrappers, or environment dependencies.
- No injected dependencies exist. Inputs are role-named values and closures: `title`, `text`, `isEnabled`, `isLoading`, `action`, `status`, `requiredHeaders`-style names only where relevant. Avoid vague `config`, `manager`, `service`, or implementation-named labels.
- Prefer native `Button`, `TextField`, `SecureField`, `ProgressView`, `ToolbarItem`, focus state, and accessibility APIs. `NexusTopBar` conforms to `ToolbarContent`; system navigation owns back behavior. Do not reproduce UIKit behavior manually.
- Component parameters may use minimal generic `@ViewBuilder` slots where Android accepts arbitrary composables. Avoid speculative slots not proven by callers.
- Reuse existing token and typography catalogs. No raw color hex, font size, spacing, radius, border, height, icon-size, or motion number in component files when a DS-1/DS-2 token exists.
- Every non-private declaration gets a concise `///` summary. Keep internal by default; no unnecessary `public` surface.
- Theme boundary: Android component code reads static `NexusSemanticColors` directly; no complete code-defined dark semantic mapping exists. Do not invent one or add a shallow theme wrapper. DS-3 uses existing static semantic colors. Record dark-theme limitation as explicit follow-up evidence, not silent invention.
- DS-4 owns gallery/screenshots. DS-3 owns component behavior and structural tests only.

## Exact component contracts

### `NexusPrimaryButton`

- Inputs: title text, action, `isEnabled` default true, `isLoading` default false, optional leading icon/content.
- Native action disabled when `!isEnabled || isLoading`; loading always wins.
- Minimum height `NexusLayout.buttonHeight` (56), radius `NexusRadius.md` (12), horizontal padding 16, vertical padding 12.
- Enabled background/action color; disabled background/action colors from semantic catalog.
- Loading replaces normal label with white 20-point progress indicator. Use tokenized icon sizing/stroke where native API permits; do not fake determinate progress.
- Normal label: optional leading icon, gap 8, title using `NexusText.styles.button`.
- Accessibility: native button trait retained; loading state announced without exposing duplicate hidden label; disabled state remains discoverable.

### `NexusSecondaryButton`

- Inputs: title, action, `isEnabled` default true, optional leading icon/content.
- Minimum height 56, radius 12, border width 1, horizontal padding 16, vertical padding 12.
- Enabled secondary text/default border. Disabled changes text only; Android keeps the same default border.
- Optional icon then gap 8 then button-style title.

### `NexusTextButton`

- Inputs: title, action, `isEnabled` default true, optional leading icon/content.
- Minimum height 44, radius 12, padding 8.
- Brand-primary enabled foreground; disabled foreground otherwise; link typography.

### `NexusIconButton`

- Required accessibility label; inputs action, `isEnabled` default true, `isSelected` default false, icon/content.
- 48-point touch target, radius 12, icon size 24.
- Selected: brand/action filled background with white icon.
- Unselected: transparent/outlined default border with primary text icon.
- Disabled: semantic disabled foreground/background/border states.
- Icon-only control must expose one clear accessibility label and native button trait.

### `NexusIconActionButton`

- Required accessibility label; inputs action, variant, optional badge flag, icon/content. Ancestor/native `.disabled` handles disabled propagation because Android exposes no explicit enabled parameter here.
- Variants: `plain`, `softContainer`, `outlined`.
- 48-point touch target, icon 24. Badge is 9 points at top trailing and uses brand color.
- `softContainer` uses elevated surface. `outlined` uses radius 12 and 1-point default border at 0.72 opacity. `plain` adds no container decoration.
- Disabled action and accessibility semantics use native button behavior.

### `NexusTextField`

- Bind text; accept label, optional placeholder and error text, enabled state, secure-entry intent only if required by Android callers, keyboard/content-type configuration only when native and minimal.
- Fill available width, minimum height 56, radius 12.
- Label uses body-small style. Input uses form-input. Placeholder uses tertiary text. Error beneath with gap 4 and error-text style/color.
- Border precedence follows native outlined-field semantics: error -> focused -> unfocused, with disabled foreground/container roles applied through native control state.
- Focused label uses action-primary color. Disabled input/background/foreground use semantic disabled values.
- Preserve native editing, selection, keyboard, autofill, VoiceOver, and Dynamic Type behavior. Placeholder is not accessibility label when explicit label exists.

### `NexusAuthTextField`

- Same field semantics with auth geometry: minimum height 60, radius 20, horizontal content padding 16.
- Optional external label then gap 8.
- Optional leading icon: 24-point box then gap 16.
- Optional trailing content: gap 16 and 48-point box. Interactive trailing content owns its required accessibility label and action.
- Border precedence: error -> focus -> default. Error beneath with gap 8.
- Android auth code does not add separate disabled border/text colors; preserve its visible contract while native field editing is disabled. Do not invent a stronger disabled treatment inside this primitive.
- Password visibility is caller-owned state; component provides secure mode and a trailing-content slot, not hidden mutable global state.

### `NexusTopBar`

- `NexusTopBar<Trailing: View>` conforms to `ToolbarContent`; inputs are title, title alignment (`center` or `start`), and trailing content.
- Native toolbar owns height, safe-area inset, horizontal margins, localization, and system back control.
- Title uses screen-title typography, heading color, one line, truncates tail.
- Apple deviation: Android accepts `onBack`, custom height, and manual margins. Swift omits these knobs so `NavigationStack` keeps native back localization and interactive-pop gesture. Title/trailing product content remains mirrored.

### `NexusStatusChip`

- Inputs status, text, and optional leading content.
- Radius 20, border 1, horizontal padding 12, vertical padding 8, internal gap 8.
- Resolve foreground/background/border exclusively through `NexusStatus.colors`; title uses status-badge typography.

### `NexusBanner`

- Inputs text, `NexusStatus`, plus optional leading and trailing-action view slots.
- Fill width, radius 12, border 1, padding 16, internal gap 12, body typography.
- Resolve foreground/background/border exclusively through `status.colors`.
- Trailing interactive content remains independently accessible; banner itself must not steal its action.

## TDD proof

Windows cannot execute iOS Swift tests. Preserve test-first commit order locally; remote CI starts only after implementation and self-review are complete.

### RED

1. Add Swift Testing compile contracts for component construction and enum exhaustiveness against absent production symbols.
2. Commit `PARITY DS-3: add failing component contracts`.
3. Record expected missing symbols in commit/PR evidence. Do not push or open a RED-only PR.

Tests must construct at minimum:

- primary button normal/loading and optional-leading-content forms;
- secondary/text buttons enabled/disabled and optional-leading-content forms;
- each icon-action variant and badge form exhaustively;
- standard/auth fields with no icons, leading content, both slots, secure input, and errors;
- top bar empty/trailing forms and both title alignments;
- status chip/banner slot combinations across all `NexusStatus` cases;
- accessibility-label inputs cannot be omitted from icon-only button initializers.

SwiftUI internals are opaque without an inspection dependency. Compile-time required initializer arguments are valid accessibility/API evidence. Do not add runtime validators, presentation metadata, `Mirror`, or state descriptors solely to test pixels/branches. DS-4 owns screenshot and interaction proof. No third-party view inspector or snapshot dependency.

### GREEN

1. Implement smallest concrete views and state descriptors that make contracts pass.
2. Keep branch local until implementation, tests, and adversarial review are complete.
3. Coordinator pushes once, opens PR, waits for latest PR-head `build-test`, reads full logs, and fixes root cause on same branch until green.

### REFACTOR

Extract only proven repeated mechanics: shared label layout or field chrome after the third real repetition. Do not merge auth and standard fields into a generic configuration object if clear concrete views are smaller.

## Acceptance matrix

| Scenario | Input | Expected state/output | Evidence |
|---|---|---|---|
| Primary normal | enabled, not loading | action enabled; title/icon visible | compile + DS-4 interaction |
| Primary loading | loading true | action disabled; progress replaces label | compile + DS-4 interaction/visual |
| Secondary/text disabled | disabled | no action; disabled semantic color | compile + DS-4 interaction/visual |
| Icon selected | selected true | filled brand/action treatment | compile + DS-4 visual |
| Icon accessibility | icon-only action | required clear label, native button trait | initializer/API review |
| Standard field focus | focused, no error | focus border | compile + DS-4 interaction/visual |
| Standard field error | focused with error | error border wins; error text visible | compile + DS-4 interaction/visual |
| Disabled field | disabled | editing blocked; standard field uses disabled foreground/container; auth field preserves Android chrome | compile + DS-4 interaction/visual |
| Auth secure field | secure true | native secure entry; caller controls reveal action | compile + DS-4 interaction |
| Top bar center/start | each alignment | exact height/title role/truncation | metadata + DS-4 visual |
| Native navigation | system stack integration | toolbar content composes; system back/swipe remain system-owned | compile/API review; later screen test |
| Status cases | all eight statuses | existing shared colors only | table-driven test |
| Banner slots | none/leading/trailing | stable layout; actions independently accessible | compile + DS-4 visual |
| Dynamic Type | accessibility size | text scales without fixed frames clipping vertically | DS-4 simulator evidence |
| Reduce Motion | enabled | no essential feedback lost; no custom motion exists | scope review |
| Async/offline/cancellation | no async behavior | N/A | scope review |

## CI gates

- CI generates project with XcodeGen.
- Exact test command:

  `xcodebuild test -project NexusTravel.xcodeproj -scheme NexusTravel -destination 'platform=iOS Simulator,name=iPhone 16e,OS=26.2' -resultBundlePath TestResults.xcresult CODE_SIGNING_ALLOWED=NO`

- Required check: latest PR-head SHA `build-test` on `macos-26` with Xcode 26.6.
- DS-3 requires compile and unit-state evidence. DS-4 supplies visual parity, Dynamic Type, Dark Mode limitation, VoiceOver, and interaction screenshots.

## Adversarial review

Fresh pass compares every public input, default, precedence rule, dimension, token, content replacement, enabled condition, and accessibility label against all Kotlin truth sources. Confirm:

- no raw design values where tokens exist;
- no missing loading/disabled/selected/error/focus state;
- no loss of native button/text-input/navigation semantics;
- no view-owned business/navigation/password state;
- no protocol/manager/service/environment/type-erasure layer;
- no invented dark palette, motion, or legacy-artifact value;
- no generated-project or dependency change.

List and fix every mismatch or record explicit Apple/platform deviation in PR evidence.

## PR contract

- Title: `PARITY DS-3: add native SwiftUI component primitives`.
- Body links packet, RED commit/error, GREEN run, component parity matrix, Apple deviations, dark-theme limitation, and risks.
- Coordinator watches latest PR-head SHA CI, reads full failure logs, fixes root cause, and pushes same branch until green.
- Max three recurrences of same root cause; third recurrence reports blocker with logs. Never weaken/delete contract tests.
- Feature agent does not push, open/merge PR, or edit PLAN/ARCHIVE.

## Done

- [ ] Test-first commit records absent component contract before implementation.
- [ ] All listed primitive types compile and expose minimal role-named APIs.
- [ ] Compile contracts cover loading, disabled, selected, secure, error, slot, alignment, status, and variant forms.
- [ ] Dimensions, colors, typography, status mappings, and required labels use shared catalogs.
- [ ] Native accessibility, text input, and navigation behavior remain intact.
- [ ] No raw tokens, speculative abstractions, third-party dependency, or generated project edit.
- [ ] Adversarial Android-code comparison records zero unexplained mismatches.
- [ ] Latest PR SHA has green `build-test`.
