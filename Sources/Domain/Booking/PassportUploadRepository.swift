/// Completed passport upload accepted by backend.
struct CompletedPassportUpload: Equatable, Sendable {
    let uploadId: String
}

/// Result of signed passport upload workflow.
enum PassportUploadResult: Equatable, Sendable {
    case success(CompletedPassportUpload)
    case invalidDocument
    case authRequired
    case networkUnavailable
    case failed
}

/// Uploads one local passport document through backend signed-upload handshake.
protocol PassportUploadRepository: Sendable {
    func upload(document: PassengerDocumentAttachment, idempotencyKey: String) async throws -> PassportUploadResult
}
