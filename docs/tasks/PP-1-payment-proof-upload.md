# PP-1 — Payment-proof signed upload

## Outcome

Replace payment-proof placeholder with receipt selection and backend signed upload, then route to trip.

## Truth sources

- Android `domain/booking/PaymentProofRepository.kt`
- Android `data/booking/repository/RemotePaymentProofRepository.kt`
- Android `feature/paymentproof/**`
- Backend mobile payment-proof controller, DTO, service, repository, and route catalog.

## Acceptance

- PDF/JPEG/PNG only, nonempty, maximum 10,000,000 bytes.
- POST create with bearer → PUT raw bytes without bearer and with every `requiredHeaders` entry → POST complete with bearer.
- Mobile ownership-hiding route used; admin routes never used.
- Loading/content/error/uploaded states and Android-equivalent copy implemented.
- Duplicate upload taps cannot start concurrent workflows; cancellation propagates and restores valid state.
- File selection uses native document importer and adds no photo-library permission.
- Icon-only controls labeled; Dynamic Type-safe layout.
- Tests cover validation, exact routes/auth/header behavior, completion, state mapping, duplicate prevention, and cancellation.

## Owned paths

- `Sources/{Domain,Data}/Booking/**PaymentProof**`
- `Sources/Feature/PaymentProof/**`
- Payment-proof composition in `Sources/App/**`
- Matching tests and coordinator ledger updates.
