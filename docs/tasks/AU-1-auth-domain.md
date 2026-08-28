# AU-1: Auth models, validation, and error presentation

## Ownership

- PLAN task: `AU-1`
- Branch: `codex/au-1-auth-domain`
- Base: shared Phase 2 dispatch commit from merged DS-4.
- Parallel with HM-1; paths do not overlap.
- Agent owns local RED/GREEN commits only. Coordinator owns push, PR, CI loop, merge, PLAN, ARCHIVE.

Production:

- `Sources/Domain/Auth/AuthModels.swift`
- `Sources/Domain/Auth/AuthValidation.swift`
- `Sources/Feature/Auth/AuthUiState.swift`
- `Sources/Feature/Auth/AuthErrorPresenter.swift`

Tests:

- `Tests/Domain/Auth/AuthValidationTests.swift`
- `Tests/Feature/Auth/AuthErrorPresenterTests.swift`

Everything else read-only. Never edit PLAN/ARCHIVE/packet/project.yml/xcodeproj.

## Truth sources

Read completely before Swift:

- Android `domain/auth/AuthModels.kt`
- Android `domain/auth/AuthValidation.kt`
- Android `feature/auth/AuthUiState.kt`
- Android `feature/auth/AuthErrorPresenter.kt`
- Android `feature/auth/AuthViewModel.kt` only to confirm state/presenter callers
- Android `AuthErrorPresenterTest.kt`, `AuthViewModelTest.kt`, plus validation callers found by `rg`
- `AGENTS.md`, `docs/PORTING.md`, `docs/CONVENTIONS.md`, ADR-0005

Android Kotlin code controls behavior/copy. Legacy artifacts excluded. Backend/repository DTOs excluded.

## Skills

Use `ponytail`, `write-swift`, `swift-expert`, `swift-api-design-guidelines`, `test-driven-development`, `improve-codebase-architecture`, `code-structure`, `dry-principle`, `swift-architecture`, `ux-copy`, and `ui-typography`. Copy skills review exact user-visible messages but must not rewrite Android contract. No SwiftUI/concurrency/network/App Store/animation work.

## Models

- `AuthSession(sessionId: String, user: AuthUser, tokens: AuthTokenSet?, expiresAt: Date)`
- `AuthUser(id: String, displayName: String, email: String, avatarUrl: String?)`
- `AuthTokenSet(accessToken: String, refreshToken: String?)`
- `SignInRequest(email: String, password: String)`
- `SignUpRequest(fullName: String, email: String, password: String, acceptedTerms: Bool)`
- `AuthField`: `fullName`, `email`, `password`, `confirmPassword`, `terms`
- `AuthError`: `validation([AuthField: String])`, `invalidCredentials`, `emailAlreadyUsed`, `emailNotVerified`, `networkUnavailable`, `rateLimited`, `unauthenticated`, `sessionExpired`, `unknown`
- `AuthMode`: `login`, `signup`
- `AuthGateState`: `checking`, `unauthenticated`, `authenticated(AuthSession)`
- `LoginUiState`: `email = ""`, `password = ""`, optional email/password/message errors nil, `isSubmitting = false`, `isSuccess = false`.
- `SignupUiState`: full name/email/password/confirm password empty, `acceptedTerms = false`, all five field errors plus message nil, `isSubmitting = false`, `isSuccess = false`.

Use value types, `let` defaults, `Equatable`, `Sendable`; add `Hashable`/`Codable` only where all storage supports it and a real consumer exists. Do not force `Hashable` on validation dictionary. Every non-private declaration gets `///` summary.

ADR-0005 overrides Android social-login residue. Omit Google-specific errors, states, completion paths, and copy. `refreshToken` remains data only; no refresh behavior exists.

## `AuthValidator`

Static namespace; exact APIs:

- `validateSignIn(request:) -> [AuthField: String]`
- `validateSignUp(request:) -> [AuthField: String]`
- `validatePasswordReset(email:) -> [AuthField: String]`

Rules:

- Validation trims outer whitespace/newlines only; request values remain unchanged.
- Email: first `@` index > 0; last `.` at least two positions after `@`; at least two characters after final `.`. No regex/lowercasing/internal-space rule. Multiple `@` may pass, matching Kotlin.
- Password minimum uses `utf16.count >= 8`, matching Kotlin code units.
- Trimmed full name length >= 2.
- Signup requires terms. Confirm password is not in request and not validated here.
- Exact errors:
  - `Please enter a valid email address.`
  - `Password must be at least 8 characters.`
  - `Please enter your full name.`
  - `Accept the terms to create your account.`

One private trim/email helper maximum. No regex wrapper, localization system, service, protocol, or validator object.

## `AuthErrorPresenter`

Small static transforms returning new value states. Prefer clear APIs such as `loginState(from:error:)` and `signupState(from:error:)`; call sites must read grammatically. Never mutate unrelated state.

Exact messages:

| Error | Login | Signup |
|---|---|---|
| invalidCredentials | `Email or password is incorrect.` | `This account cannot be created. Try another email.` |
| emailAlreadyUsed | `An account already exists for this email.` | field-only email error with same text |
| emailNotVerified | `Verify your email before signing in.` | `Verify your email to continue.` |
| networkUnavailable | `You appear to be offline. Check your connection and try again.` | same |
| rateLimited | `Too many attempts. Try again later.` | same |
| unauthenticated/sessionExpired | `Your session expired. Sign in again.` | same |
| unknown | `Something went wrong. Please try again.` | same |

Preservation semantics:

- Every mapping stops submission.
- Validation replaces all relevant field errors, clearing keys absent from dictionary; preserves existing banner message.
- Message mappings set message but preserve existing field errors and inputs.
- Signup email-used changes only submission/email error; preserves message and other field errors.
- Never alter inputs, terms, success state, or mode.

## TDD

Windows cannot run Swift. Commit tests first; record expected missing symbols. Do not push RED alone.

RED validator matrix:

- minimal valid email, outer whitespace, missing/leading `@`, missing dot, empty domain segment, one/two-character suffix, permissive multiple `@`;
- password 7/8 UTF-16 units plus Unicode code-unit boundary;
- trimmed name 1/2 boundary; terms false; simultaneous signup errors;
- password-reset email only.

RED presenter matrix:

- validation maps/clears every field and preserves message;
- every nonvalidation branch exact copy for login/signup;
- signup email-used is field-only;
- submission always false; unrelated state preserved.

Commit `PARITY AU-1: add failing auth domain contracts`, then smallest production commit. No ceremonial per-property tests.

## Exclusions

No `AuthViewModel`, events/completion channels, repositories/results/fakes, session store/Keychain, DTO/mappers, network/backend fixtures, screens/navigation, password-match orchestration, Google auth, or dependency protocol.

## Done

- [ ] RED precedes production.
- [ ] Exact models/defaults compile.
- [ ] Validation edge matrix passes.
- [ ] Presenter copy/state-preservation matrix passes.
- [ ] ADR-0005 social-login exclusions preserved.
- [ ] No unrelated abstraction/dependency/file change.
- [ ] Latest PR-head CI green after coordinator push.
