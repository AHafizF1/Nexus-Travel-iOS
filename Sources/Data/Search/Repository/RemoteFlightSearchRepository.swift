import Foundation

/// Remote anonymous flight-search adapter.
struct RemoteFlightSearchRepository: FlightSearchRepository {
    let transport: HTTPTransport
    let cache: SearchResultsCache

    func createSearch(request: FlightSearchRequest) async throws -> FlightSearchResult {
        do {
            let body = try JSONEncoder().encode(SearchRequestDTO(request))
            let response = try await transport.send(HTTPRequest(target: .mobile(SearchEndpoints.search), method: .post, body: body))
            guard (200..<300).contains(response.statusCode) else { return .unknownError }
            let dto = try JSONDecoder().decode(SearchResponseDTO.self, from: response.data)
            let mapped = try SearchResponseMapper.map(dto, request: request)
            await cache.store(.success(querySummary: mapped.querySummary, offers: mapped.offers), for: dto.sessionId)
            return .success(searchId: dto.sessionId)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as HTTPTransportError {
            switch error { case .timedOut, .networkUnavailable: return .networkUnavailable; default: return .unknownError }
        } catch {
            return .unknownError
        }
    }
}
