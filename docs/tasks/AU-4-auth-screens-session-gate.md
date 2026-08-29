# AU-4 — Email authentication screens and session gate

## Outcome

Ship Android-parity email authentication UI and session restoration using the existing remote auth Adapter, with native SwiftUI interaction and typed main/booking return routing.

## Truth sources

Read completely: Android `feature/auth/Auth{ViewModel,UiState,Screens,ErrorPresenter}.kt`; Android auth design-system components used by `AuthScreens.kt`; backend auth controllers/DTO/e2e tests for sign-in, sign-up, session, and password reset; ADR-0005; AU-1/AU-3 archive evidence.

## Scope

- Observable `AuthViewModel`: session check, login/signup mode, field editing, duplicate-safe submit, cancellation, password matching, password-reset request, authenticated event.
- Native login/signup screens with loading, validation, success/error feedback, secure-entry reveal controls, terms acceptance, keyboard/content-type semantics, Dynamic Type, VoiceOver, and no social-login controls.
- `mainAuth` and `bookingAuth` destinations use one production repository seam and complete through existing Router return behavior.
- Password reset reports current backend-disabled behavior honestly; no invented recovery success.

## Tests

Write state-transition tests first: existing session success/failure/cancellation, field clearing, validation mapping, duplicate submit, login/signup success/error/cancellation, password mismatch, reset validation/result, event FIFO, main/booking route construction. Latest PR-head CI compile/tests/gallery required.

## Exclusions

- Google and Sign in with Apple per ADR-0005.
- Account deletion, profile editing, booking submission, and final device verification.
