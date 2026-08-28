import Foundation
import Security
import Testing
@testable import NexusTravel

struct KeychainAuthSessionStoreTests {
    @Test func missingItemReturnsNil() async throws {
        let client = FakeKeychainClient()
        let store = KeychainAuthSessionStore(client: client)

        #expect(try await store.read() == nil)
    }

    @Test func roundTripsCompleteSessionAndUsesRequiredItemContract() async throws {
        let client = FakeKeychainClient()
        let store = KeychainAuthSessionStore(client: client)
        let expected = StoredAuthSession(session: richSession)

        try await store.write(expected)

        #expect(try await store.read() == expected)
        let write = try #require(await client.lastWrite)
        #expect(write.service == "com.nexustravel.NexusTravel.auth")
        #expect(write.account == "session")
        #expect(write.accessibility == .afterFirstUnlockThisDeviceOnly)
        #expect(write.synchronizable == false)
        #expect(!write.data.isEmpty)
    }

    @Test func roundTripsNilAvatarTokensAndRefreshToken() async throws {
        let client = FakeKeychainClient()
        let store = KeychainAuthSessionStore(client: client)
        let noTokens = StoredAuthSession(session: session(avatarURL: nil, tokens: nil))
        try await store.write(noTokens)
        #expect(try await store.read() == noTokens)

        let noRefresh = StoredAuthSession(
            session: session(avatarURL: nil, tokens: AuthTokenSet(accessToken: "access", refreshToken: nil))
        )
        try await store.write(noRefresh)
        #expect(try await store.read() == noRefresh)
    }

    @Test func laterWriteOverwritesExistingSession() async throws {
        let client = FakeKeychainClient()
        let store = KeychainAuthSessionStore(client: client)
        try await store.write(StoredAuthSession(session: richSession))
        let replacement = StoredAuthSession(session: session(id: "replacement", tokens: nil))

        try await store.write(replacement)

        #expect(try await store.read() == replacement)
    }

    @Test func clearRemovesItemAndMissingClearSucceeds() async throws {
        let client = FakeKeychainClient()
        let store = KeychainAuthSessionStore(client: client)
        try await store.write(StoredAuthSession(session: richSession))

        try await store.clear()
        try await store.clear()

        #expect(try await store.read() == nil)
    }

    @Test func corruptPayloadSelfClearsWithoutSurfacingDeleteFailure() async throws {
        let client = FakeKeychainClient(data: Data("not-json".utf8))
        await client.setDeleteError(.init(status: errSecInteractionNotAllowed))
        let store = KeychainAuthSessionStore(client: client)

        #expect(try await store.read() == nil)
        #expect(await client.deleteCount == 1)
    }

    @Test func clientReadWriteAndExplicitDeleteFailuresPropagate() async {
        let expected = KeychainError(status: errSecInteractionNotAllowed)

        let readClient = FakeKeychainClient()
        await readClient.setReadError(expected)
        await #expect(throws: expected) {
            try await KeychainAuthSessionStore(client: readClient).read()
        }

        let writeClient = FakeKeychainClient()
        await writeClient.setWriteError(expected)
        await #expect(throws: expected) {
            try await KeychainAuthSessionStore(client: writeClient)
                .write(StoredAuthSession(session: richSession))
        }

        let deleteClient = FakeKeychainClient()
        await deleteClient.setDeleteError(expected)
        await #expect(throws: expected) {
            try await KeychainAuthSessionStore(client: deleteClient).clear()
        }
    }

    @Test func tokenProviderReturnsOnlyCurrentAccessToken() async throws {
        let client = FakeKeychainClient()
        let store = KeychainAuthSessionStore(client: client)
        let provider = AuthTokenProvider(sessionStore: store)
        #expect(try await provider.accessToken() == nil)

        try await store.write(StoredAuthSession(session: richSession))

        #expect(try await provider.accessToken() == "access-token")
    }

    private var richSession: AuthSession {
        session(
            avatarURL: "https://example.com/avatar.png",
            tokens: AuthTokenSet(accessToken: "access-token", refreshToken: "refresh-token")
        )
    }

    private func session(
        id: String = "session-id",
        avatarURL: String? = "https://example.com/avatar.png",
        tokens: AuthTokenSet? = AuthTokenSet(accessToken: "access-token", refreshToken: "refresh-token")
    ) -> AuthSession {
        AuthSession(
            sessionId: id,
            user: AuthUser(id: "user-id", displayName: "Afi Z", email: "afi@example.com", avatarUrl: avatarURL),
            tokens: tokens,
            expiresAt: Date(timeIntervalSince1970: 2_000_000_000)
        )
    }
}

struct SecurityKeychainClientTests {
    @Test func nativeQueriesUseGenericPasswordWithoutSynchronization() {
        let data = Data([1, 2, 3])
        let read = SecurityKeychainClient.readQuery(service: "service", account: "account")
        let write = SecurityKeychainClient.writeQuery(
            data: data,
            service: "service",
            account: "account",
            accessibility: .afterFirstUnlockThisDeviceOnly,
            synchronizable: false
        )
        let delete = SecurityKeychainClient.deleteQuery(service: "service", account: "account")

        #expect(read[kSecClass] as? String == kSecClassGenericPassword as String)
        #expect(read[kSecAttrService] as? String == "service")
        #expect(read[kSecAttrAccount] as? String == "account")
        #expect(read[kSecReturnData] as? Bool == true)
        #expect(read[kSecAttrSynchronizable] as? Bool == false)

        #expect(write[kSecClass] as? String == kSecClassGenericPassword as String)
        #expect(write[kSecAttrService] as? String == "service")
        #expect(write[kSecAttrAccount] as? String == "account")
        #expect(write[kSecAttrAccessible] as? String == kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String)
        #expect(write[kSecAttrSynchronizable] as? Bool == false)
        #expect(write[kSecValueData] as? Data == data)

        #expect(delete[kSecClass] as? String == kSecClassGenericPassword as String)
        #expect(delete[kSecAttrService] as? String == "service")
        #expect(delete[kSecAttrAccount] as? String == "account")
        #expect(delete[kSecAttrSynchronizable] as? Bool == false)
    }
}

private actor FakeKeychainClient: KeychainClient {
    struct Write: Sendable {
        let data: Data
        let service: String
        let account: String
        let accessibility: KeychainAccessibility
        let synchronizable: Bool
    }

    private var data: Data?
    private var readError: KeychainError?
    private var writeError: KeychainError?
    private var deleteError: KeychainError?
    private(set) var lastWrite: Write?
    private(set) var deleteCount = 0

    init(data: Data? = nil) {
        self.data = data
    }

    func setReadError(_ error: KeychainError) { readError = error }
    func setWriteError(_ error: KeychainError) { writeError = error }
    func setDeleteError(_ error: KeychainError) { deleteError = error }

    func read(service: String, account: String) async throws -> Data? {
        if let readError { throw readError }
        return data
    }

    func write(
        _ data: Data,
        service: String,
        account: String,
        accessibility: KeychainAccessibility,
        synchronizable: Bool
    ) async throws {
        if let writeError { throw writeError }
        lastWrite = Write(
            data: data,
            service: service,
            account: account,
            accessibility: accessibility,
            synchronizable: synchronizable
        )
        self.data = data
    }

    func delete(service: String, account: String) async throws {
        deleteCount += 1
        if let deleteError { throw deleteError }
        data = nil
    }
}
