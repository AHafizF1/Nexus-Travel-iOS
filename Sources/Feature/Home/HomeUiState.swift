/// Editable state for one multi-city flight leg.
struct MultiCityLegUiState: Equatable, Hashable, Codable, Sendable {
    let origin: Airport?
    let destination: Airport?
    let departureDate: LocalDate?
    let originAutoLinked: Bool

    /// Creates a leg with optional route and date selections.
    init(
        origin: Airport? = nil,
        destination: Airport? = nil,
        departureDate: LocalDate? = nil,
        originAutoLinked: Bool = false
    ) {
        self.origin = origin
        self.destination = destination
        self.departureDate = departureDate
        self.originAutoLinked = originAutoLinked
    }
}

/// Search validation failure shown by home.
enum HomeValidationError: Equatable, Hashable, Codable, Sendable {
    case missingOrigin
    case missingDestination
    case sameOriginDestination
    case missingDepartureDate
    case missingReturnDate
    case returnBeforeDeparture
    case departureDateInPast
    case invalidMultiCityLegs
}

/// Presentation-independent home fields needed by search validation and multi-city transitions.
struct HomeUiState: Equatable, Hashable, Codable, Sendable {
    let isLoading: Bool
    let userName: String
    let tripType: TripType
    let origin: Airport?
    let destination: Airport?
    let departureDate: LocalDate?
    let returnDate: LocalDate?
    let travelers: TravelerCounts
    let childAges: [Int]
    let infantAges: [Int]
    let cabinClass: CabinClass
    let multiCityLegs: [MultiCityLegUiState]
    let trendingEscapes: [TrendingEscape]
    let recentSearches: [RecentSearch]
    let airports: [Airport]
    let airportQuery: String
    let validationError: HomeValidationError?
    let isSearching: Bool
    let message: String?

    /// Creates home state with Android-equivalent defaults.
    init(
        isLoading: Bool = true,
        userName: String = "Traveler",
        tripType: TripType = .oneWay,
        origin: Airport? = nil,
        destination: Airport? = nil,
        departureDate: LocalDate? = nil,
        returnDate: LocalDate? = nil,
        travelers: TravelerCounts = TravelerCounts(),
        childAges: [Int] = [],
        infantAges: [Int] = [],
        cabinClass: CabinClass = .economy,
        multiCityLegs: [MultiCityLegUiState] = [],
        trendingEscapes: [TrendingEscape] = [],
        recentSearches: [RecentSearch] = [],
        airports: [Airport] = [],
        airportQuery: String = "",
        validationError: HomeValidationError? = nil,
        isSearching: Bool = false,
        message: String? = nil
    ) {
        self.isLoading = isLoading
        self.userName = userName
        self.tripType = tripType
        self.origin = origin
        self.destination = destination
        self.departureDate = departureDate
        self.returnDate = returnDate
        self.travelers = travelers
        self.childAges = childAges
        self.infantAges = infantAges
        self.cabinClass = cabinClass
        self.multiCityLegs = multiCityLegs
        self.trendingEscapes = trendingEscapes
        self.recentSearches = recentSearches
        self.airports = airports
        self.airportQuery = airportQuery
        self.validationError = validationError
        self.isSearching = isSearching
        self.message = message
    }

    /// Returns state after Android-equivalent trip-type transition.
    func settingTripType(_ tripType: TripType) -> HomeUiState {
        let legs = tripType == .multiCity && multiCityLegs.isEmpty
            ? initialMultiCityLegs(origin: origin, destination: destination, date: departureDate)
            : multiCityLegs
        let error = tripType == .oneWay && validationError == .returnBeforeDeparture
            ? nil
            : validationError
        return replacing(tripType: tripType, multiCityLegs: legs, validationError: error)
    }

    private func replacing(
        tripType: TripType,
        multiCityLegs: [MultiCityLegUiState],
        validationError: HomeValidationError?
    ) -> HomeUiState {
        HomeUiState(
            isLoading: isLoading,
            userName: userName,
            tripType: tripType,
            origin: origin,
            destination: destination,
            departureDate: departureDate,
            returnDate: returnDate,
            travelers: travelers,
            childAges: childAges,
            infantAges: infantAges,
            cabinClass: cabinClass,
            multiCityLegs: multiCityLegs,
            trendingEscapes: trendingEscapes,
            recentSearches: recentSearches,
            airports: airports,
            airportQuery: airportQuery,
            validationError: validationError,
            isSearching: isSearching,
            message: message
        )
    }
}
