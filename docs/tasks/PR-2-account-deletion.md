# PR-2 — Asynchronous account deletion

## Goal

Add App Store-compliant in-app account-deletion initiation matching Android intent and current backend asynchronous contract.

## Dependencies

- PR-1 merged and CI-verified.
- Existing `DeleteAccountRoute`, auth/session storage, HTTP transport, profile security screen.

## Truth sources

Read completely before Swift changes:

- Android `feature/profile/ProfileDetailScreens.kt` — `DeleteAccountScreen`.
- Android `feature/profile/ProfileDetailViewModels.kt` — `AccountSecurityViewModel` deletion behavior.
- Android `data/profile/RemoteAccountSecurityRepository.kt` and `domain/profile/ProfileModels.kt`.
- Backend `customer-profile.controller.ts`, `customer-profile.dto.ts`, `customer-profile.dto.test.ts`, `customer-profile.service.ts`, `customer-profile.repository.ts`, `account-deletion.queue.ts`, and `account-deletion.worker.ts`.
- ADR-0005 and App Store/account-deletion rules in `AGENTS.md`.

## Required behavior

- Validate nonblank password, maximum 128 characters, and exact case-sensitive `DELETE` confirmation before network work.
- POST authenticated `/api/v1/mobile/profile/delete` with JSON `{password, confirmation}`.
- Generate one operation-scoped idempotency key when ViewModel is created; reuse it for retries. Never generate in repository request method.
- Decode required `{requestId,status}` response and accept only backend `REQUESTED` initiation state.
- Model idle, submitting, pending, and recoverable failure honestly. Never claim immediate deletion completion.
- Explain irreversible removal plus anonymized legally required booking/ticket retention before confirmation.
- On accepted request, clear local auth/session state, route to signed-out profile, and show deletion-request-pending confirmation.
- Preserve cancellation without user-visible error and prevent duplicate submission.
- Map auth, input/password, network, and server failures to actionable Apple-tone copy without exposing backend internals.
- Native secure password field; icon-only controls accessible; Dynamic Type-safe layout; no new permission or dependency.

## Tests and evidence

- RED first: exact route/method/bearer/body/idempotency header and required response decoding.
- Prove same key across retry, different ViewModel operation gets different key, duplicate-submit blocking, validation, cancellation rollback, pending state, and local session clearing.
- Adversarially compare every truth source after implementation.
- Latest PR-head macOS CI must compile and pass full suite. Device/visual evidence stays Phase 8 per user direction.

## Owned paths

- `Sources/Domain/Profile/`, `Sources/Data/Profile/`, `Sources/Feature/Profile/`
- Minimal composition/navigation changes under `Sources/App/`
- Matching `Tests/`
- This packet plus coordinator PLAN/ARCHIVE reconciliation.

## Excluded

- Backend edits, worker polling/status endpoint invention, immediate-completion claims, social auth, third-party dependencies, Phase 8 device verification.
