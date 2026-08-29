import Foundation

struct PriceOfferRequestDTO: Encodable, Sendable {
    let searchSessionId: String
    let offerId: String
}

struct PriceOfferResponseDTO: Decodable, Sendable {
    let status: String
    let details: FlightDetailsDTO?
    let previousTotal: MoneyDTO?
}

struct FlightDetailsDTO: Decodable, Sendable {
    let tripType: String
    let originCode: String
    let destinationCode: String
    let departureDate: String
    let returnDate: String?
    let adults: Int
    let children: Int
    let infants: Int
    let cabinClass: String
    let airlineName: String?
    let airlineLogoKey: String?
    let flightNumber: String
    let badge: String?
    let price: MoneyDTO
    let oldPrice: MoneyDTO?
    let legs: [FlightDetailsLegDTO]
    let baggage: BaggageSummaryDTO
    let fareRules: FareRulesSummaryDTO
    let priceBreakdown: PriceBreakdownDTO
    let aircraft: AircraftSummaryDTO
    let seat: SeatSummaryDTO
    let fareAvailability: FareAvailabilityDTO?
    let warnings: [SearchWarningDTO]
}

struct MoneyDTO: Decodable, Sendable { let amount: Int; let currency: String; let formatted: String }
struct SearchWarningDTO: Decodable, Sendable { let code: String; let message: String }
struct FareAvailabilityDTO: Decodable, Sendable { let status: String; let remainingSeats: Int? }
struct BaggageSummaryDTO: Decodable, Sendable { let cabin: String; let checked: String; let included: Bool; let detail: String }
struct FareRuleSectionDTO: Decodable, Sendable { let title: String; let items: [String] }
struct FareRulesSummaryDTO: Decodable, Sendable {
    let refundableLabel: String; let changeLabel: String; let cancellationLabel: String; let sections: [FareRuleSectionDTO]
}
struct PriceBreakdownDTO: Decodable, Sendable { let baseFare: MoneyDTO; let taxesAndFees: MoneyDTO; let serviceFee: MoneyDTO?; let total: MoneyDTO }
struct AircraftSummaryDTO: Decodable, Sendable { let aircraftName: String; let operatingAirline: String?; let note: String }
struct SeatSummaryDTO: Decodable, Sendable { let selectedSeat: String?; let availabilityLabel: String; let extraLegroomAvailable: Bool }

struct FlightDetailsLegDTO: Decodable, Sendable {
    let label: String; let date: String
    let departureAirportCode: String; let departureAirportName: String
    let arrivalAirportCode: String; let arrivalAirportName: String
    let departureTime: String; let arrivalTime: String
    let durationMinutes: Int; let stopLabel: String; let segments: [FlightDetailsSegmentDTO]
}

struct FlightDetailsSegmentDTO: Decodable, Sendable {
    let departureAirportCode: String; let arrivalAirportCode: String; let layoverAfterMinutes: Int?
    let departureDate: String?; let arrivalDate: String?; let departureTime: String?; let arrivalTime: String?
    let durationMinutes: Int; let marketingAirlineName: String?; let operatingAirlineName: String?
    let flightNumber: String; let operatingFlightNumber: String?; let equipment: String?; let cabin: String?; let bookingClass: String?
}
