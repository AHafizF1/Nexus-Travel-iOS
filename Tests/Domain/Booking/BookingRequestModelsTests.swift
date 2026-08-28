import Testing
@testable import NexusTravel

struct BookingRequestModelsTests {
    @Test func statusLabelsMatchAndroid() {
        let labels: [BookingRequestStatus: String] = [
            .none: "", .draftSaved: "Request saved", .submittedForManualReview: "Manual review",
            .agentReviewing: "Agent reviewing", .confirmed: "Confirmed", .expired: "Expired",
            .unavailable: "Unavailable"
        ]
        for (status, label) in labels { #expect(status.label == label) }
    }

    @Test func snapshotHasRequestUnlessStatusIsNone() {
        #expect(!BookingRequestSnapshot(offerId: "offer", reviewId: nil, status: .none).hasRequest)
        #expect(BookingRequestSnapshot(offerId: "offer", reviewId: "review", status: .draftSaved).hasRequest)
    }
}
