struct ExploreCheapestFlight: Codable, Equatable, Sendable { let amountMinor: Int; let currency, departureDate: String; let freshnessLabel: String?; let isStale: Bool }
struct ExploreDestination: Codable, Equatable, Sendable { let id, title, city, country, summary: String; let airportCode, imageUrl, imageCacheKey: String?; let gallery, highlights: [String]; let bestTravelPeriod: String?; let cheapestFlight: ExploreCheapestFlight? }
struct ExplorePackage: Codable, Equatable, Sendable { let id, destinationId, title, summary: String; let imageUrl: String?; let priceFromMinor: Int; let currency: String; let imageCacheKey: String? }
struct ExploreBanner: Codable, Equatable, Sendable { let id, title, subtitle: String; let imageUrl, imageCacheKey, destinationId: String? }
struct ExploreContent: Codable, Equatable, Sendable { let banners: [ExploreBanner]; let destinations: [ExploreDestination]; let packages: [ExplorePackage] }
struct ExploreDestinationDetail: Equatable, Sendable { let destination: ExploreDestination; let packages: [ExplorePackage] }
struct ExplorePackageDetail: Equatable, Sendable { let package: ExplorePackage; let destination: ExploreDestination }
enum ExploreResult<Value: Equatable & Sendable>: Equatable, Sendable { case success(Value); case empty, unavailable, networkUnavailable, failed }
protocol ExploreRepository: Sendable {
    func content(forceRefresh: Bool) async throws -> ExploreResult<ExploreContent>
    func destination(id: String) async throws -> ExploreResult<ExploreDestinationDetail>
    func travelPackage(id: String) async throws -> ExploreResult<ExplorePackageDetail>
}
