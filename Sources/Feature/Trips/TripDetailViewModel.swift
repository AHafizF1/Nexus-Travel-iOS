import Foundation
import Observation

struct TripDetailUiState: Equatable, Sendable {
    var loading = true; var refreshing = false; var downloadingTicket = false; var trip: CustomerTrip?
    var error: String?; var notice = ""; var primaryActionLabel: String?; var secondaryActionLabel: String?; var ticketToOpen: URL?
}
@MainActor @Observable final class TripDetailViewModel {
    private(set) var state = TripDetailUiState()
    private let bookingId: String; private let repository: any TripsRepository
    init(bookingId: String, repository: any TripsRepository) { self.bookingId = bookingId; self.repository = repository }
    func load(forceRefresh: Bool = false) async throws {
        let prior = state; state.loading = state.trip == nil; state.refreshing = state.trip != nil; state.error = nil
        do {
            switch try await repository.tripDetail(id: bookingId, forceRefresh: forceRefresh) {
            case let .success(trip): state = trip.uiState
            case .authRequired: fail("Sign in again to view this trip.")
            case .notFound: fail("Trip not found.")
            case .networkUnavailable: fail("Connection lost. Retry when you are online.")
            case .failed: fail("Could not load trip.")
            }
        } catch is CancellationError { state = prior; throw CancellationError() }
    }
    func downloadTicket() async throws {
        guard !state.downloadingTicket, state.trip?.ticketDocumentAvailable == true else { return }
        state.downloadingTicket = true; state.error = nil; state.ticketToOpen = nil
        do {
            switch try await repository.resolveTicketDocument(id: bookingId) {
            case let .success(url):
                switch try await repository.cacheTicketPdf(id: bookingId, downloadURL: url) {
                case let .success(file): state.downloadingTicket = false; state.ticketToOpen = file
                case .networkUnavailable: ticketError("Connection lost. Retry when you are online.")
                case .storageUnavailable: ticketError("Could not save ticket on this device.")
                case .unknownError: ticketError("We couldn’t load your e-ticket PDF.")
                }
            case .authRequired: ticketError("Sign in again to open this ticket.")
            case .networkUnavailable: ticketError("Connection lost. Retry when you are online.")
            case .unavailable: ticketError("Ticket document is not ready yet.")
            case .unknownError: ticketError("We couldn’t load your e-ticket PDF.")
            }
        } catch is CancellationError { state.downloadingTicket = false; throw CancellationError() }
    }
    func ticketOpened() { state.ticketToOpen = nil }
    private func fail(_ message: String) { state.loading = false; state.refreshing = false; state.error = message }
    private func ticketError(_ message: String) { state.downloadingTicket = false; state.error = message }
}
private extension CustomerTrip {
    var uiState: TripDetailUiState {
        let policy: (String, String?, String?)
        if status.uppercased() == "TICKETED", ticketDocumentAvailable { policy = ("Your ticket is ready.", "View ticket", "Download again") }
        else if status.uppercased() == "TICKETED" { policy = ("Ticket issued. Document is being prepared.", "Refresh", nil) }
        else if status.uppercased() == "TICKETING_DELAYED" || ["DELAYED", "OUTCOME_UNKNOWN"].contains(ticketingStatus.uppercased()) { policy = ("Payment received, but ticketing is delayed. Our agents are manually confirming your booking. Your funds are secure.", "Refresh", "Contact support") }
        else if status.uppercased() == "TICKETING_FAILED" || ticketingStatus.uppercased() == "FAILED" { policy = ("We could not issue this ticket automatically. Our team is reviewing it.", "Refresh", "Contact support") }
        else if status.uppercased() == "BOOKING_HELD", paymentProofStatus == "MISSING" { policy = ("Upload your payment receipt so our team can verify payment and issue your ticket.", "Upload payment receipt", nil) }
        else if paymentStatus == "FAILED" { policy = ("We couldn’t complete your payment.", "Contact support", nil) }
        else if status.uppercased() == "CANCELLED" { policy = ("This trip is cancelled.", ticketDocumentAvailable ? "View ticket" : nil, nil) }
        else { policy = ("Track your booking details here.", nil, nil) }
        return TripDetailUiState(loading: false, trip: self, notice: policy.0, primaryActionLabel: policy.1, secondaryActionLabel: policy.2)
    }
}
