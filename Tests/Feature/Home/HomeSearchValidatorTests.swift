import Testing
@testable import NexusTravel

struct HomeSearchValidatorTests {
    private let validator = HomeSearchValidator()
    private let add = Airport(code: "ADD", city: "Addis Ababa", name: "Bole", country: "Ethiopia")
    private let dxb = Airport(code: "DXB", city: "Dubai", name: "Dubai International", country: "UAE")

    @Test func normalValidationUsesExactPrecedence() throws {
        let today = try #require(LocalDate(year: 2026, month: 5, day: 20))
        #expect(validator.validateSearch(state: HomeUiState(), today: today) == .missingOrigin)
        #expect(validator.validateSearch(state: HomeUiState(origin: add), today: today) == .missingDestination)
        #expect(validator.validateSearch(state: HomeUiState(origin: add, destination: add), today: today) == .sameOriginDestination)
        #expect(validator.validateSearch(state: HomeUiState(origin: add, destination: dxb), today: today) == .missingDepartureDate)
    }

    @Test func oneWayAllowsTodayAndIgnoresReturnDate() throws {
        let today = try #require(LocalDate(year: 2026, month: 5, day: 20))
        let state = HomeUiState(tripType: .oneWay, origin: add, destination: dxb, departureDate: today, returnDate: today.addingDays(-1))
        #expect(validator.validateSearch(state: state, today: today) == nil)
        #expect(validator.validateSearch(state: HomeUiState(tripType: .oneWay, origin: add, destination: dxb, departureDate: today.addingDays(-1)), today: today) == .departureDateInPast)
    }

    @Test func roundTripRequiresStrictlyLaterReturn() throws {
        let today = try #require(LocalDate(year: 2026, month: 5, day: 20))
        let base = HomeUiState(tripType: .roundTrip, origin: add, destination: dxb, departureDate: today)
        #expect(validator.validateSearch(state: base, today: today) == .missingReturnDate)
        #expect(validator.validateSearch(state: HomeUiState(tripType: .roundTrip, origin: add, destination: dxb, departureDate: today, returnDate: today), today: today) == .returnBeforeDeparture)
        #expect(validator.validateSearch(state: HomeUiState(tripType: .roundTrip, origin: add, destination: dxb, departureDate: today, returnDate: today.addingDays(1)), today: today) == nil)
    }

    @Test func multiCityRequiresTwoToThreeCompleteValidLegs() throws {
        let today = try #require(LocalDate(year: 2026, month: 5, day: 20))
        #expect(validateMultiCity([], today: today) == .invalidMultiCityLegs)
        #expect(validateMultiCity([validLeg(today: today)], today: today) == .invalidMultiCityLegs)
        #expect(validateMultiCity(Array(repeating: validLeg(today: today), count: 4), today: today) == .invalidMultiCityLegs)
        #expect(validateMultiCity([MultiCityLegUiState(destination: dxb, departureDate: today), validLeg(today: today)], today: today) == .invalidMultiCityLegs)
        #expect(validateMultiCity([MultiCityLegUiState(origin: add, departureDate: today), validLeg(today: today)], today: today) == .invalidMultiCityLegs)
        #expect(validateMultiCity([MultiCityLegUiState(origin: add, destination: dxb), validLeg(today: today)], today: today) == .invalidMultiCityLegs)
        #expect(validateMultiCity([validLeg(destination: add, today: today), validLeg(today: today)], today: today) == .invalidMultiCityLegs)
        #expect(validateMultiCity([validLeg(date: today.addingDays(-1), today: today), validLeg(today: today)], today: today) == .invalidMultiCityLegs)
    }

    @Test func multiCityDatesAreNondecreasingAndTopLevelFieldsAreIgnored() throws {
        let today = try #require(LocalDate(year: 2026, month: 5, day: 20))
        let later = today.addingDays(2)
        #expect(validateMultiCity([validLeg(date: later, today: today), validLeg(date: today, today: today)], today: today) == .invalidMultiCityLegs)
        #expect(validateMultiCity([validLeg(date: today, today: today), validLeg(date: today, today: today)], today: today) == nil)
        let lowercaseAdd = Airport(code: "add", city: "Addis Ababa", name: "Bole", country: "Ethiopia")
        #expect(validateMultiCity([validLeg(destination: lowercaseAdd, today: today), validLeg(today: today)], today: today) == nil)
        let state = HomeUiState(tripType: .multiCity, multiCityLegs: [validLeg(today: today), validLeg(today: today)])
        #expect(validator.validateSearch(state: state, today: today) == nil)
    }

    private func validLeg(destination: Airport? = nil, date: LocalDate? = nil, today: LocalDate) -> MultiCityLegUiState {
        MultiCityLegUiState(origin: add, destination: destination ?? dxb, departureDate: date ?? today)
    }

    private func validateMultiCity(_ legs: [MultiCityLegUiState], today: LocalDate) -> HomeValidationError? {
        validator.validateSearch(state: HomeUiState(tripType: .multiCity, multiCityLegs: legs), today: today)
    }
}
