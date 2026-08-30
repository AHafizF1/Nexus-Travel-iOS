# 001 — Tokenize Home service transition

- **Status**: DONE
- **Commit**: `6ee2300`
- **Severity**: MEDIUM
- **Category**: Easing, duration, accessibility, cohesion
- **Estimated scope**: 2 files, under 20 lines

## Problem

`Sources/Feature/Home/HomeScreen.swift:101-110` uses implicit `.smooth` timing and `.linear` for reduced motion:

```swift
if state.selectedService == .flight { searchPanel.transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity)) }
// ...
.animation(reduceMotion ? .linear : .smooth, value: state.selectedService)
```

Timing therefore bypasses existing `NexusMotion` tokens. Reduced Motion correctly removes position change, but its unspecified linear animation does not reuse short feedback timing.

## Target

Add token-derived SwiftUI animations: critically damped spring for normal expand/fade; 120 ms ease-out opacity for Reduce Motion. Keep Android-defined `fadeIn() + expandVertically()` behavior and existing top origin.

```swift
static let serviceTransition = Animation.spring(response: 0.4, dampingFraction: 1)
static let reducedServiceTransition = Animation.easeOut(duration: 0.12)
```

## Repo conventions to follow

- Durations live in `Sources/Core/DesignSystem/NexusTokens.swift` under `NexusMotion`.
- Existing accessibility branch lives beside transition in `Sources/Feature/Home/HomeScreen.swift:94-110`.
- Use native SwiftUI only; no dependency.

## Steps

1. Extend `NexusMotion` with internal SwiftUI `Animation` values derived from current 120 ms fast token and Apple critically damped defaults.
2. Replace Home `.linear`/`.smooth` selection with those tokens.
3. Keep transition structure and selected-service behavior unchanged.

## Boundaries

- Do NOT change Home state, navigation, layout, Android-visible composition, or sheet behavior.
- Do NOT add loading shimmer; it is separate additive scope.
- Do NOT add dependencies.
- If cited code drifted since `6ee2300`, stop and report.

## Verification

- **Mechanical**: run project macOS CI; build and tests must pass.
- **Feel check**: toggle Flight/Hotel/Package repeatedly. Search panel must retarget without jumping, expand from top, settle without bounce. Enable Reduce Motion: position must not move; only short opacity change remains.
- **Done when**: animations use shared tokens, normal motion is critically damped, Reduce Motion has no translation, latest PR-head CI is green.
