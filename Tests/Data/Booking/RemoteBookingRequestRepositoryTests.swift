import Foundation
import Testing
@testable import NexusTravel

struct RemoteBookingRequestRepositoryTests {
    @Test func holdSendsStableKeyAndAcceptsConfirmedSupplierReference() async throws {
        let loader = BookingRequestLoader(responses: [Self.response(201, Self.heldJSON)])
        let result = try await Self.repository(loader).submitReview(reviewId: "b-1", idempotencyKey: "stable-key")
        #expect(result == .success(reviewId: "b-1", bookingReference: "ABC123", status: .submittedForManualReview))
        let requests = await loader.requests
        #expect(requests[0].url?.path == "/api/v1/mobile/bookings/b-1/hold")
        #expect(requests[0].value(forHTTPHeaderField: "Idempotency-Key") == "stable-key")
    }

    @Test(arguments: ["UNKNOWN", "FAKE123", "LOCAL-1"])
    func placeholderSupplierReferenceIsUnavailable(_ reference: String) async throws {
        let body = Self.heldJSON.replacingOccurrences(of: "ABC123", with: reference)
        let result = try await Self.repository(BookingRequestLoader(responses: [Self.response(201, body)]))
            .submitReview(reviewId: "b-1", idempotencyKey: "stable")
        #expect(result == .unavailable)
    }

    @Test func unconfirmedHoldIsOutcomeUnknown() async throws {
        let body = Self.heldJSON.replacingOccurrences(of: "BOOKING_HELD", with: "HOLD_UNCONFIRMED")
        let result = try await Self.repository(BookingRequestLoader(responses: [Self.response(201, body)]))
            .submitReview(reviewId: "b-1", idempotencyKey: "stable")
        #expect(result == .outcomeUnknown)
    }

    private static func repository(_ loader: BookingRequestLoader) -> RemoteBookingRequestRepository {
        .init(transport: HTTPTransport(loader: loader), tokenProvider: AuthTokenProvider(sessionStore: BookingRequestSessionStore()))
    }
    private static func response(_ status: Int, _ body: String) -> (Data, URLResponse) {
        (Data(body.utf8), HTTPURLResponse(url: URL(string: "https://api.travelwithnexus.com")!, statusCode: status,
                                        httpVersion: nil, headerFields: nil)!)
    }
    private static let heldJSON = #"{"amountMinor":15875,"currency":"USD","id":"b-1","status":"BOOKING_HELD","travelportLocator":"ABC123","failureReason":null,"failureReasonCode":null,"passengerDetailsSnapshot":{"passengers":[]},"contactSnapshot":{"email":"a@b.com","phone":"+2519"},"seatSelectionSnapshot":null}"#
}

private actor BookingRequestLoader: HTTPDataLoading {
    private var responses: [(Data, URLResponse)]; private(set) var requests: [URLRequest] = []
    init(responses: [(Data, URLResponse)]) { self.responses = responses }
    func data(for request: URLRequest) async throws -> (Data, URLResponse) { requests.append(request); return responses.removeFirst() }
}
private struct BookingRequestSessionStore: AuthSessionStore {
    func read() async throws -> StoredAuthSession? {
        .init(session: .init(sessionId: "s", user: .init(id: "u", displayName: "A", email: "a@b.com", avatarUrl: nil),
                             tokens: .init(accessToken: "secret", refreshToken: nil), expiresAt: .distantFuture))
    }
    func write(_ session: StoredAuthSession) async throws {}
    func clear() async throws {}
}
