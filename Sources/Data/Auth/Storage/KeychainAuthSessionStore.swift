import Foundation

/// Persists complete authentication sessions in one device-only Keychain item.
struct KeychainAuthSessionStore: AuthSessionStore {
    private static let service = "com.nexustravel.NexusTravel.auth"
    private static let account = "session"

    private let client: any KeychainClient

    /// Creates secure session storage using the native Keychain by default.
    init(client: any KeychainClient = SecurityKeychainClient()) {
        self.client = client
    }

    func read() async throws -> StoredAuthSession? {
        guard let data = try await client.read(service: Self.service, account: Self.account) else {
            return nil
        }
        do {
            return StoredAuthSession(session: try JSONDecoder().decode(Payload.self, from: data).session)
        } catch is DecodingError {
            try? await client.delete(service: Self.service, account: Self.account)
            return nil
        }
    }

    func write(_ session: StoredAuthSession) async throws {
        let data = try JSONEncoder().encode(Payload(session: session.session))
        try await client.write(
            data,
            service: Self.service,
            account: Self.account,
            accessibility: .afterFirstUnlockThisDeviceOnly,
            synchronizable: false
        )
    }

    func clear() async throws {
        try await client.delete(service: Self.service, account: Self.account)
    }
}

private struct Payload: Codable {
    let sessionId: String
    let user: UserPayload
    let tokens: TokenPayload?
    let expiresAt: Date

    init(session: AuthSession) {
        sessionId = session.sessionId
        user = UserPayload(user: session.user)
        tokens = session.tokens.map(TokenPayload.init)
        expiresAt = session.expiresAt
    }

    var session: AuthSession {
        AuthSession(
            sessionId: sessionId,
            user: user.user,
            tokens: tokens?.tokens,
            expiresAt: expiresAt
        )
    }
}

private struct UserPayload: Codable {
    let id: String
    let displayName: String
    let email: String
    let avatarUrl: String?

    init(user: AuthUser) {
        id = user.id
        displayName = user.displayName
        email = user.email
        avatarUrl = user.avatarUrl
    }

    var user: AuthUser {
        AuthUser(id: id, displayName: displayName, email: email, avatarUrl: avatarUrl)
    }
}

private struct TokenPayload: Codable {
    let accessToken: String
    let refreshToken: String?

    init(tokens: AuthTokenSet) {
        accessToken = tokens.accessToken
        refreshToken = tokens.refreshToken
    }

    var tokens: AuthTokenSet {
        AuthTokenSet(accessToken: accessToken, refreshToken: refreshToken)
    }
}
