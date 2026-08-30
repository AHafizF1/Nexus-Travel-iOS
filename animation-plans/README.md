# Motion plans

| Plan | Title | Severity | Status |
|---|---|---|---|
| [001](001-tokenize-home-service-transition.md) | Tokenize Home service transition | MEDIUM | DONE |

## Execution order

1. Execute 001. No dependencies.

## Vetted audit

| Severity | Category | Location | Finding |
|---|---|---|---|
| MEDIUM | Easing, accessibility, cohesion | `Sources/Feature/Home/HomeScreen.swift:101-110` | Implicit `.smooth` and `.linear` bypass shared duration tokens; reduced path needs explicit short opacity timing. |

## Missed opportunities

- Search Results skeleton pulse exists in Android but iOS placeholder is static. Defer until device feel/performance evidence supports continuous motion in high-frequency search flow.
- Explore shimmer exists in Android but iOS uses native `ProgressView`/`AsyncImage` placeholders. Defer until Explore gains equivalent skeleton geometry; adding shimmer alone would invent UI structure.

No other custom motion exists. Native navigation, sheets, menus, disclosure groups, progress indicators, and button press feedback already provide platform motion and remain intentionally unwrapped.
