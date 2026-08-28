import Testing
@testable import NexusTravel

struct NexusSearchIdCodecTests {
    @Test func encodesExactNormalizedUppercaseID() throws {
        let departure = try #require(LocalDate(iso8601: "2026-09-04"))
        let returning = try #require(LocalDate(iso8601: "2026-09-11"))
        let request = try #require(FlightSearchRequest.make(
            tripType: .roundTrip, originCode: "add", destinationCode: "dxb",
            departureDate: departure, returnDate: returning,
            travelers: TravelerCounts(adults: 0, children: 20, infants: 4),
            cabinClass: .premiumEconomy, cheapestFirst: true
        ))
        #expect(NexusSearchIdCodec.encode(request) == "search_roundtrip_ADD_DXB_2026-09-04_2026-09-11_1_8_0_premiumeconomy_cheapest")
    }

    @Test func encodesTripAndCabinCodes() throws {
        let departure = try #require(LocalDate(iso8601: "2026-09-04"))
        let returning = try #require(LocalDate(iso8601: "2026-09-11"))
        let leg = FlightSearchLeg(originCode: "add", destinationCode: "nbo", departureDate: departure)
        let second = FlightSearchLeg(originCode: "nbo", destinationCode: "dxb", departureDate: returning)
        let request = try #require(FlightSearchRequest.make(
            tripType: .multiCity, originCode: "", destinationCode: "", departureDate: departure,
            returnDate: nil, travelers: TravelerCounts(), cabinClass: .first, legs: [leg, second]
        ))
        #expect(NexusSearchIdCodec.encode(request) == "search_multicity_ADD_DXB_2026-09-04_none_1_0_0_first_normal")
    }

    @Test func decodesKnownAndUnknownValues() throws {
        let today = try #require(LocalDate(iso8601: "2026-08-28"))
        let returning = try #require(LocalDate(iso8601: "2026-09-11"))
        let known = NexusSearchIdCodec.decode("search_roundtrip_ADD_DXB_2026-09-04_2026-09-11_2_1_1_business_cheapest", today: today)
        #expect(known.searchId == "search_roundtrip_ADD_DXB_2026-09-04_2026-09-11_2_1_1_business_cheapest")
        #expect(known.tripType == .roundTrip)
        #expect(known.returnDate == returning)
        #expect(known.travelers == TravelerCounts(adults: 2, children: 1, infants: 1))
        #expect(known.cabinClass == .business)
        #expect(known.cheapestFirst)

        let unknown = NexusSearchIdCodec.decode("search_unknown_add_dxb_2026-09-04_none_bad_bad_bad_unknown", today: today)
        #expect(unknown.tripType == .oneWay)
        #expect(unknown.travelers == TravelerCounts())
        #expect(unknown.cabinClass == .economy)
        #expect(!unknown.cheapestFirst)
    }

    @Test func invalidShapeOrDateUsesInjectedFallback() throws {
        let today = try #require(LocalDate(iso8601: "2026-08-28"))
        let departure = try #require(LocalDate(iso8601: "2026-09-04"))
        let returning = try #require(LocalDate(iso8601: "2026-09-11"))
        for id in ["bad", "search_roundtrip_ADD_DXB_bad_none_1_0_0_economy_normal", "search_roundtrip_ADD_DXB_2026-09-04_bad_1_0_0_economy_normal"] {
            let summary = NexusSearchIdCodec.decode(id, today: today)
            #expect(summary.searchId == id)
            #expect(summary.tripType == .roundTrip)
            #expect(summary.originCode == "ADD")
            #expect(summary.destinationCode == "DXB")
            #expect(summary.departureDate == departure)
            #expect(summary.returnDate == returning)
            #expect(summary.travelers == TravelerCounts())
            #expect(summary.cabinClass == .economy)
        }
    }
}
