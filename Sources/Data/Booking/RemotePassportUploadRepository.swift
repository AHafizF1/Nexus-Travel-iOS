import Foundation

/// Backend signed-upload adapter for passport documents.
struct RemotePassportUploadRepository: PassportUploadRepository {
    typealias DocumentLoader = @Sendable (URL) throws -> Data

    private let transport: HTTPTransport
    private let tokenProvider: AuthTokenProvider
    private let documentLoader: DocumentLoader

    /// Creates adapter with injectable local document loading.
    init(transport: HTTPTransport, tokenProvider: AuthTokenProvider,
         documentLoader: @escaping DocumentLoader = { try Data(contentsOf: $0, options: .mappedIfSafe) }) {
        self.transport = transport
        self.tokenProvider = tokenProvider
        self.documentLoader = documentLoader
    }

    func upload(document: PassengerDocumentAttachment, idempotencyKey: String) async throws -> PassportUploadResult {
        guard let contentType = document.mimeType?.split(separator: ";").first.map(String.init)?.lowercased(),
              Self.allowedTypes.contains(contentType),
              let url = URL(string: document.uriString), url.isFileURL else {
            return .invalidDocument
        }
        let accessed = url.startAccessingSecurityScopedResource()
        defer { if accessed { url.stopAccessingSecurityScopedResource() } }
        guard let bytes = try? documentLoader(url), !bytes.isEmpty, bytes.count <= Self.maximumBytes else {
            return .invalidDocument
        }
        do {
            guard let token = try await tokenProvider.accessToken() else { return .authRequired }
            let createBody = try JSONEncoder().encode(CreateUploadRequest(
                fileName: document.displayName, contentType: contentType, sizeBytes: bytes.count
            ))
            let createdResponse = try await transport.send(HTTPRequest(
                target: .mobile("uploads/passport"), method: .post,
                headers: ["Idempotency-Key": idempotencyKey], body: createBody, authorization: .bearer(token)
            ))
            guard createdResponse.statusCode != 401 else { return .authRequired }
            guard (200..<300).contains(createdResponse.statusCode),
                  let created = try? JSONDecoder().decode(UploadResponse.self, from: createdResponse.data) else {
                return .failed
            }
            if created.status == "PENDING" {
                guard let value = created.uploadUrl, let uploadURL = URL(string: value) else { return .failed }
                let putResponse = try await transport.send(HTTPRequest(
                    target: .absolute(uploadURL), method: .put, headers: created.requiredHeaders,
                    body: bytes, authorization: .none
                ))
                guard (200..<300).contains(putResponse.statusCode) else { return .failed }
            }
            let completedResponse = try await transport.send(HTTPRequest(
                target: .mobile("uploads/passport/\(created.uploadId)/complete"), method: .post,
                authorization: .bearer(token)
            ))
            guard completedResponse.statusCode != 401 else { return .authRequired }
            guard (200..<300).contains(completedResponse.statusCode),
                  let completed = try? JSONDecoder().decode(CompletedUploadResponse.self, from: completedResponse.data),
                  ["COMPLETED", "CONSUMED"].contains(completed.status) else { return .failed }
            return .success(CompletedPassportUpload(uploadId: completed.uploadId))
        } catch is CancellationError {
            throw CancellationError()
        } catch HTTPTransportError.networkUnavailable, HTTPTransportError.timedOut {
            return .networkUnavailable
        } catch {
            return .failed
        }
    }

    private static let maximumBytes = 10_000_000
    private static let allowedTypes = Set(["application/pdf", "image/jpeg", "image/png"])
}

private struct CreateUploadRequest: Encodable { let fileName: String; let contentType: String; let sizeBytes: Int }
private struct UploadResponse: Decodable {
    let uploadId: String; let status: String; let uploadUrl: String?; let requiredHeaders: [String: String]
}
private struct CompletedUploadResponse: Decodable { let uploadId: String; let status: String }
