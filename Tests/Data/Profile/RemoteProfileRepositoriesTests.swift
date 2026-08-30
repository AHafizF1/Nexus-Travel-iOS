import Foundation
import Testing
@testable import NexusTravel

struct RemoteProfileRepositoriesTests {
    @Test func deletionUsesExactContractAndDecodesRequestedState() async throws {
        let loader = ProfileLoader(responses: [Self.response(202, #"{"requestId":"delete-1","status":"REQUESTED"}"#)])
        let repository = RemoteAccountSecurityRepository(
            transport: HTTPTransport(loader: loader),
            tokenProvider: AuthTokenProvider(sessionStore: ProfileSessionStore())
        )

        let result = try await repository.deleteAccount(
            password: "correct horse battery staple",
            confirmation: "DELETE",
            idempotencyKey: "stable-delete-key"
        )

        #expect(result == .success(.init(requestId: "delete-1", status: .requested)))
        let request = try #require(await loader.requests.first)
        #expect(request.url?.path == "/api/v1/mobile/profile/delete")
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer secret")
        #expect(request.value(forHTTPHeaderField: "Idempotency-Key") == "stable-delete-key")
        let body = try #require(request.httpBody)
        let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: String])
        #expect(json == ["password": "correct horse battery staple", "confirmation": "DELETE"])
    }

    @Test func deletionRejectsUnexpectedCompletionClaim() async throws {
        let loader = ProfileLoader(responses: [Self.response(202, #"{"requestId":"delete-1","status":"COMPLETED"}"#)])
        let repository = RemoteAccountSecurityRepository(
            transport: HTTPTransport(loader: loader),
            tokenProvider: AuthTokenProvider(sessionStore: ProfileSessionStore())
        )

        #expect(try await repository.deleteAccount(password: "password", confirmation: "DELETE", idempotencyKey: "key") == .failed)
    }

    @Test func profileAndTravelersUseExactAuthenticatedRoutes() async throws {
        let loader = ProfileLoader(responses: [
            Self.response(200, #"{"user":{"id":"u1","name":"Ada Lovelace","email":"ada@example.com","image":null},"phone":"+251900000000","travelerSummary":{"total":1,"verified":1,"pending":0}}"#),
            Self.response(200, #"[{"id":"t1","firstName":"Ada","lastName":"Lovelace","nationality":"GB","passportNumber":"P1234567","passportExpiryDate":"2030-01-01","status":"VERIFIED","locked":true}]"#)
        ])
        let repository = RemoteProfileRepository(transport: HTTPTransport(loader: loader), tokenProvider: AuthTokenProvider(sessionStore: ProfileSessionStore()))
        guard case let .success(profile) = try await repository.profile() else { Issue.record("Expected profile"); return }
        guard case let .success(travelers) = try await repository.travelers() else { Issue.record("Expected travelers"); return }
        #expect(profile.verifiedTravelerCount == 1); #expect(travelers.first?.passportNumber == "•••• 4567")
        let requests = await loader.requests
        #expect(requests.map { $0.url?.path } == ["/api/v1/mobile/profile", "/api/v1/mobile/travelers"])
        #expect(requests.allSatisfy { $0.value(forHTTPHeaderField: "Authorization") == "Bearer secret" })
    }

    @Test func profileValidationMatchesBackendBoundaries() {
        #expect(ProfileValidation.validate(name: " A ", phone: nil) == .invalidName)
        #expect(ProfileValidation.validate(name: String(repeating: "A", count: 81), phone: nil) == .invalidName)
        #expect(ProfileValidation.validate(name: "Ada Lovelace", phone: "0900") == .invalidPhone)
        #expect(ProfileValidation.validate(name: " Ada Lovelace ", phone: "+251900000000") == .valid(name: "Ada Lovelace", phone: "+251900000000"))
    }

    private static func response(_ status: Int, _ body: String) -> (Data, URLResponse) { (Data(body.utf8), HTTPURLResponse(url: URL(string: "https://api.travelwithnexus.com")!, statusCode: status, httpVersion: nil, headerFields: nil)!) }
}
private actor ProfileLoader: HTTPDataLoading { private var responses: [(Data, URLResponse)]; private(set) var requests: [URLRequest] = []; init(responses: [(Data, URLResponse)]) { self.responses = responses }; func data(for request: URLRequest) async throws -> (Data, URLResponse) { requests.append(request); return responses.removeFirst() } }
private struct ProfileSessionStore: AuthSessionStore {
    func read() async throws -> StoredAuthSession? { .init(session: .init(sessionId: "s", user: .init(id: "u", displayName: "A", email: "a@b.com", avatarUrl: nil), tokens: .init(accessToken: "secret", refreshToken: nil), expiresAt: .distantFuture)) }
    func write(_ session: StoredAuthSession) async throws {}; func clear() async throws {}
}
