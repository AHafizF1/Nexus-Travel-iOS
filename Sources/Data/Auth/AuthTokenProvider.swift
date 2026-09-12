import Foundation

/// Supplies the access token currently stored for authenticated requests.
struct AuthTokenProvider: Sendable {
    private let sessionStore: any AuthSessionStore
    private let clock: @Sendable () -> Date

    /// Creates a token provider backed by session storage.
    init(
        sessionStore: any AuthSessionStore,
        clock: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.sessionStore = sessionStore
        self.clock = clock
    }

    /// Returns the current optional access token without refresh behavior.
    func accessToken() async throws -> String? {
        guard let stored = try await sessionStore.read() else { return nil }
        guard stored.session.expiresAt > clock() else {
            try await sessionStore.clear()
            return nil
        }
        return stored.session.tokens?.accessToken
    }
}
