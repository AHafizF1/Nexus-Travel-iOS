import Observation

struct ExploreUiState: Equatable, Sendable { var content: ExploreContent?; var loading = true; var refreshing = false; var error: String? }
@MainActor @Observable final class ExploreViewModel {
    private(set) var state = ExploreUiState(); private let repository: any ExploreRepository; private var generation = 0
    init(repository: any ExploreRepository) { self.repository = repository }
    func load(forceRefresh: Bool = false) async throws { generation += 1; let request = generation; let prior = state; state.loading = state.content == nil; state.refreshing = state.content != nil; state.error = nil; do { let result = try await repository.content(forceRefresh: forceRefresh); guard request == generation else { return }; switch result { case let .success(value): state = .init(content: value, loading: false); case .empty: state = .init(content: .init(banners: [], destinations: [], packages: []), loading: false); default: state.loading = false; state.refreshing = false; state.error = "Could not update Explore." } } catch is CancellationError { if request == generation { state = prior }; throw CancellationError() } }
}
enum ExploreDetailState: Equatable, Sendable { case loading; case destination(ExploreDestination, [ExplorePackage]); case package(ExplorePackage, ExploreDestination); case unavailable; case error }
@MainActor @Observable final class ExploreDetailViewModel {
    private(set) var state: ExploreDetailState = .loading; private let repository: any ExploreRepository
    init(repository: any ExploreRepository) { self.repository = repository }
    func loadDestination(id: String) async throws { let prior = state; do { switch try await repository.destination(id: id) { case let .success(value): state = .destination(value.destination, value.packages); case .unavailable: state = .unavailable; default: state = .error } } catch is CancellationError { state = prior; throw CancellationError() } }
    func loadPackage(id: String) async throws { let prior = state; do { switch try await repository.travelPackage(id: id) { case let .success(value): state = .package(value.package, value.destination); case .unavailable: state = .unavailable; default: state = .error } } catch is CancellationError { state = prior; throw CancellationError() } }
}
