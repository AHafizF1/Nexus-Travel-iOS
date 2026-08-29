import Testing
@testable import NexusTravel

@MainActor
struct PaymentProofViewModelTests {
    @Test func successPublishesUploadedCopy() async throws {
        let repository = PaymentProofFakeRepository(result: .success)
        let viewModel = PaymentProofViewModel(bookingId: "b-1", repository: repository)
        viewModel.select(.init(uriString: "file:///proof.pdf", displayName: "proof.pdf", mimeType: "application/pdf"))
        try await viewModel.upload()
        #expect(viewModel.state.uploaded)
        #expect(viewModel.state.message == "Receipt uploaded.")
    }
}
private actor PaymentProofFakeRepository: PaymentProofRepository {
    let result: PaymentProofUploadResult
    init(result: PaymentProofUploadResult) { self.result = result }
    func upload(bookingId: String, document: PaymentProofAttachment) async throws -> PaymentProofUploadResult { result }
}
