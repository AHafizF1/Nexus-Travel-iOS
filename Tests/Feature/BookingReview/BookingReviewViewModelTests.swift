import Testing
@testable import NexusTravel

@MainActor
struct BookingReviewViewModelTests {
    @Test func retryReusesOperationIdempotencyKey() async throws {
        let repository = BookingReviewFakeRepository(
            review: .success(Self.details), submits: [.outcomeUnknown, .success(reviewId: "b-1", bookingReference: "ABC123", status: .submittedForManualReview)]
        )
        let viewModel = BookingReviewViewModel(reviewId: "b-1", repository: repository, idempotencyKey: "stable-key")
        try await viewModel.load()
        try await viewModel.submit()
        try await viewModel.submit()

        #expect(await repository.keys == ["stable-key", "stable-key"])
        #expect(viewModel.state.screenState == .submitted)
    }

    @Test func invalidReferenceCannotBecomeSuccess() async throws {
        let repository = BookingReviewFakeRepository(review: .success(Self.details), submits: [.unavailable])
        let viewModel = BookingReviewViewModel(reviewId: "b-1", repository: repository, idempotencyKey: "stable")
        try await viewModel.load(); try await viewModel.submit()
        #expect(viewModel.state.screenState == .content)
        #expect(viewModel.state.message == "This fare is no longer available.")
    }

    private static let details = BookingReviewDetails(
        reviewId: "b-1", bookingReference: nil, status: .draftSaved,
        passengers: [.init(title: "MR", firstName: "Ada", lastName: "Lovelace", passportNumber: "P1", nationality: "GB")],
        contact: .init(email: "ada@example.com", phone: "+251900000000"), seats: [],
        fareTotal: .init(amount: 15_875, currency: "USD", formatted: "USD 158.75")
    )
}

private actor BookingReviewFakeRepository: BookingRequestRepository {
    let review: BookingRequestResult
    private var submits: [BookingSubmitResult]
    private(set) var keys: [String] = []
    init(review: BookingRequestResult, submits: [BookingSubmitResult]) { self.review = review; self.submits = submits }
    func getReview(reviewId: String) async throws -> BookingRequestResult { review }
    func submitReview(reviewId: String, idempotencyKey: String) async throws -> BookingSubmitResult {
        keys.append(idempotencyKey); return submits.removeFirst()
    }
}
