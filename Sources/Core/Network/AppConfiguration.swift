import Foundation

enum AppConfiguration {
    static let productionOrigin: URL = {
        guard let origin = URL(string: "https://api.travelwithnexus.com") else {
            preconditionFailure("Production API origin must be a valid URL.")
        }

        return origin
    }()

    static let mobileBasePath = "/api/v1/mobile"
    static let healthPath = "/api/v1/health"

    /// Resolves configured or absolute request target without path traversal.
    static func url(for target: HTTPRequestTarget) throws -> URL {
        switch target {
        case let .absolute(url):
            guard ["http", "https"].contains(url.scheme?.lowercased() ?? ""), url.host != nil else {
                throw HTTPTransportError.invalidRequest
            }
            return url
        case let .mobile(path):
            return try configuredURL(prefix: mobileBasePath, path: path)
        case let .root(path):
            return try configuredURL(prefix: "", path: path)
        }
    }

    private static func configuredURL(prefix: String, path: String) throws -> URL {
        let components = path.split(separator: "/", omittingEmptySubsequences: true)
        guard !components.contains("..") else { throw HTTPTransportError.invalidRequest }
        let normalizedPath = components.joined(separator: "/")
        let base = productionOrigin.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let normalizedPrefix = prefix.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let pieces = [base, normalizedPrefix, normalizedPath].filter { !$0.isEmpty }
        guard let url = URL(string: pieces.joined(separator: "/")) else {
            throw HTTPTransportError.invalidRequest
        }
        return url
    }
}
