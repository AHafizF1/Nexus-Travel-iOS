import Testing
@testable import NexusTravel

struct NexusRoutesTests {
    @Test
    func routeInventoryPreservesPayloadEquality() {
        let reference = FlightOfferReference(
            searchId: "search-1", offerId: "offer-1", offerToken: "token-1", provider: .travelportGds,
            contentSource: "GDS", responseId: "response-1", productIds: ["product-1"],
            termsAndConditionsId: "terms-1", brandRef: "brand-1", expiresAt: nil
        )
        let routes: [AppRoute] = [
            .home(HomeRootRoute()),
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
            .flightDetails(FlightDetailsRoute(reference: reference)),
            .passengerDetails(PassengerDetailsRoute()),
            .bookingAuth(BookingAuthRoute()),
            .seatSelection(SeatSelectionRoute(bookingId: "booking-1")),
            .bookingReview(BookingReviewRoute(reviewId: "review-1")),
            .paymentProof(PaymentProofRoute(bookingId: "booking-1"))
        ]

        #expect(routes.count == 25)
        #expect(routes == routes)
        #expect(DestinationDetailRoute(destinationId: "1") != DestinationDetailRoute(destinationId: "2"))
        #expect(PackageDetailRoute(packageId: "1") != PackageDetailRoute(packageId: "2"))
        #expect(TripDetailRoute(tripId: "1") != TripDetailRoute(tripId: "2"))
        #expect(SearchResultsRoute(searchId: "search-1") != SearchResultsRoute(searchId: "search-2"))
        #expect(FlightDetailsRoute(reference: reference).reference == reference)
        #expect(SeatSelectionRoute(bookingId: "1") != SeatSelectionRoute(bookingId: "2"))
        #expect(BookingReviewRoute(reviewId: "1") != BookingReviewRoute(reviewId: "2"))
        #expect(PaymentProofRoute(bookingId: "1") != PaymentProofRoute(bookingId: "2"))
        #expect(DestinationDetailRoute(destinationId: "") == DestinationDetailRoute(destinationId: ""))
    }

    @Test
    func exploreFilterControlsVisibleContent() {
        #expect(ExploreFilter.all.showsPackages)
        #expect(ExploreFilter.all.showsDestinations)
        #expect(ExploreFilter.packages.showsPackages)
        #expect(!ExploreFilter.packages.showsDestinations)
        #expect(!ExploreFilter.destinations.showsPackages)
        #expect(ExploreFilter.destinations.showsDestinations)
    }

    @Test
    func exploreRouteDefaultsToAllContent() {
        #expect(ExploreRoute().filter == .all)
    }
}
