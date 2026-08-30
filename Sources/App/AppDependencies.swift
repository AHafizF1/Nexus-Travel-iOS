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
    let flightSeatsRepository: RemoteFlightSeatsRepository
    let bookingRequestRepository: RemoteBookingRequestRepository
    let paymentProofRepository: RemotePaymentProofRepository
    let tripsRepository: RemoteTripsRepository
    let profileRepository: RemoteProfileRepository
    let preferencesRepository: RemotePreferencesRepository
    let securityRepository: RemoteAccountSecurityRepository
    let airportRepository: RemoteAirportRepository
    let appTheme: AppTheme
    let profileViewModel: ProfileViewModel
    let preferencesViewModel: PreferencesViewModel
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
        let sharedTokenProvider = AuthTokenProvider(sessionStore: sharedSessionStore)
        let sharedPreferencesStore = ProfilePreferencesStore()
        let sharedAppTheme = AppTheme()
        let sharedProfileRepository = RemoteProfileRepository(transport: sharedTransport, tokenProvider: sharedTokenProvider)
        let sharedPreferencesRepository = RemotePreferencesRepository(transport: sharedTransport, tokenProvider: sharedTokenProvider, store: sharedPreferencesStore)
        let sharedSecurityRepository = RemoteAccountSecurityRepository(transport: sharedTransport, tokenProvider: sharedTokenProvider)
        transport = sharedTransport
        sessionStore = sharedSessionStore
        airportCache = sharedAirportCache
        airportRepository = sharedAirportRepository
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
        flightSeatsRepository = RemoteFlightSeatsRepository(
            transport: sharedTransport, tokenProvider: AuthTokenProvider(sessionStore: sharedSessionStore)
        )
        bookingRequestRepository = RemoteBookingRequestRepository(
            transport: sharedTransport, tokenProvider: AuthTokenProvider(sessionStore: sharedSessionStore)
        )
        paymentProofRepository = RemotePaymentProofRepository(
            transport: sharedTransport, tokenProvider: AuthTokenProvider(sessionStore: sharedSessionStore)
        )
        tripsRepository = RemoteTripsRepository(
            transport: sharedTransport, tokenProvider: AuthTokenProvider(sessionStore: sharedSessionStore),
            cache: TripCache(), ticketStore: TicketPdfStore()
        )
        profileRepository = sharedProfileRepository
        preferencesRepository = sharedPreferencesRepository
        securityRepository = sharedSecurityRepository
        appTheme = sharedAppTheme
        profileViewModel = ProfileViewModel(repository: sharedProfileRepository, authRepository: sharedAuthRepository)
        preferencesViewModel = PreferencesViewModel(repository: sharedPreferencesRepository, onTheme: { sharedAppTheme.preference = $0 })
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
