struct AirportListDTO: Decodable, Sendable {
    let items: [AirportDTO]
    let limit: Int
}

struct AirportDTO: Decodable, Sendable {
    let iataCode: String
    let name: String
    let city: String
    let country: String
}

struct ExploreHomeDTO: Decodable, Sendable {
    let destinations: [DestinationDTO]
    let packages: [TravelPackageDTO]
}

struct DestinationDTO: Decodable, Sendable {
    let id: String
    let title: String
    let city: String
    let country: String
    let summary: String
    let airportCode: String?
    let imageUrl: String?
}

struct TravelPackageDTO: Decodable, Sendable {
    let id: String
    let title: String
    let summary: String
    let priceFromMinor: Int
    let currency: String
}
