/// Supplies the access token currently stored for authenticated requests.
struct AuthTokenProvider: Sendable {
    private let sessionStore: any AuthSessionStore

    /// Creates a token provider backed by session storage.
    init(sessionStore: any AuthSessionStore) {
        self.sessionStore = sessionStore
    }

    /// Returns the current optional access token without refresh behavior.
    func accessToken() async throws -> String? {
        try await sessionStore.read()?.session.tokens?.accessToken
    }
}
