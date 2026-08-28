import Testing
@testable import NexusTravel

struct PassengerDateInputTests {
    @Test func partChangesKeepDigitsWithinLimits() {
        let input = PassengerDateInput(day: "", month: "", year: "")
            .withDay("a123").withMonth("045").withYear("20x260")
        #expect(input.day == "12")
        #expect(input.month == "04")
        #expect(input.year == "2026")
    }

    @Test func parsingRequiresCompleteValidGregorianDateInSupportedYears() {
        #expect(!PassengerDateInput(day: "", month: "2", year: "2024").complete)
        #expect(PassengerDateInput(day: "29", month: "2", year: "2024").parsed == date(2024, 2, 29))
        #expect(PassengerDateInput(day: "29", month: "2", year: "2023").parsed == nil)
        #expect(PassengerDateInput(day: "1", month: "1", year: "1899").parsed == nil)
        #expect(PassengerDateInput(day: "1", month: "1", year: "2101").parsed == nil)
    }

    @Test func formHelpersSynchronizePartsAndAggregateDates() {
        let form = PassengerDetailsFormState()
            .withDateOfBirth(PassengerDateInput(day: "15", month: "1", year: "1995"))
            .withPassportExpiry(PassengerDateInput(day: "1", month: "12", year: "2030"))
        #expect(form.dateOfBirth == date(1995, 1, 15))
        #expect(form.passportExpiryDate == date(2030, 12, 1))
        #expect(form.dateOfBirthInput().day == "15")
        #expect(form.passportExpiryInput().year == "2030")
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> LocalDate {
        LocalDate(year: year, month: month, day: day)!
    }
}
