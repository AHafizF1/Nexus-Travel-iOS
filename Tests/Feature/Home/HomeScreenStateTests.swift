import Testing
@testable import NexusTravel

struct HomeScreenStateTests {
    @Test func presentationKindsCoverFourRequiredStates() {
        #expect(HomeScreenState(state: HomeUiState()).kind == .loading)
        #expect(HomeScreenState(state: HomeUiState(isLoading: false)).kind == .empty)
        #expect(HomeScreenState(state: HomeUiState(isLoading: false, message: "Offline")).kind == .error)
        let airport = Airport(code: "ADD", city: "Addis Ababa", name: "Bole", country: "Ethiopia")
        let escape = TrendingEscape(id: "one", airport: airport, tags: [],
                                    startingPrice: Money(amount: 0, currency: "USD", formatted: ""), imageName: "")
        #expect(HomeScreenState(state: HomeUiState(isLoading: false, trendingEscapes: [escape])).kind == .content)
    }

    @Test func transientSearchMessageDoesNotReplaceLoadedDiscovery() {
        let state = HomeUiState(
            isLoading: false,
            message: "We lost the connection. Try again.",
            loadPhase: .content
        )
        #expect(HomeScreenState(state: state).kind == .content)
    }

    @Test func everySheetHasStableIdentity() {
        let sheets: [HomeSheet] = [.originAirport, .destinationAirport, .departureDate, .returnDate,
            .multiCityOrigin(index: 0), .multiCityDestination(index: 0), .multiCityDate(index: 0),
            .travelers, .cabinClass, .hotelComingSoon]
        #expect(Set(sheets.map(\.id)).count == sheets.count)
    }
}
