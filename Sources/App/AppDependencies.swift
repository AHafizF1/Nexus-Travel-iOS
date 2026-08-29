import Foundation

@MainActor
struct AppDependencies {
    let transport: HTTPTransport
    let sessionStore: KeychainAuthSessionStore
    let airportCache: AirportCache
    let searchResultsCache: SearchResultsCache
    let searchResultsRepository: RemoteSearchResultsRepository
    let flightDetailsRepository: RemoteFlightDetailsRepository
    let passengerDetailsRepository: RemotePassengerDetailsRepository
    let authRepository: RemoteAuthRepository
    let homeViewModel: HomeViewModel

    init() {
        let sharedTransport = HTTPTransport()
        let sharedSessionStore = KeychainAuthSessionStore()
        let sharedAirportCache = AirportCache()
        let sharedSearchResultsCache = SearchResultsCache()
        let sharedAuthRepository = RemoteAuthRepository(
            transport: sharedTransport,
            sessionStore: sharedSessionStore
        )
        let sharedAirportRepository = RemoteAirportRepository(
            transport: sharedTransport,
            cache: sharedAirportCache
        )
        transport = sharedTransport
        sessionStore = sharedSessionStore
        airportCache = sharedAirportCache
        searchResultsCache = sharedSearchResultsCache
        searchResultsRepository = RemoteSearchResultsRepository(cache: sharedSearchResultsCache)
        flightDetailsRepository = RemoteFlightDetailsRepository(transport: sharedTransport)
        passengerDetailsRepository = RemotePassengerDetailsRepository(
            transport: sharedTransport,
            tokenProvider: AuthTokenProvider(sessionStore: sharedSessionStore),
            passportUploadRepository: RemotePassportUploadRepository(
                transport: sharedTransport, tokenProvider: AuthTokenProvider(sessionStore: sharedSessionStore)
            )
        )
        authRepository = sharedAuthRepository
        homeViewModel = HomeViewModel(
            homeRepository: RemoteHomeRepository(
                transport: sharedTransport,
                airportRepository: sharedAirportRepository
            ),
            airportRepository: sharedAirportRepository,
            flightSearchRepository: RemoteFlightSearchRepository(transport: sharedTransport, cache: sharedSearchResultsCache),
            authRepository: sharedAuthRepository,
            today: Self.currentLocalDate
        )
    }

    private static func currentLocalDate() -> LocalDate {
        let components = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: Date())
        guard let year = components.year, let month = components.month, let day = components.day,
              let date = LocalDate(year: year, month: month, day: day) else {
            preconditionFailure("Current Gregorian date must be representable.")
        }
        return date
    }
}
