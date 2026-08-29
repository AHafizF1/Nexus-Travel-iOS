import Foundation

struct RemoteAirportRepository: AirportRepository {
    let transport: HTTPTransport
    let cache: AirportCache

    func searchAirports(query: String) async throws -> [Airport] {
        let key = AirportCache.key(for: query)
        let cached = await cache.entry(for: key)
        if let cached, !cached.needsRevalidation { return cached.airports }
        do {
            let isPopular = query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            var queryItems: [URLQueryItem] = []
            if !isPopular { queryItems.append(URLQueryItem(name: "q", value: query)) }
            queryItems.append(URLQueryItem(name: "limit", value: isPopular ? "60" : "30"))
            let response = try await transport.send(HTTPRequest(
                target: .mobile(isPopular ? HomeEndpoints.popularAirports : HomeEndpoints.airportSearch),
                queryItems: queryItems
            ))
            guard (200..<300).contains(response.statusCode) else { return cached?.airports ?? [] }
            let dto = try JSONDecoder().decode(AirportListDTO.self, from: response.data)
            let airports = dto.items.map(AirportMapper.map)
            await cache.store(airports, for: key)
            return airports
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as HTTPTransportError {
            switch error {
            case .networkUnavailable, .timedOut: return cached?.airports ?? []
            case .invalidRequest, .nonHTTPResponse: throw error
            }
        }
    }
}
