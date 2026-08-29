import Foundation
import Testing
@testable import NexusTravel

struct RemotePassportUploadRepositoryTests {
    @Test func signedUploadOmitsBearerAndReplaysRequiredHeaders() async throws {
        let loader = PassportUploadRecordingLoader(responses: [
            Self.response(201, #"{"uploadId":"up-1","status":"PENDING","uploadUrl":"https://signed.example/upload","requiredHeaders":{"x-amz-meta-kind":"passport","Content-Type":"image/png"}}"#),
            Self.response(200, ""),
            Self.response(200, #"{"uploadId":"up-1","status":"COMPLETED"}"#)
        ])
        let repository = RemotePassportUploadRepository(
            transport: HTTPTransport(loader: loader), tokenProvider: AuthTokenProvider(sessionStore: PassportSessionStore()),
            documentLoader: { _ in Data([1, 2, 3]) }
        )

        let result = try await repository.upload(
            document: PassengerDocumentAttachment(uriString: "file:///passport.png", displayName: "passport.png", mimeType: "image/png"),
            idempotencyKey: "operation:passport:0"
        )

        #expect(result == .success(CompletedPassportUpload(uploadId: "up-1")))
        let requests = await loader.requests
        #expect(requests.count == 3)
        #expect(requests[0].value(forHTTPHeaderField: "Idempotency-Key") == "operation:passport:0")
        #expect(requests[1].value(forHTTPHeaderField: "Authorization") == nil)
        #expect(requests[1].value(forHTTPHeaderField: "x-amz-meta-kind") == "passport")
        #expect(requests[1].value(forHTTPHeaderField: "Content-Type") == "image/png")
    }

    @Test func rejectsUnsupportedDocumentBeforeNetwork() async throws {
        let loader = PassportUploadRecordingLoader(responses: [])
        let repository = RemotePassportUploadRepository(
            transport: HTTPTransport(loader: loader), tokenProvider: AuthTokenProvider(sessionStore: PassportSessionStore()),
            documentLoader: { _ in Data([1]) }
        )
        let result = try await repository.upload(
            document: PassengerDocumentAttachment(uriString: "file:///a.txt", displayName: "a.txt", mimeType: "text/plain"),
            idempotencyKey: "stable"
        )
        #expect(result == .invalidDocument)
        let requests = await loader.requests
        #expect(requests.isEmpty)
    }

    private static func response(_ status: Int, _ body: String) -> (Data, URLResponse) {
        (Data(body.utf8), HTTPURLResponse(url: URL(string: "https://api.travelwithnexus.com")!, statusCode: status,
                                        httpVersion: nil, headerFields: nil)!)
    }
}

private actor PassportUploadRecordingLoader: HTTPDataLoading {
    private var responses: [(Data, URLResponse)]
    private(set) var requests: [URLRequest] = []
    init(responses: [(Data, URLResponse)]) { self.responses = responses }
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        return responses.removeFirst()
    }
}

private struct PassportSessionStore: AuthSessionStore {
    func read() async throws -> StoredAuthSession? {
        StoredAuthSession(session: AuthSession(
            sessionId: "s", user: AuthUser(id: "u", displayName: "A", email: "a@b.com", avatarUrl: nil),
            tokens: AuthTokenSet(accessToken: "secret", refreshToken: nil), expiresAt: .distantFuture
        ))
    }
    func write(_ session: StoredAuthSession) async throws {}
    func clear() async throws {}
}
