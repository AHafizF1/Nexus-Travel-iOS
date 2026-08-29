import Foundation
import Testing
@testable import NexusTravel

struct SearchRequestMapperTests {
    @Test(arguments: [
        (CabinClass.economy, "ECONOMY"), (.premiumEconomy, "PREMIUM_ECONOMY"),
        (.business, "BUSINESS"), (.first, "FIRST")
    ])
    func encodesCabinValues(_ cabin: CabinClass, _ raw: String) throws {
        let dto = SearchRequestDTO(try request(cabin: cabin))
        #expect(dto.cabinClass == raw)
    }

    @Test func oneWayUsesUppercaseRootShapeAndNormalizedTravelers() throws {
        let dto = SearchRequestDTO(try request(travelers: .init(adults: 0, children: 9, infants: 9)))
        #expect(dto.tripType == "ONE_WAY")
        #expect(dto.from == "JFK" && dto.to == "LHR")
        #expect(dto.departureDate == "2026-08-01" && dto.returnDate == nil && dto.legs == nil)
        #expect(dto.adults == 1 && dto.children == 8 && dto.infants == 0)
        #expect(dto.childAges == [4] && dto.infantAges == [1])
    }

    @Test func roundTripIncludesOnlyReturnRootDate() throws {
        let value = try #require(FlightSearchRequest.make(tripType: .roundTrip, originCode: "JFK", destinationCode: "LHR", departureDate: date(1), returnDate: date(8), travelers: .init(), cabinClass: .business))
        let dto = SearchRequestDTO(value)
        #expect(dto.tripType == "ROUND_TRIP" && dto.returnDate == "2026-08-08" && dto.legs == nil)
    }

    @Test func multiCityOmitsAllRootRouteFields() throws {
        let legs = [FlightSearchLeg(originCode: "NBO", destinationCode: "DXB", departureDate: date(1)), FlightSearchLeg(originCode: "DXB", destinationCode: "LHR", departureDate: date(5))]
        let value = try #require(FlightSearchRequest.make(tripType: .multiCity, originCode: "", destinationCode: "", departureDate: date(1), returnDate: nil, travelers: .init(), cabinClass: .first, legs: legs))
        let dto = SearchRequestDTO(value)
        #expect(dto.tripType == "MULTI_CITY" && dto.from == nil && dto.to == nil)
        #expect(dto.departureDate == nil && dto.returnDate == nil && dto.legs?.count == 2)
    }

    private func request(cabin: CabinClass = .economy, travelers: TravelerCounts = .init()) throws -> FlightSearchRequest {
        try #require(FlightSearchRequest.make(tripType: .oneWay, originCode: "JFK", destinationCode: "LHR", departureDate: date(1), returnDate: nil, travelers: travelers, cabinClass: cabin, cheapestFirst: true, childAges: [4], infantAges: [1]))
    }
    private func date(_ day: Int) -> LocalDate {
        guard let value = LocalDate(year: 2026, month: 8, day: day) else { preconditionFailure("Valid fixture date") }
        return value
    }
}
