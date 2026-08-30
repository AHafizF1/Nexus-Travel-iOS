import Testing
@testable import NexusTravel

@MainActor
struct ExploreViewModelReliabilityTests {
    @Test func cancelledOlderLoadDoesNotOverwriteNewerContent() async throws {
        let repository = ControlledExploreRepository()
        let viewModel = ExploreViewModel(repository: repository)
        let first = Task { try await viewModel.load() }
        await repository.waitForCalls(1)
        let second = Task { try await viewModel.load(forceRefresh: true) }
        await repository.waitForCalls(2)

        let content = ExploreContent(banners: [], destinations: [], packages: [])
        await repository.complete(call: 1, with: .success(content))
        try await second.value
        await repository.cancel(call: 0)
        await #expect(throws: CancellationError.self) { try await first.value }

        #expect(viewModel.state.content == content)
        #expect(!viewModel.state.loading)
    }
}

private actor ControlledExploreRepository: ExploreRepository {
    private var calls = 0
    private var completions: [Int: CheckedContinuation<ExploreResult<ExploreContent>, Error>] = [:]
    private var waiters: [(Int, CheckedContinuation<Void, Never>)] = []

    func content(forceRefresh: Bool) async throws -> ExploreResult<ExploreContent> {
        let call = calls
        calls += 1
        resumeWaiters()
        return try await withCheckedThrowingContinuation { completions[call] = $0 }
    }

    func destination(id: String) async throws -> ExploreResult<ExploreDestinationDetail> { .failed }
    func travelPackage(id: String) async throws -> ExploreResult<ExplorePackageDetail> { .failed }

    func waitForCalls(_ count: Int) async {
        if calls >= count { return }
        await withCheckedContinuation { waiters.append((count, $0)) }
    }

    func complete(call: Int, with result: ExploreResult<ExploreContent>) {
        completions.removeValue(forKey: call)?.resume(returning: result)
    }

    func cancel(call: Int) {
        completions.removeValue(forKey: call)?.resume(throwing: CancellationError())
    }

    private func resumeWaiters() {
        let ready = waiters.filter { calls >= $0.0 }
        waiters.removeAll { calls >= $0.0 }
        ready.forEach { $0.1.resume() }
    }
}
