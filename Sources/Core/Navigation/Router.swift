import Observation

enum MainTab: CaseIterable, Hashable, Sendable {
    case home
    case explore
    case trips
    case profile

    var label: String {
        switch self {
        case .home: "Home"
        case .explore: "Explore"
        case .trips: "Trips"
        case .profile: "Profile"
        }
    }

    var icon: NexusIconName {
        switch self {
        case .home: .home
        case .explore: .map
        case .trips: .baggage
        case .profile: .profile
        }
    }
}

@MainActor
@Observable
final class Router {
    private(set) var selectedTab: MainTab = .home
    var homePath: [AppRoute] = []
    var explorePath: [AppRoute] = []
    var tripsPath: [AppRoute] = []
    var profilePath: [AppRoute] = []
    private(set) var pendingTab: MainTab?

    func select(_ tab: MainTab) {
        if tab == selectedTab {
            popToRoot()
        } else {
            selectedTab = tab
        }
    }

    func push(_ route: AppRoute) {
        selectedPath.append(route)
    }

    func pop() {
        guard !selectedPath.isEmpty else { return }
        selectedPath.removeLast()
    }

    func popToRoot() {
        selectedPath.removeAll()
    }

    func beginMainAuth(returningTo tab: MainTab) {
        pendingTab = tab
        push(.mainAuth(MainAuthRoute()))
    }

    func completeMainAuth() {
        if selectedPath.last == .mainAuth(MainAuthRoute()) {
            pop()
        }
        selectedTab = pendingTab ?? .home
        pendingTab = nil
    }

    func completeBookingAuth() {
        if selectedPath.last == .bookingAuth(BookingAuthRoute()) {
            pop()
        }
    }

    private var selectedPath: [AppRoute] {
        get {
            switch selectedTab {
            case .home: homePath
            case .explore: explorePath
            case .trips: tripsPath
            case .profile: profilePath
            }
        }
        set {
            switch selectedTab {
            case .home: homePath = newValue
            case .explore: explorePath = newValue
            case .trips: tripsPath = newValue
            case .profile: profilePath = newValue
            }
        }
    }
}
