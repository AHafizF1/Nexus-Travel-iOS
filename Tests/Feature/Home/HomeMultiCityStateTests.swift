import Testing
@testable import NexusTravel

struct HomeMultiCityStateTests {
    private let nbo = Airport(code: "NBO", city: "Nairobi", name: "JKIA", country: "Kenya")
    private let dxb = Airport(code: "DXB", city: "Dubai", name: "Dubai International", country: "UAE")
    private let lhr = Airport(code: "LHR", city: "London", name: "Heathrow", country: "UK")

    @Test func initialStateAlwaysHasTwoLinkedLegs() throws {
        let date = try #require(LocalDate(iso8601: "2026-09-01"))
        let legs = initialMultiCityLegs(origin: nbo, destination: dxb, date: date)
        #expect(legs == [
            MultiCityLegUiState(origin: nbo, destination: dxb, departureDate: date),
            MultiCityLegUiState(origin: dxb, departureDate: date.addingDays(7), originAutoLinked: true)
        ])
        #expect(initialMultiCityLegs(origin: nil, destination: nil, date: nil).count == 2)
        #expect(initialMultiCityLegs(origin: nil, destination: nil, date: nil)[1].departureDate == nil)
    }

    @Test func originSelectionClearsAutoLinkAndInvalidIndexIsNoOp() {
        let legs = [MultiCityLegUiState(origin: dxb, originAutoLinked: true)]
        let updated = legs.selectMultiCityOrigin(index: 0, airport: nbo)
        #expect(updated[0].origin == nbo)
        #expect(!updated[0].originAutoLinked)
        #expect(updated.selectMultiCityOrigin(index: 4, airport: lhr) == updated)
    }

    @Test func destinationAutoLinksOnlyBlankOrAutoLinkedNextOrigin() {
        let blank = [MultiCityLegUiState(), MultiCityLegUiState()]
            .selectMultiCityDestination(index: 0, airport: lhr)
        #expect(blank[1].origin == lhr)
        #expect(blank[1].originAutoLinked)

        let linked = [MultiCityLegUiState(), MultiCityLegUiState(origin: dxb, originAutoLinked: true)]
            .selectMultiCityDestination(index: 0, airport: lhr)
        #expect(linked[1].origin == lhr)
        #expect(linked[1].originAutoLinked)

        let manual = [MultiCityLegUiState(), MultiCityLegUiState(origin: nbo)]
            .selectMultiCityDestination(index: 0, airport: lhr)
        #expect(manual[1].origin == nbo)
        #expect(!manual[1].originAutoLinked)
        #expect(manual.selectMultiCityDestination(index: 5, airport: dxb) == manual)
    }

    @Test func dateSelectionPropagatesNondecreasingDatesAndIsSafe() throws {
        let selected = try #require(LocalDate(iso8601: "2026-09-10"))
        let equal = selected
        let later = try #require(LocalDate(iso8601: "2026-09-20"))
        let legs = [
            MultiCityLegUiState(),
            MultiCityLegUiState(departureDate: nil),
            MultiCityLegUiState(departureDate: later)
        ].selectMultiCityDate(index: 0, date: selected)
        #expect(legs.map(\.departureDate) == [selected, equal, later])
        #expect(legs.selectMultiCityDate(index: -1, date: selected) == legs)
    }

    @Test func addAndRemoveRespectLimitsWithoutRelinking() throws {
        let date = try #require(LocalDate(iso8601: "2026-09-01"))
        let two = initialMultiCityLegs(origin: nbo, destination: dxb, date: date)
        let three = two.addMultiCityLeg()
        #expect(three.count == 3)
        #expect(three[2].origin == nil)
        #expect(three[2].departureDate == two[1].departureDate)
        #expect(three.addMultiCityLeg() == three)
        #expect([MultiCityLegUiState]().addMultiCityLeg().isEmpty)
        #expect(two.removeMultiCityLeg(index: 0) == two)
        #expect(three.removeMultiCityLeg(index: 8) == three)
        #expect(three.removeMultiCityLeg(index: 1) == [three[0], three[2]])
    }

    @Test func tripTypeTransitionInitializesOncePreservesLegsAndClearsOnlyReturnError() throws {
        let date = try #require(LocalDate(iso8601: "2026-09-01"))
        let initial = HomeUiState(origin: nbo, destination: dxb, departureDate: date, validationError: .returnBeforeDeparture)
        let multiCity = initial.settingTripType(.multiCity)
        #expect(multiCity.multiCityLegs.count == 2)
        #expect(multiCity.validationError == .returnBeforeDeparture)
        let roundTrip = multiCity.settingTripType(.roundTrip)
        #expect(roundTrip.multiCityLegs == multiCity.multiCityLegs)
        #expect(roundTrip.settingTripType(.multiCity).multiCityLegs == multiCity.multiCityLegs)
        #expect(roundTrip.settingTripType(.oneWay).validationError == nil)
        #expect(HomeUiState(validationError: .missingOrigin).settingTripType(.oneWay).validationError == .missingOrigin)
    }
}
