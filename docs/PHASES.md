# Port phases

Current phase: **Phase 1 — design system**.

| Phase | Goal | Exit gate |
|---|---|---|
| 0 | Rulebook, task packets, XcodeGen shell, PR CI | Bootstrap PR green on macOS 26; branch rules enabled |
| 1 | Design tokens, primitives, gallery | Token tests green; Mac screenshots logged |
| 2 | Domain models, validators, codecs, fake Adapters | Swift Testing suite green; no UI/network dependency |
| 3 | Transport, Keychain, auth | Backend contract fixtures green; email auth demo flow green |
| 4 | App shell, tabs, typed navigation | Per-tab restoration/navigation tests; simulator evidence |
| 5 | Home → search → results → details | Happy/error/empty/loading parity; contract + mapper tests |
| 6 | Passenger → seats → review → proof | Journey transition/idempotency/upload tests; CRITICAL gates |
| 7 | Trips, profile, explore | Offline/cache/account deletion behavior tests |
| 8 | Reliability, accessibility, motion, performance | Device evidence; accessibility/motion plans reconciled |
| 9 | App Store release | Current policy audit, privacy evidence, TestFlight, archive validation |

## Slice sizing

- One PR = one PARITY row = one observable behavior slice.
- Target 0.5–2 agent-hours, usually ≤8 production files and ≤8 test files.
- Split when task crosses two domain outcomes, two independent navigation flows, or cannot be verified by one focused command.
- Combine files when separating them would produce uncompilable or untestable intermediate state.
- Foundation row may serve later rows; feature rows may not silently refactor foundations.

## Phase gate

Phase closes only when every row is complete, CI green on latest SHA, adversarial parity review logged, no unresolved CRITICAL deviation, PROGRESS updated.
