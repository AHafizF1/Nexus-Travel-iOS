import Testing
@testable import NexusTravel

@MainActor
struct DeleteAccountViewModelTests {
    @Test func validationPreventsNetworkRequest() async throws {
        let repository = DeleteAccountRepositorySpy(results: [])
        let viewModel = DeleteAccountViewModel(repository: repository, clearSession: {}, idempotencyKey: "operation")

        await viewModel.submit(password: "", confirmation: "delete")

        #expect(viewModel.state == .failure("Enter your password and type DELETE exactly."))
        #expect(await repository.keys.isEmpty)
    }

    @Test func acceptedRequestBecomesPendingAndClearsSession() async throws {
        let repository = DeleteAccountRepositorySpy(results: [.success(.init(requestId: "request-1", status: .requested))])
        let session = SessionClearSpy()
        let viewModel = DeleteAccountViewModel(repository: repository, clearSession: { try await session.clear() }, idempotencyKey: "operation")

        await viewModel.submit(password: "password", confirmation: "DELETE")

        #expect(viewModel.state == .pending(requestId: "request-1"))
        #expect(await session.clearCount == 1)
    }

    @Test func retryReusesOperationKey() async throws {
        let repository = DeleteAccountRepositorySpy(results: [.networkUnavailable, .success(.init(requestId: "request-1", status: .requested))])
        let viewModel = DeleteAccountViewModel(repository: repository, clearSession: {}, idempotencyKey: "stable-key")

        await viewModel.submit(password: "password", confirmation: "DELETE")
        await viewModel.submit(password: "password", confirmation: "DELETE")

        #expect(await repository.keys == ["stable-key", "stable-key"])
        #expect(viewModel.state == .pending(requestId: "request-1"))
    }
}

private actor DeleteAccountRepositorySpy: AccountSecurityRepository {
    private var results: [ProfileResult<AccountDeletionRequest>]
    private(set) var keys: [String] = []
    init(results: [ProfileResult<AccountDeletionRequest>]) { self.results = results }
    func security() async throws -> ProfileResult<AccountSecurity> { .failed }
    func deleteAccount(password: String, confirmation: String, idempotencyKey: String) async throws -> ProfileResult<AccountDeletionRequest> {
        keys.append(idempotencyKey)
        return results.removeFirst()
    }
}

private actor SessionClearSpy {
    private(set) var clearCount = 0
    func clear() { clearCount += 1 }
}
