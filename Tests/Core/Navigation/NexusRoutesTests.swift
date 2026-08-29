import Testing
@testable import NexusTravel

struct NexusRoutesTests {
    @Test
    func routeInventoryPreservesPayloadEquality() {
        let routes: [AppRoute] = [
            .home(HomeRoute()),
            .explore(ExploreRoute()),
            .destinationDetail(DestinationDetailRoute(destinationId: "destination-1")),
            .packageDetail(PackageDetailRoute(packageId: "package-1")),
            .trips(TripsRoute()),
            .tripDetail(TripDetailRoute(tripId: "trip-1")),
            .profile(ProfileRoute()),
            .editProfile(EditProfileRoute()),
            .savedTravelers(SavedTravelersRoute()),
            .settings(SettingsRoute()),
            .language(LanguageRoute()),
            .currency(CurrencyRoute()),
            .theme(ThemeRoute()),
            .homeAirport(HomeAirportRoute()),
            .notificationSettings(NotificationSettingsRoute()),
            .security(SecurityRoute()),
            .deleteAccount(DeleteAccountRoute()),
            .mainAuth(MainAuthRoute()),
            .searchResults(SearchResultsRoute(searchId: "search-1")),
            .flightDetails(FlightDetailsRoute()),
            .passengerDetails(PassengerDetailsRoute()),
            .bookingAuth(BookingAuthRoute()),
            .seatSelection(SeatSelectionRoute(bookingId: "booking-1")),
            .bookingReview(BookingReviewRoute(reviewId: "review-1")),
            .paymentProof(PaymentProofRoute(bookingId: "booking-1"))
        ]

        #expect(routes.count == 25)
        #expect(routes == routes)
        #expect(SearchResultsRoute(searchId: "search-1") != SearchResultsRoute(searchId: "search-2"))
        #expect(DestinationDetailRoute(destinationId: "") == DestinationDetailRoute(destinationId: ""))
    }

    @Test(arguments: [
        (ExploreFilter.all, true, true),
        (.packages, true, false),
        (.destinations, false, true)
    ])
    func exploreFilterControlsVisibleContent(
        filter: ExploreFilter,
        showsPackages: Bool,
        showsDestinations: Bool
    ) {
        #expect(filter.showsPackages == showsPackages)
        #expect(filter.showsDestinations == showsDestinations)
    }

    @Test
    func exploreRouteDefaultsToAllContent() {
        #expect(ExploreRoute().filter == .all)
    }
}
