import Foundation
import Testing
@testable import NexusTravel

@MainActor struct TripDetailViewModelTests {
    @Test func ticketedTripExposesTicketActions() async throws {
        let repository = TripsFakeRepository(detail: .success(Self.trip))
        let viewModel = TripDetailViewModel(bookingId: "b-1", repository: repository)
        try await viewModel.load()
        #expect(viewModel.state.notice == "Your ticket is ready.")
        #expect(viewModel.state.primaryActionLabel == "View ticket")
        #expect(viewModel.state.secondaryActionLabel == "Download again")
    }
    static let trip = CustomerTrip(id: "b-1", group: .upcoming, status: "TICKETED", paymentStatus: "PAID", paymentProofStatus: "VERIFIED", ticketingStatus: "TICKETED", amountMinor: 100, currency: "USD", holdExpiresAt: nil, ticketDocumentAvailable: true, nextAction: "DOWNLOAD_TICKET", createdAt: "2026-08-30", itineraryLabel: "ADD to DXB")
}

private actor TripsFakeRepository: TripsRepository {
    let detail: TripDetailResult
    init(detail: TripDetailResult) { self.detail = detail }
    func trips(group: TripGroup, forceRefresh: Bool) async throws -> TripPageState { .loading }
    func tripDetail(id: String, forceRefresh: Bool) async throws -> TripDetailResult { detail }
    func resolveTicketDocument(id: String) async throws -> TicketDocumentResult { .unavailable }
    func cacheTicketPdf(id: String, downloadURL: URL) async throws -> CachedTicketResult { .unknownError }
}
