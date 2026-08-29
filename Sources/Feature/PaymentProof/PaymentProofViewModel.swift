import Observation

struct PaymentProofUiState: Equatable, Sendable {
    var selected: PaymentProofAttachment?; var uploading = false; var uploaded = false; var message: String?
}
@MainActor @Observable
final class PaymentProofViewModel {
    private(set) var state = PaymentProofUiState()
    private let bookingId: String; private let repository: any PaymentProofRepository
    init(bookingId: String, repository: any PaymentProofRepository) { self.bookingId = bookingId; self.repository = repository }
    func select(_ attachment: PaymentProofAttachment) {
        state.selected = attachment; state.uploaded = false; state.message = nil
    }
    func upload() async throws {
        guard !state.uploading, let document = state.selected else { return }
        state.uploading = true; state.message = nil
        do {
            let result = try await repository.upload(bookingId: bookingId, document: document)
            state.uploading = false
            switch result {
            case .success: state.uploaded = true; state.message = "Receipt uploaded."
            case .invalidDocument: state.message = "Use PDF, JPG, or PNG up to 10 MB."
            case .authRequired: state.message = "Sign in again to upload payment receipt."
            case .networkUnavailable: state.message = "Connection lost. Retry upload."
            case .failed: state.message = "Could not upload receipt. Retry."
            }
        } catch is CancellationError { state.uploading = false; throw CancellationError() }
    }
}
