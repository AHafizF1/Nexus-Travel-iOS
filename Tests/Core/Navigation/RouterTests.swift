import Testing
@testable import NexusTravel

@MainActor
struct RouterTests {
    @Test
    func initialStateSelectsHomeWithEmptyHistories() {
        let router = Router()

        #expect(router.selectedTab == .home)
        #expect(MainTab.allCases == [.home, .explore, .trips, .profile])
        #expect(router.homePath.isEmpty)
        #expect(router.explorePath.isEmpty)
        #expect(router.tripsPath.isEmpty)
        #expect(router.profilePath.isEmpty)
    }

    @Test
    func switchingTabsPreservesIndependentHistories() {
        let router = Router()
        router.push(.searchResults(SearchResultsRoute(searchId: "search-1")))
        router.select(.explore)
        router.push(.destinationDetail(DestinationDetailRoute(destinationId: "destination-1")))
        router.select(.home)

        #expect(router.homePath == [.searchResults(SearchResultsRoute(searchId: "search-1"))])
        #expect(router.explorePath == [.destinationDetail(DestinationDetailRoute(destinationId: "destination-1"))])
    }

    @Test
    func reselectingCurrentTabPopsOnlyThatTabToRoot() {
        let router = Router()
        router.push(.searchResults(SearchResultsRoute(searchId: "search-1")))
        router.select(.explore)
        router.push(.packageDetail(PackageDetailRoute(packageId: "package-1")))

        router.select(.explore)

        #expect(router.explorePath.isEmpty)
        #expect(router.homePath.count == 1)
    }

    @Test
    func pushPopAndPopToRootAffectOnlySelectedTab() {
        let router = Router()
        router.push(.searchResults(SearchResultsRoute(searchId: "search-1")))
        let reference = FlightOfferReference(
            searchId: "search-1", offerId: "offer-1", offerToken: "token", provider: .travelportGds,
            contentSource: nil, responseId: nil, productIds: [], termsAndConditionsId: nil,
            brandRef: nil, expiresAt: nil
        )
        router.push(.flightDetails(FlightDetailsRoute(reference: reference)))
        router.pop()

        #expect(router.homePath == [.searchResults(SearchResultsRoute(searchId: "search-1"))])

        router.select(.profile)
        router.push(.settings(SettingsRoute()))
        router.popToRoot()

        #expect(router.profilePath.isEmpty)
        #expect(router.homePath.count == 1)
    }

    @Test
    func poppingEmptyPathIsSafeNoOp() {
        let router = Router()

        router.pop()

        #expect(router.homePath.isEmpty)
    }

    @Test
    func completingMainAuthSelectsPendingTabAndClearsIntent() {
        let router = Router()
        router.select(.profile)
        router.push(.settings(SettingsRoute()))
        router.select(.home)
        router.beginMainAuth(returningTo: .trips)

        #expect(router.pendingTab == .trips)
        #expect(router.homePath.last == .mainAuth(MainAuthRoute()))

        router.completeMainAuth()

        #expect(router.selectedTab == .trips)
        #expect(router.pendingTab == nil)
        #expect(router.homePath.isEmpty)
        #expect(router.profilePath == [.settings(SettingsRoute())])
    }

    @Test
    func completingMainAuthWithoutIntentFallsBackToHome() {
        let router = Router()
        router.select(.explore)

        router.completeMainAuth()

        #expect(router.selectedTab == .home)
        #expect(router.pendingTab == nil)
    }

    @Test
    func bookingAuthKeepsCurrentBookingPath() {
        let router = Router()
        router.push(.passengerDetails(PassengerDetailsRoute()))
        router.push(.bookingAuth(BookingAuthRoute()))

        router.completeBookingAuth()

        #expect(router.selectedTab == .home)
        #expect(router.homePath == [.passengerDetails(PassengerDetailsRoute())])
    }
}
