import Foundation
import Testing
@testable import NexusTravel

struct RemotePaymentProofRepositoryTests {
    @Test func uploadUsesMobileHandshakeAndBearerFreeSignedPut() async throws {
        let loader = PaymentProofLoader(responses: [
            Self.response(201, #"{"uploadId":"up-1","status":"PENDING","uploadUrl":"https://signed.example/proof","requiredHeaders":{"Content-Type":"application/pdf","x-meta":"proof"}}"#),
            Self.response(200, ""), Self.response(201, #"{"id":"file-1"}"#)
        ])
        let repository = RemotePaymentProofRepository(
            transport: HTTPTransport(loader: loader), tokenProvider: AuthTokenProvider(sessionStore: PaymentProofSessionStore()),
            documentLoader: { _ in Data([1, 2, 3]) }
        )
        let result = try await repository.upload(
            bookingId: "b-1", document: .init(uriString: "file:///receipt.pdf", displayName: "receipt.pdf", mimeType: "application/pdf")
        )
        #expect(result == .success)
        let requests = await loader.requests
        #expect(requests.map { $0.url?.path } == ["/api/v1/mobile/bookings/b-1/payment-proof-upload", "/proof", "/api/v1/mobile/bookings/b-1/payment-proof-upload/up-1/complete"])
        #expect(requests[1].value(forHTTPHeaderField: "Authorization") == nil)
        #expect(requests[1].value(forHTTPHeaderField: "x-meta") == "proof")
    }
}

private actor PaymentProofLoader: HTTPDataLoading {
    private var responses: [(Data, URLResponse)]; private(set) var requests: [URLRequest] = []
    init(responses: [(Data, URLResponse)]) { self.responses = responses }
    func data(for request: URLRequest) async throws -> (Data, URLResponse) { requests.append(request); return responses.removeFirst() }
}
private struct PaymentProofSessionStore: AuthSessionStore {
    func read() async throws -> StoredAuthSession? {
        .init(session: .init(sessionId: "s", user: .init(id: "u", displayName: "A", email: "a@b.com", avatarUrl: nil),
                             tokens: .init(accessToken: "secret", refreshToken: nil), expiresAt: .distantFuture))
    }
    func write(_ session: StoredAuthSession) async throws {}
    func clear() async throws {}
}
private extension RemotePaymentProofRepositoryTests {
    static func response(_ status: Int, _ body: String) -> (Data, URLResponse) {
        (Data(body.utf8), HTTPURLResponse(url: URL(string: "https://api.travelwithnexus.com")!, statusCode: status,
                                        httpVersion: nil, headerFields: nil)!)
    }
}
