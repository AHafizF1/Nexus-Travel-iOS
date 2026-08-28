/// One origin, destination, and departure date in a flight search.
struct FlightSearchLeg: Equatable, Hashable, Codable, Sendable {
    let originCode: String
    let destinationCode: String
    let departureDate: LocalDate
}

/// Valid one-way, round-trip, or multi-city flight search request.
struct FlightSearchRequest: Equatable, Hashable, Sendable {
    let tripType: TripType
    let originCode: String
    let destinationCode: String
    let departureDate: LocalDate
    let returnDate: LocalDate?
    let travelers: TravelerCounts
    let cabinClass: CabinClass
    let cheapestFirst: Bool
    let legs: [FlightSearchLeg]
    let childAges: [Int]
    let infantAges: [Int]

    private init(tripType: TripType, originCode: String, destinationCode: String, departureDate: LocalDate,
                 returnDate: LocalDate?, travelers: TravelerCounts, cabinClass: CabinClass,
                 cheapestFirst: Bool, legs: [FlightSearchLeg], childAges: [Int], infantAges: [Int]) {
        self.tripType = tripType
        self.originCode = originCode
        self.destinationCode = destinationCode
        self.departureDate = departureDate
        self.returnDate = returnDate
        self.travelers = travelers
        self.cabinClass = cabinClass
        self.cheapestFirst = cheapestFirst
        self.legs = legs
        self.childAges = childAges
        self.infantAges = infantAges
    }

    /// Creates a request only when trip-specific required fields form a valid shape.
    static func make(
        tripType: TripType,
        originCode: String,
        destinationCode: String,
        departureDate: LocalDate,
        returnDate: LocalDate?,
        travelers: TravelerCounts,
        cabinClass: CabinClass,
        cheapestFirst: Bool = false,
        legs: [FlightSearchLeg] = [],
        childAges: [Int]? = nil,
        infantAges: [Int]? = nil
    ) -> FlightSearchRequest? {
        let resolvedChildAges = childAges ?? Array(repeating: 2, count: max(travelers.children, 0))
        let resolvedInfantAges = infantAges ?? Array(repeating: 0, count: max(travelers.infants, 0))
        switch tripType {
        case .oneWay:
            return FlightSearchRequest(tripType: tripType, originCode: originCode, destinationCode: destinationCode,
                departureDate: departureDate, returnDate: nil, travelers: travelers, cabinClass: cabinClass,
                cheapestFirst: cheapestFirst, legs: [], childAges: resolvedChildAges, infantAges: resolvedInfantAges)
        case .roundTrip:
            guard let returnDate else { return nil }
            return FlightSearchRequest(tripType: tripType, originCode: originCode, destinationCode: destinationCode,
                departureDate: departureDate, returnDate: returnDate, travelers: travelers, cabinClass: cabinClass,
                cheapestFirst: cheapestFirst, legs: [], childAges: resolvedChildAges, infantAges: resolvedInfantAges)
        case .multiCity:
            guard (2...3).contains(legs.count), let first = legs.first, let last = legs.last else { return nil }
            return FlightSearchRequest(tripType: tripType, originCode: first.originCode, destinationCode: last.destinationCode,
                departureDate: first.departureDate, returnDate: nil, travelers: travelers, cabinClass: cabinClass,
                cheapestFirst: cheapestFirst, legs: legs, childAges: resolvedChildAges, infantAges: resolvedInfantAges)
        }
    }
}

/// Result of creating a flight search.
enum FlightSearchResult: Equatable, Sendable {
    case success(searchId: String)
    case networkUnavailable
    case unknownError
}
