import Foundation
import Observation

enum PassengerDetailsNavigationEvent: Equatable, Sendable { case back, authenticate, seats(String), editSearch }

@MainActor
@Observable
final class PassengerDetailsViewModel {
    var form = PassengerDetailsFormState()
    private(set) var validation = PassengerValidationState()
    private(set) var isSubmitting = false
    private(set) var errorMessage: String?
    let details: FlightDetails
    private let repository: any PassengerDetailsRepository
    private let today: () -> LocalDate
    private let clientSessionId: String
    private var navigationEvents: [PassengerDetailsNavigationEvent] = []

    init(details: FlightDetails, repository: any PassengerDetailsRepository,
         clientSessionId: String = "ios_\(UUID().uuidString)", today: @escaping () -> LocalDate) {
        self.details = details; self.repository = repository; self.clientSessionId = clientSessionId; self.today = today
    }

    func submit(authenticated: Bool) async throws {
        validation = PassengerDetailsValidator.validate(form: form, details: details, today: today())
        guard !validation.hasErrors else { return }
        guard authenticated else { navigationEvents.append(.authenticate); return }
        isSubmitting = true; errorMessage = nil
        defer { isSubmitting = false }
        let request = SubmitPassengerDetailsRequest(
            offerReference: details.reference,
            passengers: [.init(passengerType: .adult, title: form.title, gender: form.gender,
                               firstName: form.firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                               lastName: form.lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                               dateOfBirth: form.dateOfBirth, nationalityCountryCode: form.nationalityCountryCode,
                               passportNumber: form.passportNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                               passportExpiryDate: form.passportExpiryDate,
                               passportIssuingCountryCode: form.passportIssuingCountryCode, document: form.passportDocument)],
            contact: .init(email: form.email.trimmingCharacters(in: .whitespacesAndNewlines),
                           countryDialCode: form.countryDialCode,
                           phoneNumber: form.phoneNumber.filter(\.isNumber)),
            clientSessionId: clientSessionId
        )
        switch try await repository.submitPassengerDetails(request) {
        case let .success(reviewId, _): navigationEvents.append(.seats(reviewId))
        case .authRequired: errorMessage = "Please sign in again to continue."
        case .networkUnavailable: errorMessage = "Connection lost. Check your internet and try again."
        case .offerExpired: errorMessage = "This fare expired. Please choose the flight again."
        case .offerUnavailable: errorMessage = "This fare is no longer available."
        case let .validationRejected(errors):
            errorMessage = errors.first?.message ?? "Check passenger details and try again."
        case .unknownError: errorMessage = "We couldn’t save passenger details. Please try again."
        }
    }

    func consumeNavigationEvent() -> PassengerDetailsNavigationEvent? {
        navigationEvents.isEmpty ? nil : navigationEvents.removeFirst()
    }
}
