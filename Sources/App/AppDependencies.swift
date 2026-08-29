import Foundation

@MainActor
struct AppDependencies {
    let homeViewModel: HomeViewModel

    init() {
        let transport = HTTPTransport()
        let sessionStore = KeychainAuthSessionStore()
        let airportCache = AirportCache()
        let searchResultsCache = SearchResultsCache()
        homeViewModel = HomeViewModel(
            homeRepository: RemoteHomeRepository(transport: transport),
            airportRepository: RemoteAirportRepository(transport: transport, cache: airportCache),
            flightSearchRepository: RemoteFlightSearchRepository(transport: transport, cache: searchResultsCache),
            authRepository: RemoteAuthRepository(transport: transport, sessionStore: sessionStore),
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
