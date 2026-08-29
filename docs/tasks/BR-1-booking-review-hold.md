# BR-1 — Booking review and stable hold idempotency

## Outcome

Replace booking-review placeholder with server-backed review. Hold flight once through stable operation-scoped idempotency, show confirmed/unknown/failure outcomes, then route to payment proof.

## Truth sources

- Android `domain/booking/BookingRequestModels.kt`
- Android booking request remote adapter/DTOs/mappers
- Android `feature/bookingreview/**`
- Backend booking review controller/response and `booking-hold/**`
- Backend `test/booking-hold.e2e.test.ts`

## Acceptance

- GET `/bookings/:id/review` and POST `/bookings/:id/hold` match backend response.
- Hold sends one nonempty idempotency key reused across retries for same ViewModel operation.
- `BOOKING_HELD` requires valid non-placeholder supplier reference.
- `HOLD_UNCONFIRMED` is presented honestly; no false success.
- Loading/content/error/submitted states and Android-equivalent copy implemented.
- Review renders passenger, contact, seats, fare, total, status, and manual-verification notice.
- Cancellation propagates; duplicate submit cannot create concurrent holds.
- Ownership-hiding 404 remains generic.
- Unit tests cover response mapping, stable retry key, invalid reference, outcome unknown, state transitions, and duplicate submit.

## Owned paths

- `Sources/{Domain,Data}/Booking/**Review**`, `Sources/{Domain,Data}/Booking/**Request**`
- `Sources/Feature/BookingReview/**`
- Booking-review composition in `Sources/App/**`
- Matching tests and coordinator ledger updates.
