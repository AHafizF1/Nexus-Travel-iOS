# ADR-0005: Launch with email/password authentication only

- Status: Accepted
- Date: 2026-08-24

## Context

Android exposes Google authentication, but backend config supports Better Auth email/password plus bearer tokens only. No Google provider or Sign in with Apple token-validation/revocation flow exists. Apple Guideline 4.8 requires an equivalent privacy-preserving login option when third-party/social login authenticates the primary account.

## Decision

Launch iOS with email/password sign-up, sign-in, password reset, session restore, sign-out, and in-app account-deletion initiation. Do not show Google or Sign in with Apple.

## Consequences

- Phase 4 is no longer blocked by login-provider choice.
- Keychain stores bearer token; no refresh flow is invented.
- Adding social login requires backend implementation, token revocation/deletion handling, parity tests, and a superseding ADR.
- App Review policy must be rechecked when social login scope changes.
