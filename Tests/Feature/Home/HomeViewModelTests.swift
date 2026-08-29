import Foundation
import Testing
@testable import NexusTravel

@MainActor
struct HomeViewModelTests {
    private let today = LocalDate(year: 2026, month: 8, day: 29)
    private let add = Airport(code: "ADD", city: "Addis Ababa", name: "Bole", country: "Ethiopia")
    private let dxb = Airport(code: "DXB", city: "Dubai", name: "Dubai International", country: "UAE")

    @Test func loadSuccessUsesGreetingDatesAndContent() async throws {
        let content = HomeContent(origin: add, destination: dxb, departureDate: "ignored", returnDate: "ignored",
                                  travelersLabel: "ignored", cabinClass: "ignored", trendingEscapes: [], recentSearches: [])
        let model = makeModel(homeResult: .success(content), displayName: "  Afiz Mohamed  ")

        try await model.load()

        #expect(model.uiState.userName == "Afiz")
        #expect(model.uiState.departureDate == today.addingDays(7))
        #expect(model.uiState.returnDate == today.addingDays(14))
        #expect(model.uiState.origin == add)
        #expect(model.uiState.destination == dxb)
        #expect(!model.uiState.isLoading)
    }

    @Test(arguments: [
        (HomeResult<HomeContent>.networkUnavailable, "You are offline. Check your connection and try again."),
        (.unknownError, "We could not load your home page. Please try again.")
    ])
    func loadFailureUsesAirportFallback(_ result: HomeResult<HomeContent>, _ message: String) async throws {
        let model = makeModel(homeResult: result)
        try await model.load()
        #expect(model.uiState.origin == add)
        #expect(model.uiState.destination == dxb)
        #expect(model.uiState.message == message)
    }

    @Test func reloadPreservesServiceAndSheet() async throws {
        let model = makeModel()
        await model.onEvent(.flightClicked)
        await model.onEvent(.originClicked)
        try await model.load()
        #expect(model.uiState.selectedService == .flight)
        #expect(model.uiState.activeSheet == .originAirport)
    }

    @Test func eventsCoverTripAirportDateTravelerAndCabinTransitions() async throws {
        let model = makeModel()
        try await model.load()
        await model.onEvent(.tripTypeChanged(.roundTrip))
        await model.onEvent(.swapAirportsClicked)
        await model.onEvent(.departureDateSelected(today.addingDays(20)))
        await model.onEvent(.travelersChanged(TravelerCounts(adults: 2, children: 2, infants: 3), childAges: [4, 7], infantAges: [0, 1, 1]))
        await model.onEvent(.cabinClassChanged(.business))
        #expect(model.uiState.origin == dxb)
        #expect(model.uiState.destination == add)
        #expect(model.uiState.returnDate == today.addingDays(27))
        #expect(model.uiState.travelers == TravelerCounts(adults: 2, children: 2, infants: 2))
        #expect(model.uiState.infantAges == [0, 1])
        #expect(model.uiState.cabinClass == .business)
    }

    @Test func airportSelectionFlagsSameRouteAndDismissClearsQuery() async throws {
        let model = makeModel()
        try await model.load()
        await model.onEvent(.originClicked)
        await model.onEvent(.airportQueryChanged("dub"))
        await model.onEvent(.airportSelected(dxb))
        #expect(model.uiState.validationError == .sameOriginDestination)
        await model.onEvent(.destinationClicked)
        await model.onEvent(.dismissSheet)
        #expect(model.uiState.airportQuery.isEmpty)
        #expect(model.uiState.activeSheet == nil)
    }

    @Test func packagesAndSuccessfulSearchEmitTypedNavigationOnce() async throws {
        let model = makeModel(searchResult: .success(searchId: "search-42"))
        try await model.load()
        await model.onEvent(.packageClicked)
        #expect(model.consumeNavigationEvent() == .toPackages)
        #expect(model.consumeNavigationEvent() == nil)
        await model.onEvent(.searchClicked)
        #expect(model.consumeNavigationEvent() == .toSearchResults(searchId: "search-42"))
        #expect(!model.uiState.isSearching)
    }

    @Test(arguments: [
        (FlightSearchResult.networkUnavailable, "We lost the connection. Try again."),
        (.unknownError, "No fares found for this route. Contact Nexus for help.")
    ])
    func searchFailureShowsExactMessage(_ result: FlightSearchResult, _ message: String) async throws {
        let model = makeModel(searchResult: result)
        try await model.load()
        await model.onEvent(.searchClicked)
        #expect(model.uiState.message == message)
        #expect(model.consumeNavigationEvent() == nil)
    }

    @Test func prefillAndMultiCityTransitionsMatchAndroid() async throws {
        let model = makeModel()
        try await model.load()
        await model.prefillDestination(airportCode: "add")
        #expect(model.uiState.destination == add)
        await model.onEvent(.tripTypeChanged(.multiCity))
        await model.onEvent(.addMultiCityLeg)
        #expect(model.uiState.multiCityLegs.count == 3)
        await model.onEvent(.removeMultiCityLeg(index: 1))
        #expect(model.uiState.multiCityLegs.count == 2)
    }

    private func makeModel(
        homeResult: HomeResult<HomeContent>? = nil,
        searchResult: FlightSearchResult = .success(searchId: "search-1"),
        displayName: String? = nil
    ) -> HomeViewModel {
        let content = HomeContent(origin: add, destination: dxb, departureDate: "", returnDate: "",
                                  travelersLabel: "", cabinClass: "", trendingEscapes: [], recentSearches: [])
        return HomeViewModel(
            homeRepository: StubHomeRepository(result: homeResult ?? .success(content)),
            airportRepository: StubAirportRepository(airports: [add, dxb]),
            flightSearchRepository: StubFlightSearchRepository(result: searchResult),
            authRepository: StubAuthRepository(displayName: displayName),
            today: { self.today }
        )
    }
}

private struct StubHomeRepository: HomeRepository {
    let result: HomeResult<HomeContent>
    func getHomeContent() async throws -> HomeResult<HomeContent> { result }
}

private struct StubAirportRepository: AirportRepository {
    let airports: [Airport]
    func searchAirports(query: String) async throws -> [Airport] {
        query.isEmpty ? airports : airports.filter { $0.code.localizedCaseInsensitiveContains(query) }
    }
}

private struct StubFlightSearchRepository: FlightSearchRepository {
    let result: FlightSearchResult
    func createSearch(request: FlightSearchRequest) async throws -> FlightSearchResult { result }
}

private struct StubAuthRepository: AuthRepository {
    let displayName: String?
    func getLocalSession() async throws -> AuthSession? {
        guard let displayName else { return nil }
        return AuthSession(sessionId: "session", user: AuthUser(id: "user", displayName: displayName,
                           email: "a@example.com", avatarUrl: nil), tokens: nil, expiresAt: .distantFuture)
    }
    func signInEmail(request: SignInRequest) async throws -> AuthResult<AuthSession> { .failure(.unknown) }
    func signUpEmail(request: SignUpRequest) async throws -> AuthResult<AuthSession> { .failure(.unknown) }
    func getSession() async throws -> AuthResult<AuthSession> { .failure(.unauthenticated) }
    func requestPasswordReset(email: String) async throws -> AuthResult<Void> { .failure(.unknown) }
    func signOut() async throws -> AuthResult<Void> { .success(()) }
}
