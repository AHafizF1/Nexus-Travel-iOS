import Foundation

struct RemoteBookingRequestRepository: BookingRequestRepository {
    private let transport: HTTPTransport
    private let tokenProvider: AuthTokenProvider
    init(transport: HTTPTransport, tokenProvider: AuthTokenProvider) {
        self.transport = transport; self.tokenProvider = tokenProvider
    }

    func getReview(reviewId: String) async throws -> BookingRequestResult {
        do {
            guard let token = try await tokenProvider.accessToken() else { return .unknownError }
            let response = try await transport.send(HTTPRequest(
                target: .mobile("bookings/\(reviewId)/review"), authorization: .bearer(token)
            ))
            switch response.statusCode {
            case 200..<300:
                guard let dto = try? JSONDecoder().decode(BookingResponseDTO.self, from: response.data) else { return .unknownError }
                return .success(dto.review)
            case 404: return .notFound
            case 410: return .expired
            default: return .unknownError
            }
        } catch is CancellationError { throw CancellationError() }
        catch HTTPTransportError.networkUnavailable, HTTPTransportError.timedOut { return .networkUnavailable }
        catch { return .unknownError }
    }

    func submitReview(reviewId: String, idempotencyKey: String) async throws -> BookingSubmitResult {
        do {
            guard let token = try await tokenProvider.accessToken(), !idempotencyKey.isEmpty else { return .unknownError }
            let response = try await transport.send(HTTPRequest(
                target: .mobile("bookings/\(reviewId)/hold"), method: .post,
                headers: ["Idempotency-Key": idempotencyKey], authorization: .bearer(token)
            ))
            switch response.statusCode {
            case 200..<300:
                guard let dto = try? JSONDecoder().decode(BookingResponseDTO.self, from: response.data) else { return .unknownError }
                if dto.status == "HOLD_UNCONFIRMED" { return .outcomeUnknown }
                if dto.failureReasonCode == "FARE_UNAVAILABLE" {
                    return .fareUnavailable(dto.failureReason ?? "This fare is no longer available. Choose another flight.")
                }
                guard dto.status == "BOOKING_HELD", let reference = dto.travelportLocator,
                      Self.validSupplierReference(reference) else { return .unavailable }
                return .success(reviewId: dto.id, bookingReference: reference.trimmingCharacters(in: .whitespacesAndNewlines),
                                status: .submittedForManualReview)
            case 404: return .notFound
            case 410: return .expired
            case 409, 429: return .unavailable
            default: return .unknownError
            }
        } catch is CancellationError { throw CancellationError() }
        catch HTTPTransportError.networkUnavailable, HTTPTransportError.timedOut { return .networkUnavailable }
        catch { return .unknownError }
    }

    private static func validSupplierReference(_ value: String) -> Bool {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return !normalized.isEmpty && normalized != "UNKNOWN" && !normalized.hasPrefix("FAKE") && !normalized.hasPrefix("LOCAL")
    }
}

private struct BookingResponseDTO: Decodable {
    let amountMinor: Int; let currency, id, status: String
    let travelportLocator, failureReason, failureReasonCode: String?
    let passengerDetailsSnapshot: PassengerSnapshotDTO?
    let contactSnapshot: ContactSnapshotDTO?
    let seatSelectionSnapshot: SeatSelectionSnapshotDTO?
    var review: BookingReviewDetails {
        .init(reviewId: id, bookingReference: travelportLocator, status: status.bookingStatus,
              passengers: passengerDetailsSnapshot?.passengers.map(\.domain) ?? [],
              contact: contactSnapshot?.domain ?? .init(email: "", phone: ""),
              seats: seatSelectionSnapshot?.assignments.map { $0.domain(currency: seatSelectionSnapshot?.currency ?? currency) } ?? [],
              fareTotal: .init(amount: amountMinor, currency: currency, formatted: moneyLabel(amountMinor, currency)))
    }
}
private struct PassengerSnapshotDTO: Decodable { let passengers: [PassengerReviewDTO] }
private struct PassengerReviewDTO: Decodable {
    let title, firstName, lastName, passportNumber, nationality: String
    var domain: BookingReviewPassenger { .init(title: title, firstName: firstName, lastName: lastName, passportNumber: passportNumber, nationality: nationality) }
}
private struct ContactSnapshotDTO: Decodable {
    let email, phone: String
    var domain: BookingReviewContact { .init(email: email, phone: phone) }
}
private struct SeatSelectionSnapshotDTO: Decodable { let assignments: [SeatReviewDTO]; let currency: String }
private struct SeatReviewDTO: Decodable {
    let passengerIndex, priceAmountMinor: Int; let segmentId, seatNumber: String
    func domain(currency: String) -> SeatAssignment {
        .init(passengerIndex: passengerIndex, segmentId: segmentId, seatNumber: seatNumber,
              price: priceAmountMinor > 0 ? .init(amount: priceAmountMinor, currency: currency,
                                                 formatted: moneyLabel(priceAmountMinor, currency)) : nil)
    }
}
private extension String {
    var bookingStatus: BookingRequestStatus {
        switch uppercased() {
        case "PRICED", "READY_TO_HOLD": .draftSaved
        case "BOOKING_HELD": .submittedForManualReview
        case "HOLD_REQUESTED", "HOLDING_WITH_TRAVELPORT", "HOLD_UNCONFIRMED": .agentReviewing
        case "PAYMENT_CONFIRMED", "TICKETED": .confirmed
        case "HOLD_EXPIRED", "EXPIRED": .expired
        case "HOLD_FAILED", "UNAVAILABLE": .unavailable
        default: .none
        }
    }
}
private func moneyLabel(_ amount: Int, _ currency: String) -> String { String(format: "%@ %.2f", currency, Double(amount) / 100) }
