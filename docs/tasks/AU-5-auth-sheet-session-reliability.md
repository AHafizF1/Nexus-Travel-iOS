# AU-5 — Contextual authentication sheet and session reliability

## Outcome

Replace pushed authentication screens with one contextual native sheet for booking, trips, and profile. Preserve booking input, resume protected work once after authentication, reject expired stored tokens, and keep loading/logout state recoverable.

## Truth sources

Read completely: Android `feature/auth/Auth{ViewModel,UiState,Screens,ErrorPresenter}.kt`; backend Better Auth configuration; `docs/adr/0005-auth-signin-apple-guideline-4.8.md`; AU-4, BJ-1, and PR-1 implementations.

## Scope

- Enum-driven authentication sheet owned by the root Router.
- Context copy for booking, trips, profile, and expired sessions.
- Existing-session restoration before displaying credentials.
- Booking continuation after sheet success without losing passenger details.
- Expired-token rejection and Keychain cleanup before protected requests.
- Complete password-reset error cleanup and logout/load race protection.
- Fixed-size loading labels, press feedback, Reduce Motion behavior, and VoiceOver error announcements.
- Password reset UI reports current backend limitation honestly.

## Tests

- Router sheet intent preserves navigation path.
- Expired stored token is rejected and cleared.
- Unexpected reset failure ends loading with actionable feedback.
- Successful authentication clears password fields.
- Failed logout ends loading and preserves recoverable profile state.
- Latest PR-head macOS CI compile and tests required before merge.

## Exclusions

- Social login.
- Backend password-reset delivery implementation.
- New dependencies or state-management frameworks.
- PLAN completion or ARCHIVE evidence before merge and green latest-head CI.
