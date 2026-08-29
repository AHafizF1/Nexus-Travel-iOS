import Foundation
import Observation

enum BookingReviewState: Equatable, Sendable { case loading, content, error, submitted }
struct BookingReviewUiState: Equatable, Sendable {
    var screenState: BookingReviewState = .loading; var details: BookingReviewDetails?
    var message: String?; var isSubmitting = false
}
enum BookingReviewNavigation: Equatable, Sendable { case back, home, payment(String), trip(String) }

@MainActor @Observable
final class BookingReviewViewModel {
    private(set) var state = BookingReviewUiState()
    private let reviewId: String; private let repository: any BookingRequestRepository
    private let idempotencyKey: String; private var navigation: [BookingReviewNavigation] = []
    init(reviewId: String, repository: any BookingRequestRepository,
         idempotencyKey: String = "ios-\(UUID().uuidString)") {
        self.reviewId = reviewId; self.repository = repository; self.idempotencyKey = idempotencyKey
    }
    func load() async throws {
        let previous = state
        state.screenState = .loading; state.message = nil
        do {
            switch try await repository.getReview(reviewId: reviewId) {
            case let .success(details): state.screenState = .content; state.details = details
            case .expired: showError("This fare expired. Choose another flight.")
            case .networkUnavailable: showError("Connection lost. Check your internet and retry.")
            case .notFound: showError("Booking request was not found.")
            case .unavailable: showError("This fare is no longer available.")
            case .unknownError: showError("Could not load booking review. Please retry.")
            }
        } catch is CancellationError {
            state = previous
            throw CancellationError()
        }
    }
    func submit() async throws {
        guard !state.isSubmitting else { return }
        state.isSubmitting = true; state.message = nil
        do { switch try await repository.submitReview(reviewId: reviewId, idempotencyKey: idempotencyKey) {
        case let .success(_, reference, status):
            guard let details = state.details else { showError("Booking request was not found."); return }
            state.details = .init(reviewId: details.reviewId, bookingReference: reference, status: status,
                                  passengers: details.passengers, contact: details.contact, seats: details.seats,
                                  fareTotal: details.fareTotal)
            state.screenState = .submitted; state.isSubmitting = false
        case .expired: showSubmitError("This fare expired. Choose another flight.")
        case let .fareUnavailable(message): showSubmitError(message)
        case .networkUnavailable: showSubmitError("Connection lost. Check your internet and retry.")
        case .outcomeUnknown: showSubmitError("We could not confirm whether the airline secured this booking. Your details are saved. Retry status or contact support.")
        case .notFound: showSubmitError("Booking request was not found.")
        case .unavailable: showSubmitError("This fare is no longer available.")
        case .unknownError: showSubmitError("Could not book flight. Please retry.")
        } } catch is CancellationError { state.isSubmitting = false; throw CancellationError() }
    }
    func back() { navigation.append(.back) }
    func home() { navigation.append(.home) }
    func payment() { if let id = state.details?.reviewId { navigation.append(.payment(id)) } }
    func trip() { if let id = state.details?.reviewId { navigation.append(.trip(id)) } }
    func consumeNavigation() -> BookingReviewNavigation? { navigation.isEmpty ? nil : navigation.removeFirst() }
    private func showError(_ message: String) { state.screenState = .error; state.isSubmitting = false; state.message = message }
    private func showSubmitError(_ message: String) { state.isSubmitting = false; state.message = message }
}
