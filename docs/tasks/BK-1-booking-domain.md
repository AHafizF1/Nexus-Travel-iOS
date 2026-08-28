# BK-1: Passenger intake and booking-request foundation

## Ownership

- Branch `codex/bk-1-booking-domain`; requires FD-1 and inherited HM-1/SR-1 types.
- Production: `Sources/Domain/Booking/{PassengerDetailsModels,BookingRequestModels}.swift`; `Sources/Feature/PassengerDetails/{PassengerDetailsUiState,PassengerDateInput,PassengerDetailsValidation,CountryCatalog}.swift`.
- Tests: matching domain tests plus date-input and validation tests under `Tests/`.
- Everything else read-only. Coordinator owns PLAN/ARCHIVE/packet/push/PR/CI.

Read Android `domain/booking/{PassengerDetailsModels,BookingRequestModels}.kt`, feature `passengerdetails/{PassengerDetailsUiState,PassengerDetailsValidation,PassengerDateInput,CountryCatalog}.kt`, validation tests, ViewModel only for boundary. Read backend booking DTO/controller/passport tests/helpers: current wire contract differs from Android domain. Read AGENTS/PORTING/CONVENTIONS and routed skills.

Use ponytail, write-swift, swift-expert, Swift API guidelines, TDD, architecture/code-structure/DRY/swift-architecture, ux-copy, ui-typography. Pure Foundation/domain; no UI/concurrency/network.

## Domain

- `SubmitPassengerDetailsRequest(offerReference: FlightOfferReference, passengers: [PassengerDetailsDraft], contact: PassengerContactDetails, clientSessionId: String)`.
- `PassengerDetailsDraft(passengerType,title,gender,firstName,lastName,dateOfBirth?,nationalityCountryCode,passportNumber,passportExpiryDate?,passportIssuingCountryCode,document?)`; `fullName` joins nonblank first/last unchanged with one space.
- `PassengerContactDetails(email,countryDialCode,phoneNumber)`; `PassengerDocumentAttachment(uriString,displayName,mimeType?)`; `PassengerType.adult/child/infant`.
- `PassengerDetailsResult`: success(reviewId,total), validationRejected([PassengerDetailsRejectedField]), offerExpired, offerUnavailable, networkUnavailable, authRequired, unknownError. Rejected field stores field/message.
- `BookingRequestSnapshot(offerId,reviewId?,status,bookingReference?=nil)`; `hasRequest = status != .none`.
- `BookingRequestStatus`: none/draftSaved/submittedForManualReview/agentReviewing/confirmed/expired/unavailable. Labels: empty, `Request saved`, `Manual review`, `Agent reviewing`, `Confirmed`, `Expired`, `Unavailable`.

Defer booking review/result/submit and all seat types to BR-1/ST-1. No repository protocol.

## Form and dates

`PassengerDetailsFormState` defaults: title Mr, gender Male; names empty; DOB aggregate nil and day/month/year empty; nationality ET/Ethiopian; passport empty; expiry parts empty and aggregate nil; issuing ET/Ethiopia; document nil; email empty; dial +251; phone country ET/Ethiopia; phone empty; both Ethiopia flags true.

`PassengerValidationState`: field-error map, date-group-error map, ordered summary; lookup helpers, hasErrors, removal of named fields/groups clearing summary. Groups DOB/expiry. Fields: title, gender, firstName, lastName, dateOfBirth + day/month/year, nationality, passportNumber, passportExpiryDate + day/month/year, passportIssuingCountry, passportDocument, email, phoneCountry, phoneNumber. No screen-level UI state.

`PassengerDateInput(day,month,year)`: complete iff every part nonblank; parsed trims/int parses, valid Gregorian, year 1900...2100. Part setters retain Unicode whole-number digits then first 2/2/4 characters. Form helpers synchronize split and aggregate DOB/expiry.

## Validation

APIs `validate(form:details:today:)` and selective `validateFields(form:details:fields:isSubmit:today:)`. Inject `today`; details supply departure date. Preserve discovery order explicitly for summary; maps only serve lookup. Summary = field messages then date-group messages, stable distinct.

Required messages: `Title is required.`, `Gender is required.`, `First name is required.`, `Last name is required.`, `Nationality is required.`, `Passport number is required.`, `Passport issuing country is required.`, `Passport document is required.`

Email trims outer space; exactly one @ with nonblank sides; domain dot-separated with >=2 nonblank components, final length >=2; no internal whitespace. Error `Enter a valid email address.`

Phone strips Unicode digits. Blank dial `Select phone country code.` before blank digits `Enter a mobile number.`. +251 must be exactly `9` + eight digits else `Enter a valid Ethiopian mobile number.`. Other numbers require 7...15 digits else `Enter a valid phone number.`

Date parts validate when submitted or touched: blank `Day|Month|Year is required.`; invalid/range day/month `... is incorrect.`; year non-int or not four chars `Year is incorrect.`. Combined validation runs on submit, group touch, or complete input. DOB invalid/future: `Enter a valid date of birth.` / `Date of birth cannot be in the future.` Expiry invalid/past/not-after-departure: `Enter a valid passport expiry date.` / `Passport expiry date cannot be in the past.` / `Passport expiry date must be after travel date.` Required group copy: `Date of birth is required.` / `Passport expiry date is required.` Preserve Android precedence.

## Countries and backend boundary

`CountryOption(isoCode,countryName,nationalityLabel,dialCode)` with country/dial search labels. Catalog puts ET/Ethiopia/Ethiopian/+251 first, then Locale ISO regions sorted by localized country name. Case-insensitive ISO/name lookup and selected-index unknown fallback to Ethiopia. Explicit dial codes: ET251, US/CA1, GB44, KE254, UG256, TZ255, AE971, SA966, ZA27, NG234, IN91, CN86, DE49, FR33, IT39, ES34, TR90, EG20; else empty. Tests assert invariants, not host locale ordering beyond Ethiopia-first.

Android domain request is not backend DTO. Backend expects booking route ID, contact email/phone, coded title/gender/type, ISO dates, bounded codes/passport, mandatory passport-upload UUID. PD-1 must map explicitly after signed upload; never serialize this domain request directly. Local attachment URI is not upload ID.

## TDD and exclusions

Commit tests-only RED then minimum GREEN. Cover defaults/status labels/fullName/results; digit filtering/completeness/leap/invalid/year bounds/synchronization; selective vs submit date behavior; DOB/expiry boundary+precedence; every required message; email and phone matrices; stable summary/dedup/removal; Ethiopia catalog/lookups/dials/fallback.

Exclude ViewModel/screens/events/navigation/sheets, repos/adapters/DTO/mappers, passport upload, booking journey, seats, review/submit models, idempotency, network/auth/persistence/async/assets. Done only after exact parity tests and latest PR-head CI green.
