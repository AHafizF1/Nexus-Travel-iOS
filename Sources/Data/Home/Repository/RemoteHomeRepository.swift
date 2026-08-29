import Foundation

struct RemoteHomeRepository: HomeRepository {
    let transport: HTTPTransport

    func getHomeContent() async throws -> HomeResult<HomeContent> {
        do {
            let airportsResponse = try await transport.send(HTTPRequest(
                target: .mobile(HomeEndpoints.popularAirports),
                queryItems: [URLQueryItem(name: "limit", value: "20")]
            ))
            guard (200..<300).contains(airportsResponse.statusCode) else { return .unknownError }
            let airportDTOs = try JSONDecoder().decode(AirportListDTO.self, from: airportsResponse.data)
            let airports = airportDTOs.items.map(AirportMapper.map)
            let addisAbaba = Airport(code: "ADD", city: "Addis Ababa", name: "Addis Ababa Bole International Airport", country: "Ethiopia")
            let dubai = Airport(code: "DXB", city: "Dubai", name: "Dubai International Airport", country: "United Arab Emirates")
            let origin = airports.first { $0.code == addisAbaba.code } ?? airports.first ?? addisAbaba
            let destination = airports.first { $0.code == dubai.code }
                ?? airports.first { $0.code != origin.code }
                ?? dubai
            let exploreResponse = try await transport.send(HTTPRequest(target: .mobile(HomeEndpoints.explore)))
            guard (200..<300).contains(exploreResponse.statusCode) else { return .unknownError }
            let explore = try JSONDecoder().decode(ExploreHomeDTO.self, from: exploreResponse.data)
            return .success(HomeContentMapper.map(explore, origin: origin, destination: destination))
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as HTTPTransportError {
            switch error {
            case .networkUnavailable, .timedOut: return .networkUnavailable
            case .invalidRequest, .nonHTTPResponse: return .unknownError
            }
        } catch {
            return .unknownError
        }
    }
}
