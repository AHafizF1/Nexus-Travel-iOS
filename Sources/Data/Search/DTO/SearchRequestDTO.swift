/// Backend flight-search request body.
struct SearchRequestDTO: Codable, Equatable, Sendable {
    let tripType: String
    let from: String?
    let to: String?
    let departureDate: String?
    let returnDate: String?
    let legs: [SearchLegDTO]?
    let adults: Int
    let children: Int
    let infants: Int
    let childAges: [Int]
    let infantAges: [Int]
    let cabinClass: String
    let cheapestFirst: Bool

    /// Maps domain request to exact backend route shape.
    init(_ request: FlightSearchRequest) {
        let travelers = request.travelers.normalized()
        tripType = request.tripType.backendValue
        from = request.tripType == .multiCity ? nil : request.originCode.uppercased()
        to = request.tripType == .multiCity ? nil : request.destinationCode.uppercased()
        departureDate = request.tripType == .multiCity ? nil : request.departureDate.iso8601
        returnDate = request.tripType == .roundTrip ? request.returnDate?.iso8601 : nil
        legs = request.tripType == .multiCity ? request.legs.map(SearchLegDTO.init) : nil
        adults = travelers.adults
        children = travelers.children
        infants = travelers.infants
        childAges = request.childAges
        infantAges = request.infantAges
        cabinClass = request.cabinClass.backendValue
        cheapestFirst = request.cheapestFirst
    }
}

/// One backend multi-city request leg.
struct SearchLegDTO: Codable, Equatable, Sendable {
    let from: String
    let to: String
    let departureDate: String

    init(_ leg: FlightSearchLeg) {
        from = leg.originCode.uppercased()
        to = leg.destinationCode.uppercased()
        departureDate = leg.departureDate.iso8601
    }
}

private extension TripType {
    var backendValue: String {
        switch self { case .oneWay: "ONE_WAY"; case .roundTrip: "ROUND_TRIP"; case .multiCity: "MULTI_CITY" }
    }
}

private extension CabinClass {
    var backendValue: String {
        switch self { case .economy: "ECONOMY"; case .premiumEconomy: "PREMIUM_ECONOMY"; case .business: "BUSINESS"; case .first: "FIRST" }
    }
}
