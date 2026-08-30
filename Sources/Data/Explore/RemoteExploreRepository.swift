import Foundation

struct RemoteExploreRepository: ExploreRepository {
    private let transport: HTTPTransport
    private let cache: ExploreCache
    init(transport: HTTPTransport, cache: ExploreCache) { self.transport = transport; self.cache = cache }
    func content(forceRefresh: Bool = false) async throws -> ExploreResult<ExploreContent> {
        let key = "explore:home"
        if !forceRefresh, let cached = await cache.fresh(key: key), let value = try? JSONDecoder().decode(ExploreContent.self, from: cached.data) { return value.destinations.isEmpty && value.packages.isEmpty ? .empty : .success(value) }
        do {
            let response = try await transport.send(HTTPRequest(target: .mobile("explore")))
            guard (200..<300).contains(response.statusCode) else { if let cached = await cache.stale(key: key), let value = try? JSONDecoder().decode(ExploreContent.self, from: cached.data) { return .success(value) }; return .failed }
            guard let value = try? JSONDecoder().decode(ExploreContent.self, from: response.data) else { return .failed }
            await cache.put(key: key, data: response.data)
            return value.destinations.isEmpty && value.packages.isEmpty ? .empty : .success(value)
        } catch is CancellationError { throw CancellationError() }
        catch {
            guard let cached = await cache.stale(key: key), let value = try? JSONDecoder().decode(ExploreContent.self, from: cached.data) else { return networkResult(error) }
            return .success(value)
        }
    }
    func destination(id: String) async throws -> ExploreResult<ExploreDestinationDetail> {
        let key = "explore:destination:\(id)"
        if let cached = await cache.fresh(key: key), let value = try? JSONDecoder().decode(DestinationDetailDTO.self, from: cached.data) { return .success(value.domain) }
        do {
            let response = try await transport.send(HTTPRequest(target: .mobile("explore/destinations/\(id)")))
            if response.statusCode == 404 { return .unavailable }
            guard (200..<300).contains(response.statusCode) else { if let cached = await cache.stale(key: key), let value = try? JSONDecoder().decode(DestinationDetailDTO.self, from: cached.data) { return .success(value.domain) }; return .failed }
            guard let value = try? JSONDecoder().decode(DestinationDetailDTO.self, from: response.data) else { return .failed }
            await cache.put(key: key, data: response.data); return .success(value.domain)
        } catch is CancellationError { throw CancellationError() }
        catch { guard let cached = await cache.stale(key: key), let value = try? JSONDecoder().decode(DestinationDetailDTO.self, from: cached.data) else { return networkResult(error) }; return .success(value.domain) }
    }
    func travelPackage(id: String) async throws -> ExploreResult<ExplorePackageDetail> {
        do {
            let response = try await transport.send(HTTPRequest(target: .mobile("explore/packages/\(id)")))
            if response.statusCode == 404 { return .unavailable }
            guard (200..<300).contains(response.statusCode), let value = try? JSONDecoder().decode(PackageDetailDTO.self, from: response.data) else { return .failed }
            return .success(.init(package: value.package, destination: value.destination))
        } catch is CancellationError { throw CancellationError() } catch { return networkResult(error) }
    }
    private func networkResult<Value: Equatable & Sendable>(_ error: Error) -> ExploreResult<Value> { if error is HTTPTransportError { return .networkUnavailable }; return .failed }
}
private struct DestinationDetailDTO: Decodable { let id, title, city, country, summary: String; let airportCode, imageUrl, imageCacheKey: String?; let gallery, highlights: [String]; let bestTravelPeriod: String?; let packages: [ExplorePackage]; var domain: ExploreDestinationDetail { .init(destination: .init(id: id, title: title, city: city, country: country, summary: summary, airportCode: airportCode, imageUrl: imageUrl, imageCacheKey: imageCacheKey, gallery: gallery, highlights: highlights, bestTravelPeriod: bestTravelPeriod, cheapestFlight: nil), packages: packages) } }
private struct PackageDetailDTO: Decodable { let id, destinationId, title, summary: String; let imageUrl, imageCacheKey: String?; let priceFromMinor: Int; let currency: String; let destination: ExploreDestination; var package: ExplorePackage { .init(id: id, destinationId: destinationId, title: title, summary: summary, imageUrl: imageUrl, priceFromMinor: priceFromMinor, currency: currency, imageCacheKey: imageCacheKey) } }
