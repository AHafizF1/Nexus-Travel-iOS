/// Deterministic fake-search identifier codec matching Android behavior.
enum NexusSearchIdCodec {
    /// Encodes request fields into exact underscore-delimited search ID.
    static func encode(_ request: FlightSearchRequest) -> String {
        let travelers = request.travelers.normalized()
        return [
            "search", tripCode(request.tripType), request.originCode.uppercased(), request.destinationCode.uppercased(),
            request.departureDate.iso8601, request.returnDate?.iso8601 ?? "none", String(travelers.adults),
            String(travelers.children), String(travelers.infants), cabinCode(request.cabinClass),
            request.cheapestFirst ? "cheapest" : "normal"
        ].joined(separator: "_")
    }

    /// Decodes search ID, using deterministic fallback for invalid shape or date.
    static func decode(_ searchId: String, today: LocalDate) -> SearchResultsQuerySummary {
        let parts = searchId.split(separator: "_", omittingEmptySubsequences: false).map(String.init)
        guard parts.count >= 10, parts.first == "search",
              let departureDate = LocalDate(iso8601: parts[4]) else { return fallback(searchId, today: today) }
        let returnDate: LocalDate?
        if parts[5] == "none" {
            returnDate = nil
        } else if let parsed = LocalDate(iso8601: parts[5]) {
            returnDate = parsed
        } else {
            return fallback(searchId, today: today)
        }
        let travelers = TravelerCounts(adults: Int(parts[6]) ?? 1, children: Int(parts[7]) ?? 0,
                                       infants: Int(parts[8]) ?? 0).normalized()
        return SearchResultsQuerySummary(
            searchId: searchId, tripType: tripType(parts[1]), originCode: parts[2], destinationCode: parts[3],
            departureDate: departureDate, returnDate: returnDate, travelers: travelers,
            cabinClass: cabinClass(parts[9]), cheapestFirst: parts.count > 10 && parts[10] == "cheapest"
        )
    }

    private static func fallback(_ searchId: String, today: LocalDate) -> SearchResultsQuerySummary {
        let departure = today.addingDays(7) ?? today
        return SearchResultsQuerySummary(searchId: searchId, tripType: .roundTrip, originCode: "ADD",
            destinationCode: "DXB", departureDate: departure, returnDate: departure.addingDays(7),
            travelers: TravelerCounts(), cabinClass: .economy)
    }

    private static func tripCode(_ value: TripType) -> String {
        switch value {
        case .oneWay: "oneway"
        case .roundTrip: "roundtrip"
        case .multiCity: "multicity"
        }
    }

    private static func cabinCode(_ value: CabinClass) -> String {
        switch value {
        case .economy: "economy"
        case .premiumEconomy: "premiumeconomy"
        case .business: "business"
        case .first: "first"
        }
    }

    private static func tripType(_ code: String) -> TripType {
        switch code {
        case "roundtrip": .roundTrip
        case "multicity": .multiCity
        default: .oneWay
        }
    }

    private static func cabinClass(_ code: String) -> CabinClass {
        switch code {
        case "premiumeconomy": .premiumEconomy
        case "business": .business
        case "first": .first
        default: .economy
        }
    }
}
