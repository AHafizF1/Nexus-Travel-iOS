import Foundation
import Testing
@testable import NexusTravel

struct FlightDetailsModelsTests {
    @Test func preservesNestedDefaultsAndResultValues() throws {
        let segment = FlightDetailsSegment(
            departureAirportCode: "ADD",
            arrivalAirportCode: "DXB",
            layoverMinutes: nil
        )
        #expect(segment.departureDate == nil)
        #expect(segment.arrivalDate == nil)
        #expect(segment.departureTime == nil)
        #expect(segment.arrivalTime == nil)
        #expect(segment.durationMinutes == 0)
        #expect(segment.marketingAirlineName.isEmpty)
        #expect(segment.operatingAirlineName == nil)
        #expect(segment.flightNumber.isEmpty)
        #expect(segment.operatingFlightNumber == nil)
        #expect(segment.equipment == nil)
        #expect(segment.cabin == nil)
        #expect(segment.bookingClass == nil)

        let rules = FareRulesSummary(refundableLabel: "Refundable", changeLabel: "Changes", cancellationLabel: "Cancellation")
        #expect(rules.sections.isEmpty)

        let details = try makeDetails()
        #expect(details.fareAvailability == nil)
        let previous = Money(amount: 500, currency: "USD", formatted: "USD 500")
        if case let .priceChanged(previousTotal, updatedDetails) = FlightDetailsResult.priceChanged(previousTotal: previous, updatedDetails: details) {
            #expect(previousTotal == previous)
            #expect(updatedDetails == details)
        } else {
            Issue.record("Expected price-changed associated values")
        }
    }

    @Test func codableRoundTripsRepresentativeDetails() throws {
        let details = try makeDetails(fareAvailability: FareAvailability(status: "limited", remainingSeats: 2))
        let encoded = try JSONEncoder().encode(details)
        #expect(try JSONDecoder().decode(FlightDetails.self, from: encoded) == details)
    }
}

func makeDetails(
    airlineCode: String = "ET",
    price: Money = Money(amount: 56_500, currency: "ETB", formatted: "ETB 56,500"),
    returnDate: LocalDate? = nil,
    fareAvailability: FareAvailability? = nil,
    legs: [FlightDetailsLeg]? = nil
) throws -> FlightDetails {
    let departureDate = try #require(LocalDate(year: 2026, month: 6, day: 1))
    let departureTime = try #require(LocalTime(hour: 0, minute: 5))
    let arrivalTime = try #require(LocalTime(hour: 12, minute: 0))
    let reference = FlightOfferReference(searchId: "search", offerId: "offer", offerToken: "token", provider: .nexusFake, contentSource: nil, responseId: nil, productIds: [], termsAndConditionsId: nil, brandRef: nil, expiresAt: nil)
    let defaultLeg = FlightDetailsLeg(label: "Outbound", date: departureDate, departureAirportCode: "ADD", departureAirportName: "Bole", arrivalAirportCode: "DXB", arrivalAirportName: "Dubai", departureTime: departureTime, arrivalTime: arrivalTime, durationMinutes: 725, stopLabel: "Non-stop", segments: [])
    return FlightDetails(searchId: "search", offerId: "offer", reference: reference, offerToken: "token", source: nil, tripType: .oneWay, originCode: "ADD", destinationCode: "DXB", departureDate: departureDate, returnDate: returnDate, travelers: TravelerCounts(adults: 1, children: 1, infants: 1), cabinLabel: "Economy", airline: AirlineBrand(code: airlineCode, name: "Ethiopian"), flightNumber: "ET600", badge: .bestValue, price: price, oldPrice: nil, legs: legs ?? [defaultLeg], baggage: BaggageSummary(cabin: "7 kg", checked: "23 kg", included: true, detail: "Included"), fareRules: FareRulesSummary(refundableLabel: "Refundable", changeLabel: "Changes", cancellationLabel: "Cancellation"), priceBreakdown: PriceBreakdown(baseFare: price, taxesAndFees: Money(amount: 0, currency: price.currency, formatted: "\(price.currency) 0"), serviceFee: nil, total: price), aircraft: AircraftSummary(aircraftName: "Boeing 787", operatingAirline: "Ethiopian", note: ""), seat: SeatSummary(selectedSeat: nil, availabilityLabel: "Available", extraLegroomAvailable: true), expiresAt: Date(timeIntervalSince1970: 1_700_000_000), warnings: [SearchWarning(code: "notice", message: "Notice")], fareAvailability: fareAvailability)
}
