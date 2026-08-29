import SwiftUI

struct AppShell: View {
    @Bindable var router: Router
    let homeViewModel: HomeViewModel
    let searchResultsRepository: any SearchResultsRepository
    let flightDetailsRepository: any FlightDetailsRepository
    let passengerDetailsRepository: any PassengerDetailsRepository
    let flightSeatsRepository: any FlightSeatsRepository
    let authRepository: any AuthRepository
    let bookingFlowState: BookingFlowState

    var body: some View {
        TabView(
            selection: Binding(
                get: { router.selectedTab },
                set: { router.select($0) }
            )
        ) {
            NavigationStack(path: $router.homePath) {
                HomeRoute(viewModel: homeViewModel, router: router)
                    .appDestinations(router: router, searchResultsRepository: searchResultsRepository, flightDetailsRepository: flightDetailsRepository, passengerDetailsRepository: passengerDetailsRepository, flightSeatsRepository: flightSeatsRepository, authRepository: authRepository, bookingFlowState: bookingFlowState)
            }
            .tabItem { Label(MainTab.home.label, systemImage: MainTab.home.icon.systemName) }
            .tag(MainTab.home)

            NavigationStack(path: $router.explorePath) {
                AppTabRoot(tab: .explore)
                    .appDestinations(router: router, searchResultsRepository: searchResultsRepository, flightDetailsRepository: flightDetailsRepository, passengerDetailsRepository: passengerDetailsRepository, flightSeatsRepository: flightSeatsRepository, authRepository: authRepository, bookingFlowState: bookingFlowState)
            }
            .tabItem { Label(MainTab.explore.label, systemImage: MainTab.explore.icon.systemName) }
            .tag(MainTab.explore)

            NavigationStack(path: $router.tripsPath) {
                AppTabRoot(tab: .trips)
                    .appDestinations(router: router, searchResultsRepository: searchResultsRepository, flightDetailsRepository: flightDetailsRepository, passengerDetailsRepository: passengerDetailsRepository, flightSeatsRepository: flightSeatsRepository, authRepository: authRepository, bookingFlowState: bookingFlowState)
            }
            .tabItem { Label(MainTab.trips.label, systemImage: MainTab.trips.icon.systemName) }
            .tag(MainTab.trips)

            NavigationStack(path: $router.profilePath) {
                AppTabRoot(tab: .profile)
                    .appDestinations(router: router, searchResultsRepository: searchResultsRepository, flightDetailsRepository: flightDetailsRepository, passengerDetailsRepository: passengerDetailsRepository, flightSeatsRepository: flightSeatsRepository, authRepository: authRepository, bookingFlowState: bookingFlowState)
            }
            .tabItem { Label(MainTab.profile.label, systemImage: MainTab.profile.icon.systemName) }
            .tag(MainTab.profile)
        }
    }
}

private struct AppTabRoot: View {
    let tab: MainTab

    var body: some View {
        ContentUnavailableView(
            tab.label,
            systemImage: tab.icon.systemName,
            description: Text("Content is unavailable.")
        )
        .navigationTitle(tab.label)
    }
}

private struct AppDestinations: ViewModifier {
    let router: Router
    let searchResultsRepository: any SearchResultsRepository
    let flightDetailsRepository: any FlightDetailsRepository
    let passengerDetailsRepository: any PassengerDetailsRepository
    let flightSeatsRepository: any FlightSeatsRepository
    let authRepository: any AuthRepository
    let bookingFlowState: BookingFlowState

    func body(content: Content) -> some View {
        content.navigationDestination(for: AppRoute.self) { route in
            switch route {
            case let .searchResults(payload):
                SearchResultsScreenRoute(
                    viewModel: SearchResultsViewModel(searchId: payload.searchId, repository: searchResultsRepository),
                    router: router
                )
                .toolbar(.hidden, for: .tabBar)
            case let .flightDetails(payload):
                FlightDetailsScreenRoute(
                    viewModel: FlightDetailsViewModel(
                        reference: payload.reference,
                        repository: flightDetailsRepository
                    ),
                    router: router,
                    bookingFlowState: bookingFlowState,
                    reference: payload.reference
                )
                .toolbar(.hidden, for: .tabBar)
            case .mainAuth:
                AuthRoute(
                    viewModel: AuthViewModel(repository: authRepository),
                    onAuthenticated: {
                        _ = bookingFlowState.completeAuthentication()
                        router.completeMainAuth()
                    }
                )
            case .bookingAuth:
                AuthRoute(
                    viewModel: AuthViewModel(repository: authRepository),
                    onAuthenticated: {
                        _ = bookingFlowState.completeAuthentication()
                        router.completeBookingAuth()
                    }
                )
            case .passengerDetails:
                if let details = bookingFlowState.passengerDetails {
                    PassengerDetailsScreenRoute(
                        viewModel: PassengerDetailsViewModel(
                            details: details, repository: passengerDetailsRepository,
                            today: Self.currentLocalDate
                        ), router: router, bookingFlowState: bookingFlowState
                    )
                    .toolbar(.hidden, for: .tabBar)
                } else {
                    ContentUnavailableView("Passenger details unavailable", systemImage: "person.crop.circle.badge.exclamationmark")
                }
            case let .seatSelection(route):
                SeatSelectionScreenRoute(
                    viewModel: SeatSelectionViewModel(
                        bookingId: route.bookingId,
                        passengerCount: bookingFlowState.passengerDetails?.travelers.total ?? 1,
                        repository: flightSeatsRepository
                    ), router: router
                )
                .toolbar(.hidden, for: .tabBar)
            default:
                AppDestination(route: route)
            }
        }
    }

    private static func currentLocalDate() -> LocalDate {
        let values = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: Date())
        guard let year = values.year, let month = values.month, let day = values.day,
              let date = LocalDate(year: year, month: month, day: day) else {
            preconditionFailure("Current Gregorian date must be representable.")
        }
        return date
    }
}

private struct AppDestination: View {
    let route: AppRoute

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: NexusIconName.flight.systemName,
            description: Text("Content is unavailable.")
        )
        .navigationTitle(title)
        .toolbar(.hidden, for: .tabBar)
    }

    private var title: String {
        switch route {
        case .home: "Home"
        case .explore: "Explore"
        case .destinationDetail: "Destination"
        case .packageDetail: "Package"
        case .trips: "Trips"
        case .tripDetail: "Trip"
        case .profile: "Profile"
        case .editProfile: "Edit Profile"
        case .savedTravelers: "Saved Travelers"
        case .settings: "Settings"
        case .language: "Language"
        case .currency: "Currency"
        case .theme: "Theme"
        case .homeAirport: "Home Airport"
        case .notificationSettings: "Notifications"
        case .security: "Security"
        case .deleteAccount: "Delete Account"
        case .mainAuth, .bookingAuth: "Sign In"
        case .searchResults: "Search Results"
        case .flightDetails: "Flight Details"
        case .passengerDetails: "Passenger Details"
        case .seatSelection: "Seat Selection"
        case .bookingReview: "Booking Review"
        case .paymentProof: "Payment Proof"
        }
    }
}

private extension View {
    func appDestinations(
        router: Router,
        searchResultsRepository: any SearchResultsRepository,
        flightDetailsRepository: any FlightDetailsRepository,
        passengerDetailsRepository: any PassengerDetailsRepository,
        flightSeatsRepository: any FlightSeatsRepository,
        authRepository: any AuthRepository,
        bookingFlowState: BookingFlowState
    ) -> some View {
        modifier(AppDestinations(
            router: router,
            searchResultsRepository: searchResultsRepository,
            flightDetailsRepository: flightDetailsRepository,
            passengerDetailsRepository: passengerDetailsRepository,
            flightSeatsRepository: flightSeatsRepository,
            authRepository: authRepository,
            bookingFlowState: bookingFlowState
        ))
    }
}

