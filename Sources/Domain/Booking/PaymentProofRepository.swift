struct PaymentProofAttachment: Equatable, Sendable {
    let uriString, displayName: String; let mimeType: String?
}
enum PaymentProofUploadResult: Equatable, Sendable {
    case success, invalidDocument, authRequired, networkUnavailable, failed
}
protocol PaymentProofRepository: Sendable {
    func upload(bookingId: String, document: PaymentProofAttachment) async throws -> PaymentProofUploadResult
}
