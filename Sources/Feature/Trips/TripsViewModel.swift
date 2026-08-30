import Observation

enum TripsAccessState: Equatable, Sendable { case guest, loading, authenticated }
struct TripsUiState: Equatable, Sendable {
    var trips: [CustomerTrip] = []; var selectedGroup: TripGroup = .actionRequired
    var loading = true; var refreshing = false; var error: String?; var access: TripsAccessState = .loading
    var offline = false; var lastUpdated: Date?
    var visibleTrips: [CustomerTrip] { trips.filter { $0.group == selectedGroup } }
}
@MainActor @Observable final class TripsViewModel {
    private(set) var state = TripsUiState()
    private let repository: any TripsRepository; private let authRepository: any AuthRepository
    private var generation = 0
    init(repository: any TripsRepository, authRepository: any AuthRepository) { self.repository = repository; self.authRepository = authRepository }
    func select(_ group: TripGroup) async throws { guard state.selectedGroup != group else { return }; state.selectedGroup = group; try await load(forceRefresh: false) }
    func load(forceRefresh: Bool = false) async throws {
        generation += 1; let request = generation
        guard try await authRepository.getLocalSession() != nil else { state = TripsUiState(loading: false, access: .guest); return }
        let prior = state; state.loading = state.trips.isEmpty; state.refreshing = !state.trips.isEmpty; state.error = nil; state.access = .authenticated
        do {
            let group = state.selectedGroup; let result = try await repository.trips(group: group, forceRefresh: forceRefresh)
            guard request == generation, group == state.selectedGroup else { return }
            switch result {
            case .loading: break
            case let .content(page, offline, updated): state.trips = state.trips.filter { $0.group != group } + page.items; state.loading = false; state.refreshing = false; state.offline = offline; state.lastUpdated = updated
            case let .error(message, cached, updated): state.trips = cached?.items ?? state.trips; state.loading = false; state.refreshing = false; state.error = message; state.offline = cached != nil; state.lastUpdated = updated
            }
        } catch is CancellationError { state = prior; throw CancellationError() }
    }
}
