import Testing
@testable import NexusTravel

struct PassengerDetailsModelsTests {
    @Test func draftFullNameKeepsNonblankNames() {
        let draft = passengerDraft(firstName: " Ada ", lastName: "Lovelace")
        #expect(draft.fullName == " Ada  Lovelace")
        #expect(passengerDraft(firstName: "", lastName: "Lovelace").fullName == "Lovelace")
    }

    @Test func passengerTypesAndResultsPreserveValues() {
        #expect([PassengerType.adult, .child, .infant].count == 3)
        let total = Money(amount: 1200, currency: "ETB", formatted: "ETB 1,200")
        #expect(PassengerDetailsResult.success(reviewId: "review", total: total) ==
            .success(reviewId: "review", total: total))
        #expect(PassengerDetailsResult.validationRejected([
            PassengerDetailsRejectedField(field: "email", message: "Invalid")
        ]) == .validationRejected([PassengerDetailsRejectedField(field: "email", message: "Invalid")]))
    }

    private func passengerDraft(firstName: String, lastName: String) -> PassengerDetailsDraft {
        PassengerDetailsDraft(
            passengerType: .adult, title: "Ms", gender: "Female", firstName: firstName,
            lastName: lastName, dateOfBirth: nil, nationalityCountryCode: "ET",
            passportNumber: "P1", passportExpiryDate: nil,
            passportIssuingCountryCode: "ET", document: nil
        )
    }
}
