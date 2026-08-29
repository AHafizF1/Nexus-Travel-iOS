import SwiftUI

struct AppShell: View {
    @Bindable var router: Router
    let homeViewModel: HomeViewModel
    let searchResultsRepository: RemoteSearchResultsRepository

    var body: some View {
        TabView(
            selection: Binding(
                get: { router.selectedTab },
                set: { router.select($0) }
            )
        ) {
            NavigationStack(path: $router.homePath) {
                HomeRoute(viewModel: homeViewModel, router: router)
                    .appDestinations(router: router, searchResultsRepository: searchResultsRepository)
            }
            .tabItem { Label(MainTab.home.label, systemImage: MainTab.home.icon.systemName) }
            .tag(MainTab.home)

            NavigationStack(path: $router.explorePath) {
                AppTabRoot(tab: .explore)
                    .appDestinations(router: router, searchResultsRepository: searchResultsRepository)
            }
            .tabItem { Label(MainTab.explore.label, systemImage: MainTab.explore.icon.systemName) }
            .tag(MainTab.explore)

            NavigationStack(path: $router.tripsPath) {
                AppTabRoot(tab: .trips)
                    .appDestinations(router: router, searchResultsRepository: searchResultsRepository)
            }
            .tabItem { Label(MainTab.trips.label, systemImage: MainTab.trips.icon.systemName) }
            .tag(MainTab.trips)

            NavigationStack(path: $router.profilePath) {
                AppTabRoot(tab: .profile)
                    .appDestinations(router: router, searchResultsRepository: searchResultsRepository)
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
    let searchResultsRepository: RemoteSearchResultsRepository

    func body(content: Content) -> some View {
        content.navigationDestination(for: AppRoute.self) { route in
            switch route {
            case let .searchResults(payload):
                SearchResultsRoute(
                    viewModel: SearchResultsViewModel(searchId: payload.searchId, repository: searchResultsRepository),
                    router: router
                )
                .toolbar(.hidden, for: .tabBar)
            default:
                AppDestination(route: route)
            }
        }
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
    func appDestinations(router: Router, searchResultsRepository: RemoteSearchResultsRepository) -> some View {
        modifier(AppDestinations(router: router, searchResultsRepository: searchResultsRepository))
    }
}
