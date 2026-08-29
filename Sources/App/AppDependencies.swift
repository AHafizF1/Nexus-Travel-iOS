import Foundation

@MainActor
struct AppDependencies {
    let transport: HTTPTransport
    let sessionStore: KeychainAuthSessionStore
    let airportCache: AirportCache
    let searchResultsCache: SearchResultsCache
    let searchResultsRepository: RemoteSearchResultsRepository
    let homeViewModel: HomeViewModel

    init() {
        let sharedTransport = HTTPTransport()
        let sharedSessionStore = KeychainAuthSessionStore()
        let sharedAirportCache = AirportCache()
        let sharedSearchResultsCache = SearchResultsCache()
        transport = sharedTransport
        sessionStore = sharedSessionStore
        airportCache = sharedAirportCache
        searchResultsCache = sharedSearchResultsCache
        searchResultsRepository = RemoteSearchResultsRepository(cache: sharedSearchResultsCache)
        homeViewModel = HomeViewModel(
            homeRepository: RemoteHomeRepository(transport: sharedTransport),
            airportRepository: RemoteAirportRepository(transport: sharedTransport, cache: sharedAirportCache),
            flightSearchRepository: RemoteFlightSearchRepository(transport: sharedTransport, cache: sharedSearchResultsCache),
            authRepository: RemoteAuthRepository(transport: sharedTransport, sessionStore: sharedSessionStore),
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
