# Nexus Travel iOS archive

Append-only evidence for completed work. An entry is allowed only after PR merge and latest PR-head SHA CI success. Local tests, open PRs, and active work do not qualify.

## ST-1 — Seat selection

- Completed: 2026-08-29
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/27
- Merge commit: `5de2623d7e98882804b848105fab944ef670e328`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33256117583
- Evidence: latest head `bb832c4` built with Xcode 26.6; 243 tests across 49 suites passed.
- Contract: authenticated GET seat map, PUT assignments, DELETE optional selection, conflict mapping, passenger/segment uniqueness, fees, skip, accessibility, and review navigation.
- Adversarial review: CI exposed observable-state exclusivity trap; active passenger was snapshotted before assignment mutation and full suite reran green.
- Known deviations: simulator/device visual and accessibility evidence deferred to Phase 8 by user direction.

## PD-1 — Passenger details and passport signed upload

- Completed: 2026-08-29
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/26
- Merge commit: `b148f1eb35a18b654e9539dab8032a98d4df01ad`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33254999846
- Evidence: Xcode 26.6 built latest head `a9484c1`; 239 tests across 47 suites passed.
- Contract: stable passport idempotency, bearer-free signed PUT with required headers, completion, booking draft, passenger submission, auth resume, and seat route compiled and passed contract tests.
- Adversarial review: corrected Android “Other” gender to backend-required `X` before merge.
- Known deviations: simulator/device visual and accessibility evidence deferred to Phase 8 by user direction.

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

## AU-1 — Auth models, validation, and error presentation

- Completed: 2026-08-28
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/9
- Merge commit: `2995c775203f01fe3b2c4309734a5f0d8c296d38`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33146905071
- Evidence: Xcode 26.6 generated project, compiled auth domain/state code, and passed validation plus presenter tests on PR head `720fe91`.
- TDD: commit `300355a` added contracts while auth production symbols were absent; feature-complete push then passed first CI run.
- Adversarial review: exact Android email/password/name/terms boundaries, UTF-16 password length, permissive multiple-`@` behavior, state preservation, and user copy confirmed.
- Known deviations: Google-specific Android residue omitted per ADR-0005; `Date` represents Kotlin `Instant`; no refresh behavior inferred from optional token data.

## HM-1 — Home models, multi-city state, and search validation

- Completed: 2026-08-28
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/10
- Merge commit: `3f9f4caba365b53f35135757e9c53ea04d70860e`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33147279937
- Evidence: Xcode 26.6 generated project, compiled home domain/state code, and passed 21 calendar, traveler, validation, and multi-city contracts on PR head `cc0420a`.
- TDD: commit `a0befcc` added contracts while `LocalDate`, home models, state, and validator symbols were absent; completed feature passed first CI run.
- Adversarial review: exact Android defaults, validation precedence, traveler normalization, trip-type transitions, auto-link rules, date propagation, labels, and boundary behavior confirmed.
- Known deviations: invalid indices and add-on-empty operations safely no-op instead of reproducing Kotlin crashes.

## SR-1 — Search models, codec, and display mapping

- Completed: 2026-08-28
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/11
- Merge commit: `70296993e7967e78a9e2e3607531b80ad85821e3`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33148505012
- Evidence: Xcode 26.6 generated project, compiled search domain/display code, and passed LocalTime, request-shape, codec, mapper, filter, and stable-sort tests on PR head `5e69dca`.
- TDD: commit `bb6403c` added contracts while SR-1 production symbols were absent; completed feature passed first CI run.
- Adversarial review: exact Android model defaults, search-ID field order/codes, traveler normalization, labels, price/time/duration/stop formatting, composed filters, and sort order confirmed.
- Known deviations: invalid request shapes return nil; malformed encoded dates use injected deterministic fallback instead of Kotlin traps.

## FD-1 — Flight details models and display mapping

- Completed: 2026-08-28
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/12
- Merge commit: `3544f558299d8d5d00208ec99ca13d47743100fd`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33149321084
- Evidence: Xcode 26.6 compiled flight-details models, nonthrowing repository result seam, deterministic display mapper, semantic airline mapping, and exact error presenter; full tests passed on PR head `d8aa493`.
- TDD: commit `d23d4b5` added missing-symbol contracts before production implementation.
- Adversarial review: exact Android nested defaults, result cases, date/time/price/traveler formatting, leg order, 14 airline mappings, and failure copy confirmed.
- Known deviations: platform-independent semantic airline identifiers replace Android resource IDs; no image assets or UI behavior entered domain scope.

## BK-1 — Passenger and booking domain

- Completed: 2026-08-28
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/13
- Merge commit: `0c18fa2a85746b97ce405eaf861b1581226839cc`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33151380562
- Evidence: Xcode 26.6 compiled passenger/booking models, deterministic split-date handling, contact/passport validation, and country catalog; full tests passed on PR head `d1ada31`.
- TDD: commit `dd71b09` added missing-symbol contracts before production implementation.
- Adversarial review: exact Android defaults, required/error copy, selective-field behavior, date precedence, Ethiopian/generic phone rules, stable summary ordering, status labels, and country fallback confirmed.
- Backend boundary: Android passenger domain request remains UI/domain data only; PD-1 must explicitly map it to current backend coded DTO after signed passport upload.

## NT-1 — Shared HTTP transport

- Completed: 2026-08-28
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/14
- Merge commit: `7b434a0220e786e842df5611c9b2883fc84932d9`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33164157051
- Evidence: Xcode 26.6 compiled strict-concurrency URLSession transport and passed URL construction, bearer/signed-upload header, status preservation, connectivity, cancellation, and unknown-error tests on PR head `c63319a`.
- TDD: commit `d677e9c` added missing-symbol request/transport contracts before production implementation.
- Adversarial review: backend route boundaries, 30-second default, authorization protection, repository-owned HTTP mapping, private correlation logging, and cancellation propagation confirmed.
- Known exclusions: no decoding, retries, reachability, auth store, endpoint catalog, idempotency generation, or third-party dependency.

## AU-2 — Keychain session storage

- Completed: 2026-08-28
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/15
- Merge commit: `e409029052294ea71e23ac29ffbb2537fe8a2917`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33169919406
- Evidence: Xcode 26.6 compiled Security-framework storage under strict concurrency and passed 12 payload, overwrite, self-heal, native-query, failure, and token-provider tests on PR head `860deeb`.
- TDD: commit `b0d85da` added missing-symbol Keychain contracts before production implementation.
- Security review: full session/token payload lives only in one non-synchronizing `AfterFirstUnlockThisDeviceOnly` generic-password item; no token logging, UserDefaults, file storage, iCloud sync, or refresh behavior.
- Boundary: storage preserves session data but does not decide expiry or contact backend; AU-3 owns lifecycle policy.

## AU-3 — Remote email/password authentication

- Completed: 2026-08-29
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/16
- Merge commit: `9bc6250d3d59e09cf83272a2c412c30ec94a036e`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33231289455
- Evidence: Xcode 26.6 compiled strict-concurrency remote auth and passed route, request, DTO, mapper, session lifecycle, cancellation, secure-storage, and sign-out tests on PR head `f3a03a1`.
- TDD: commit `39dd9c8` added remote-auth contracts before production implementation; CI exposed one Swift 6 inference defect, fixed at source in `f3a03a1`, then latest-SHA CI passed.
- Contract review: root Better Auth routes, `200 null` unauthenticated session, token precedence, bearer attachment, expiry boundaries, clearing policy, and full error/status matrix confirmed.
- Backend blocker: password reset remains disabled server-side as `RESET_PASSWORD_DISABLED`; iOS reports unknown failure honestly and does not call obsolete Android `/forget-password`.

## NV-1 — Typed app shell navigation

- Completed: 2026-08-29
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/17
- Merge commit: `41e3535d2eb28139c71ed1a6fdbad5f77f56bee0`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33232280871
- Evidence: Xcode 26.6 compiled native four-tab shell and passed 25-route inventory, filter, independent-history, reselect, safe-pop, auth-return, and launch-selection tests on PR head `4709863`.
- TDD: commit `b264536` added missing-symbol navigation contracts before production implementation; feature passed first CI run.
- Adversarial review: every Android route, tab label, icon intent, auth return, and detail tab-bar visibility matched.
- Intentional Apple adaptation: native `TabView`, one `NavigationStack` per tab, retained independent histories, and current-tab reselect-to-root.

## SR-2 — Remote flight search

- Completed: 2026-08-29
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/18
- Merge commit: `c41a166d130729b5875bc09fbb711315ff982ff8`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33237776609
- Evidence: Xcode 26.6 compiled anonymous remote search, strict DTO mapping, actor cache, and cache-backed results repository; full tests and gallery evidence passed on PR head `910d02b`.
- TDD: `97b4bcf` established missing-symbol contracts; coordinator review added name-parity/currency-precision RED `1ed30f9`; one syntax failure was repaired at source and latest-SHA CI passed.
- Contract review: exact one-way/round-trip/multi-city shapes, normalized travelers/ages, 201 success, strict required fields, additive JSON, offer legs/carrier/price/expiry, status/transport/cancellation, and no-write failures confirmed.
- Known boundary: results remain memory-only by Android contract; process restart requires a new search. No retry, refresh, details/price call, bearer, or supplier reference leakage.

## HD-1 — Remote Home and airport data adapters

- Completed: 2026-08-29
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/19
- Merge commit: `27320a35dfba82ebc87b84b6b8e631693e19d5fe`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33238883005
- Evidence: Xcode 26.6 compiled structured query construction, strict Home/airport DTO mapping, anonymous remote adapters, and actor airport cache; 179 tests plus gallery capture passed on PR head `b3c22e2`.
- TDD: `9d0ce17` established missing-symbol contracts before `d6070bb`; CI exposed one nested test-macro compile defect plus two fixture/spec mismatches, each repaired at source before latest-SHA green.
- Contract review: popular/search route limits, original-query percent encoding, ADD/DXB precedence, Android index/fallback mapping, ten-minute stale revalidation, no-empty cache, complete status/connectivity/cancellation behavior, and no auth headers confirmed.
- Known boundary: Home mapper intentionally preserves Android zero/empty price presentation. No image assets, retries, disk cache, ViewModel, or UI entered scope.

## HM-2 — Home screen and orchestration

- Completed: 2026-08-29
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/20
- Merge commit: `a2cbb3291d51d35213f8d0e96909eb2e4ac09691`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33240910861
- Evidence: Xcode 26.6 compiled production Home dependency wiring, observable orchestration, native SwiftUI Home states/sheets, typed navigation, stale-query protection, and cancellation; full tests plus gallery capture passed on PR head `868c8c9`.
- TDD: `9029f0a` established missing ViewModel/screen contracts; coordinator and independent parity/concurrency reviews closed retry, load/search state, date clock, traveler ages, route-name, request-shape, and nested-task cancellation gaps before first push.
- Android parity: every Home event/state/copy path, one/round/multi-city request shape, ADD/DXB fallback, airport search, recent/trending search, and result/package handoff confirmed.
- Apple adaptations: native DatePicker/sheets/navigation, Dynamic Type wrapping, Reduce Motion transition, code-only background, remote URL images only, labeled non-actionable notification indicator, and no dead Recent Searches clear control.

## SR-3 — Search results screen

- Completed: 2026-08-29
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/21
- Merge commit: `68f04b4e3d6f6f65b19d54eda003e2cf170c90be`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33243023779
- Evidence: Xcode 26.6 compiled observable search-results orchestration, four UI states, sorting/filtering, expiry countdown, typed flight-details navigation, accessibility, and gallery capture on PR head `0ca9e41845ef997fa4eb14e81d666e65ea7aed10`.
- CI repair loop: first run exposed a Swift route/view name collision; renamed only the SwiftUI destination seam to `SearchResultsScreenRoute`, preserving Android model name parity.
- Known boundary: selected-offer pricing/details remains FD-API-1; destination stayed an honest placeholder until its production repository exists.

## FD-API-1 — Remote flight details adapter

- Completed: 2026-08-29
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/22
- Merge commit: `5e03f7ebf7fbbca5d381011d318a13aec0242f44`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33243797678
- Evidence: Xcode 26.6 compiled strict canonical DTO mapping and pricing/revalidation adapter; full tests passed on PR head `dc2c71207cec2fa3620e5a348f0e32c1c958811a`.
- Contract review: anonymous 90-second details request, confirmed/price-change mapping, segments/rules/availability, status matrix, connectivity, malformed data, and cancellation verified.

## FD-2 — Flight details screen

- Completed: 2026-08-29
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/23
- Merge commit: `c9a1ffb`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33247965119
- Evidence: Xcode 26.6 compiled Flight Details orchestration, screen states, typed routing, shared dependency wiring, cancellation hardening, and composed Home request reuse; 223 tests in 44 suites plus gallery capture passed on PR head `b09266f`.
- Adversarial review: corrected continuation failures to retain details, restored valid state on cancellation, blocked duplicate revalidation/stale Home loads, moved AppShell to composition root, and removed fixed-delay async tests.
- Deferred evidence: final device accessibility, motion, and full cold-launch journey verification remains Phase 8 QA scope.

## AU-4 — Email authentication screens and session gate

- Completed: 2026-08-29
- PR: https://github.com/AHafizF1/Nexus-Travel-iOS/pull/24
- Merge commit: `287af2c`
- Latest task-branch CI: https://github.com/AHafizF1/Nexus-Travel-iOS/actions/runs/33252802840
- Evidence: Xcode 26.6 compiled session restoration, native email login/signup, password reset request, and main/booking auth returns; 230 tests in 45 suites plus gallery capture passed on PR head `1160de2`.
- Adversarial review: cancellation restores prior form/gate state, duplicate submissions are suppressed, password mismatch stays local, backend-disabled reset fails honestly, and social login remains excluded by ADR-0005.
- CI repair: replaced actor-isolated method references with explicit closures after Xcode 26.6 crashed during AuthScreens IR generation.
- Deferred evidence: final device accessibility, keyboard, and cold-launch verification remains Phase 8 QA scope.
- **BJ-1 — Booking journey Module and valid transitions** — merged PR #25 at `d241cb7`; PR head `ea22fd1`; CI run `33253338540` green (237 tests, 46 suites). Added typed booking state, auth-resume transition, stale-offer rejection, and composition-root ownership.
