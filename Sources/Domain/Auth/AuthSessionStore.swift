/// Authentication session persisted between app launches.
struct StoredAuthSession: Equatable, Sendable {
    let session: AuthSession
}

/// Persistence boundary for the current authentication session.
protocol AuthSessionStore: Sendable {
    func read() async throws -> StoredAuthSession?
    func write(_ session: StoredAuthSession) async throws
    func clear() async throws
}
