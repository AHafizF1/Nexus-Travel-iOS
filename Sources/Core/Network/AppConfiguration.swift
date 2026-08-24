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
}
