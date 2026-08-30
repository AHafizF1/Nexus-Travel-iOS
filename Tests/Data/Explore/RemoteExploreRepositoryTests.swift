import Foundation
import Testing
@testable import NexusTravel

struct RemoteExploreRepositoryTests {
    @Test func homeAndDetailsUseExactAnonymousRoutes() async throws {
        let loader = ExploreLoader(responses: [
            Self.response(200, #"{"banners":[],"destinations":[],"packages":[]}"#),
            Self.response(200, #"{"id":"d1","title":"Dubai","city":"Dubai","country":"UAE","summary":"Sunny","airportCode":"DXB","imageUrl":null,"imageCacheKey":null,"gallery":[],"highlights":[],"bestTravelPeriod":null,"cheapestFlight":null,"packages":[],"relatedDeals":[]}"#),
            Self.response(200, #"{"id":"p1","destinationId":"d1","title":"Dubai week","summary":"Seven nights","imageUrl":null,"imageCacheKey":null,"priceFromMinor":120000,"currency":"INR","destination":{"id":"d1","title":"Dubai","city":"Dubai","country":"UAE","summary":"Sunny","airportCode":"DXB","imageUrl":null,"imageCacheKey":null,"gallery":[],"highlights":[],"bestTravelPeriod":null,"cheapestFlight":null}}"#)
        ])
        let repository = RemoteExploreRepository(transport: HTTPTransport(loader: loader), cache: ExploreCache())

        _ = try await repository.content(forceRefresh: true)
        _ = try await repository.destination(id: "d1")
        _ = try await repository.travelPackage(id: "p1")

        let requests = await loader.requests
        #expect(requests.map { $0.url?.path } == ["/api/v1/mobile/explore", "/api/v1/mobile/explore/destinations/d1", "/api/v1/mobile/explore/packages/p1"])
        #expect(requests.allSatisfy { $0.value(forHTTPHeaderField: "Authorization") == nil })
    }

    @Test func missingRequiredFieldsFailDecoding() async throws {
        let loader = ExploreLoader(responses: [Self.response(200, #"{"banners":[],"destinations":[{"id":"d1"}],"packages":[]}"#)])
        let repository = RemoteExploreRepository(transport: HTTPTransport(loader: loader), cache: ExploreCache())
        #expect(try await repository.content(forceRefresh: true) == .failed)
    }

    private static func response(_ status: Int, _ body: String) -> (Data, URLResponse) {
        (Data(body.utf8), HTTPURLResponse(url: URL(string: "https://api.travelwithnexus.com")!, statusCode: status, httpVersion: nil, headerFields: nil)!)
    }
}

private actor ExploreLoader: HTTPDataLoading {
    private var responses: [(Data, URLResponse)]
    private(set) var requests: [URLRequest] = []
    init(responses: [(Data, URLResponse)]) { self.responses = responses }
    func data(for request: URLRequest) async throws -> (Data, URLResponse) { requests.append(request); return responses.removeFirst() }
}
