import Foundation
import Testing
@testable import NexusTravel

struct FlightSearchModelsTests {
    @Test func requestFactoryBuildsValidShapesAndDefaultAges() throws {
        let departure = try #require(LocalDate(iso8601: "2026-06-01"))
        let returning = try #require(LocalDate(iso8601: "2026-06-08"))
        let travelers = TravelerCounts(adults: 2, children: 2, infants: 1)
        let oneWay = try #require(FlightSearchRequest.make(
            tripType: .oneWay, originCode: "ADD", destinationCode: "DXB",
            departureDate: departure, returnDate: nil, travelers: travelers, cabinClass: .economy
        ))
        #expect(oneWay.tripType == .oneWay)
        #expect(oneWay.returnDate == nil)
        #expect(oneWay.childAges == [2, 2])
        #expect(oneWay.infantAges == [0])

        let roundTrip = try #require(FlightSearchRequest.make(
            tripType: .roundTrip, originCode: "ADD", destinationCode: "DXB",
            departureDate: departure, returnDate: returning, travelers: travelers, cabinClass: .business
        ))
        #expect(roundTrip.returnDate == returning)

        let legs = [
            FlightSearchLeg(originCode: "ADD", destinationCode: "DXB", departureDate: departure),
            FlightSearchLeg(originCode: "DXB", destinationCode: "NBO", departureDate: returning)
        ]
        let multiCity = try #require(FlightSearchRequest.make(
            tripType: .multiCity, originCode: "ignored", destinationCode: "ignored",
            departureDate: departure, returnDate: nil, travelers: travelers, cabinClass: .first, legs: legs
        ))
        #expect(multiCity.originCode == "ADD")
        #expect(multiCity.destinationCode == "NBO")
        #expect(multiCity.legs == legs)
    }

    @Test func requestFactoryRejectsInvalidRequiredShape() throws {
        let departure = try #require(LocalDate(iso8601: "2026-06-01"))
        #expect(FlightSearchRequest.make(
            tripType: .roundTrip, originCode: "ADD", destinationCode: "DXB",
            departureDate: departure, returnDate: nil, travelers: TravelerCounts(), cabinClass: .economy
        ) == nil)
        #expect(FlightSearchRequest.make(
            tripType: .multiCity, originCode: "", destinationCode: "",
            departureDate: departure, returnDate: nil, travelers: TravelerCounts(), cabinClass: .economy,
            legs: [FlightSearchLeg(originCode: "ADD", destinationCode: "DXB", departureDate: departure)]
        ) == nil)
        #expect(FlightSearchRequest.make(
            tripType: .multiCity, originCode: "", destinationCode: "",
            departureDate: departure, returnDate: nil, travelers: TravelerCounts(), cabinClass: .economy,
            legs: Array(repeating: FlightSearchLeg(originCode: "ADD", destinationCode: "DXB", departureDate: departure), count: 4)
        ) == nil)
    }

    @Test func labelsSortCycleAndReportedStopCountMatchAndroid() throws {
        #expect(FlightOfferBadge.bestValue.label == "Best Value")
        #expect(SearchFilter.nonStop.label == "Non-stop")
        #expect(SortOption.recommended.label == "Sort")
        #expect(SortOption.recommended.next() == .bestPrice)
        #expect(SortOption.bestPrice.next() == .fastest)
        #expect(SortOption.fastest.next() == .departureEarly)
        #expect(SortOption.departureEarly.next() == .recommended)
        let time = try #require(LocalTime(hhmm: "10:00"))
        let stop = FlightStop(airportCode: "NBO", layoverMinutes: 60)
        let reported = FlightLeg(departureAirportCode: "ADD", arrivalAirportCode: "DXB", departureTime: time, arrivalTime: time, durationMinutes: 100, stops: [stop], reportedStopCount: 2)
        let inferred = FlightLeg(departureAirportCode: "ADD", arrivalAirportCode: "DXB", departureTime: time, arrivalTime: time, durationMinutes: 100, stops: [stop])
        #expect(reported.stopCount == 2)
        #expect(inferred.stopCount == 1)
    }
}
