# FD-1: Flight details models and mapper

## Ownership and truth

- Branch: `codex/fd-1-flight-details-domain`; requires merged HM-1 and SR-1.
- Own production: `Sources/Domain/FlightDetails/{FlightDetailsModels,FlightDetailsRepository}.swift` and `Sources/Feature/FlightDetails/{FlightDetailsDisplayModel,FlightDetailsDisplayMapper,FlightDetailsErrorPresenter}.swift`.
- Own matching tests under `Tests/Domain/FlightDetails/` and `Tests/Feature/FlightDetails/`.
- Everything else read-only. Coordinator owns PLAN/ARCHIVE/packet/push/PR/CI.
- Read Android `domain/flightdetails/{FlightDetailsModels,FlightDetailsRepository}.kt`, feature `FlightDetails{DisplayModel,DisplayMapper,ErrorPresenter,UiState,ViewModel}.kt`, related mapper/ViewModel/airport tests, existing Swift HM-1/SR-1 types, AGENTS/PORTING/CONVENTIONS completely.
- Use ponytail, write-swift, swift-expert, swift-api-design-guidelines, TDD, architecture/code-structure/DRY/swift-architecture, ux-copy, ui-typography. No SwiftUI/network/animation implementation.

## Domain

Reuse `LocalDate`, `LocalTime`, `Money`, `TravelerCounts`, `TripType`, `AirlineBrand`, `FlightOfferReference`, `FlightOfferBadge`, `SearchWarning`. Never duplicate/modify them. Value types gain Equatable/Hashable/Codable/Sendable where supported; document every non-private declaration.

`FlightDetails`: searchId, offerId, reference, offerToken, source?, tripType, originCode, destinationCode, departureDate, returnDate?, travelers, cabinLabel, airline, flightNumber, badge?, price, oldPrice?, legs, baggage, fareRules, priceBreakdown, aircraft, seat, expiresAt?, warnings, fareAvailability? = nil.

Nested exact fields:

- `FareAvailability(status, remainingSeats?)`
- `FlightDetailsLeg(label, date, departureAirportCode/name, arrivalAirportCode/name, departureTime, arrivalTime, durationMinutes, stopLabel, segments)`
- `FlightDetailsSegment(departureAirportCode, arrivalAirportCode, layoverMinutes?, departureDate?=nil, arrivalDate?=nil, departureTime?=nil, arrivalTime?=nil, durationMinutes=0, marketingAirlineName="", operatingAirlineName?=nil, flightNumber="", operatingFlightNumber?=nil, equipment?=nil, cabin?=nil, bookingClass?=nil)`
- `BaggageSummary(cabin, checked, included, detail)`
- `FareRulesSummary(refundableLabel, changeLabel, cancellationLabel, sections=[]); FareRuleSection(title, items)`
- `PriceBreakdown(baseFare, taxesAndFees, serviceFee?, total)`
- `AircraftSummary(aircraftName, operatingAirline, note)`
- `SeatSummary(selectedSeat?, availabilityLabel, extraLegroomAvailable)`

Repository seam: `protocol FlightDetailsRepository: Sendable { func priceOffer(reference:) async -> FlightDetailsResult }`. Result cases: success(details), priceChanged(previousTotal:updatedDetails:), offerExpired, offerUnavailable, networkUnavailable, authRequired, unknownError. Result seam never throws.

## Display mapper

Models: `FlightDetailsDisplayModel(title, airlineName, airlineLogo: AirlineVisual, flightMeta, dateTravelerMeta, totalPrice: PriceDisplay, legs: [FlightLegDisplay], warning?)`; `AirlineVisual.asset(name:)/fallback`; `PriceDisplay(currency,amount,formatted)`; `FlightLegDisplay` mirrors display leg strings; `FlightDetailsWarningDisplay(message)`.

`toDisplayModel(warningMessage:nil)` exact rules:

- title `origin -> destination`; flight meta `flightNumber · cabinLabel`; date/traveler meta `date range · travelers.summary()`.
- one-way `MMM d`; return `MMM d - MMM d`; deterministic English Gregorian.
- price currency raw; amount removes only exact `"<currency> "` prefix; formatted preserved.
- legs preserve order/API label. Date `EEE, MMM d`; time 12-hour `h:mm a` lowercased; duration `Nh Nm`; fields/stop label preserved.
- warning nil or exact input.
- airline assets: ET ic_airline_ethiopian_mark; EK airline_emirates_logo; FZ airline_flydubai_logo; G9 airline_air_arabia_logo; EY airline_etihad_logo; QR airline_qatar_logo; SV airline_saudia_logo; XY airline_flynas_logo; MS airline_egyptair_logo; TK airline_turkish_mark; KQ airline_kenya_airways_mark; AH airline_air_algerie_mark; J4 airline_badr_icon; IY airline_yemenia_mark; else fallback. Semantic names only; no assets/UI types.

## Error presenter

`FlightDetailsErrorUi(title,message,primaryAction,secondaryAction=nil)`; action retry/chooseAnotherFlight/signInAgain/none. Success/priceChanged -> nil. Failures exact:

- network: `Connection lost` / `Check your network and retry.` / retry
- unknown: `Could not load flight details` / `Try again.` / retry
- expired: `Fare expired` / `This fare expired. Choose another flight.` / chooseAnotherFlight
- unavailable: `Fare unavailable` / `This fare is no longer available. Choose another flight.` / chooseAnotherFlight
- auth: `Sign in again` / `Sign in again to continue.` / signInAgain

## TDD and exclusions

Commit tests-only RED, then minimum GREEN. Cover nested defaults, result values, representative Codable; one-way/round-trip dates, separators, traveler summary, exact/nonmatching currency prefix including `INR 46,332.46`, midnight/noon/single-digit/PM, deterministic weekday/month, zero/sub-hour/multi-hour duration, leg order, warning, all 14 airlines/fallback; every error mapping and nil secondary.

Exclude UI state/ViewModel/events/navigation, revalidation/continue/price dialog, expandable state, booking lookup, fixtures/inventory, remote/cached repos, DTO/API, airportSubtitle, SwiftUI, assets/colors, networking/cache/persistence, cancellation, HM/SR edits.

Done only after RED precedes production, exact models/defaults compile, mapper/error matrix passes, no Android UI leakage/duplication, latest PR-head CI green.
