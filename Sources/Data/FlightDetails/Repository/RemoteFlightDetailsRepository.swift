import Foundation

/// Remote adapter for pricing and revalidating selected flight offers.
struct RemoteFlightDetailsRepository: FlightDetailsRepository {
    let transport: HTTPTransport

    func priceOffer(reference: FlightOfferReference) async throws -> FlightDetailsResult {
        do {
            let body = try JSONEncoder().encode(PriceOfferRequestDTO(searchSessionId: reference.searchId, offerId: reference.offerId))
            let response = try await transport.send(HTTPRequest(target: .mobile(FlightDetailsEndpoints.details), method: .post, body: body, timeout: 90))
            switch response.statusCode {
            case 200..<300:
                return try FlightDetailsResponseMapper.map(JSONDecoder().decode(PriceOfferResponseDTO.self, from: response.data), reference: reference)
            case 401: return .authRequired
            case 404, 503: return .offerUnavailable
            case 410: return .offerExpired
            default: return .unknownError
            }
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as HTTPTransportError {
            switch error { case .timedOut, .networkUnavailable: return .networkUnavailable; default: return .unknownError }
        } catch {
            return .unknownError
        }
    }
}
