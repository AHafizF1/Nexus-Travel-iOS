/// Latest booking-request state associated with an offer.
struct BookingRequestSnapshot: Equatable, Hashable, Codable, Sendable {
    let offerId: String
    let reviewId: String?
    let status: BookingRequestStatus
    let bookingReference: String?

    /// Creates snapshot with no booking reference by default.
    init(offerId: String, reviewId: String?, status: BookingRequestStatus, bookingReference: String? = nil) {
        self.offerId = offerId
        self.reviewId = reviewId
        self.status = status
        self.bookingReference = bookingReference
    }

    /// Whether any booking request exists.
    var hasRequest: Bool { status != .none }
}

/// Booking-request lifecycle status.
enum BookingRequestStatus: String, Equatable, Hashable, Codable, Sendable {
    case none
    case draftSaved
    case submittedForManualReview
    case agentReviewing
    case confirmed
    case expired
    case unavailable

    /// Android-equivalent user-facing status label.
    var label: String {
        switch self {
        case .none: ""
        case .draftSaved: "Request saved"
        case .submittedForManualReview: "Manual review"
        case .agentReviewing: "Agent reviewing"
        case .confirmed: "Confirmed"
        case .expired: "Expired"
        case .unavailable: "Unavailable"
        }
    }
}
