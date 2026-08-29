# BJ-1 — Booking journey Module and valid transitions

## Outcome

Ship one composition-root-owned `BookingFlowState` that preserves Android booking handoff behavior while making invalid offer/details/auth transitions explicit and testable.

## Truth sources

Read completely: Android `core/navigation/BookingFlowState.kt`; booking section of `MainActivity.kt`; Swift `PORTING.md` navigation rule; existing `Router`, `FlightDetailsViewModel`, auth routes, flight/passenger booking domain models, and relevant ADRs.

## Scope

- `@MainActor @Observable final class BookingFlowState` with Android fields: `authenticated`, `offerReference`, `passengerDetails`, `submitPassengerDetailsAfterAuth`.
- Valid transitions for selecting/replacing an offer, accepting matching priced details, requesting booking auth, completing auth with one-shot passenger-submit resumption, and clearing booking data while preserving authentication.
- One instance owned by app composition root and passed explicitly to booking destinations.
- Flight-details handoff records priced details before passenger navigation; booking auth completion updates state before returning.
- Missing/mismatched prerequisites safely refuse transition; no Boolean/field mutation scattered across screens.

## Tests

Write transition tests first: defaults, offer replacement, matching/mismatched details, unauthenticated/authenticated submit, one-shot resume, repeated completion, clear semantics, and production route construction. Latest PR-head CI compile/tests/gallery required.

## Exclusions

- Passenger screen/API, signed passport upload, seat API/UI, booking hold/review, payment proof, persistence/restoration, and device verification.
