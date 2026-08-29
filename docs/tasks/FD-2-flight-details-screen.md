# FD-2 — Flight details screen

## Outcome

Ship Android-parity Flight Details orchestration and SwiftUI screen backed by `RemoteFlightDetailsRepository`.

## Truth sources

Read completely: Android `feature/flightdetails/FlightDetails{Route,Screen,Sections,ItinerarySection,UiState,ViewModel,Feedback,DisplayModel,DisplayMapper,ErrorPresenter}.kt`; FD-API-1 backend contract.

## Scope

- Observable ViewModel: initial load/retry, duplicate-safe revalidation, price-change confirmation, section expansion, unavailable seat feedback, cancellation.
- Loading/content/error plus honest empty-invalid response handling; itinerary, included accordions, price breakdown, aircraft, sticky CTA.
- Typed back/passenger navigation and production dependency wiring.
- Dynamic Type, VoiceOver icon labels, Reduce Motion, native alert, no legacy images.

## Tests

Test state transitions first: success, errors, retry, revalidation, price change accept/dismiss, duplicate continue, cancellation, accordion, seat message, navigation. CI compile/tests/gallery latest SHA required.
