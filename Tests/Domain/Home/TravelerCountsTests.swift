import Testing
@testable import NexusTravel

struct TravelerCountsTests {
    @Test(arguments: [
        (TravelerCounts(adults: 8, children: 4, infants: 3), TravelerCounts(adults: 8, children: 1, infants: 0)),
        (TravelerCounts(adults: 2, children: 0, infants: 5), TravelerCounts(adults: 2, children: 0, infants: 2)),
        (TravelerCounts(adults: 0, children: -2, infants: -1), TravelerCounts(adults: 1, children: 0, infants: 0)),
        (TravelerCounts(adults: 20, children: 2, infants: 2), TravelerCounts(adults: 9, children: 0, infants: 0))
    ])
    func normalizationMatchesAndroid(input: TravelerCounts, expected: TravelerCounts) {
        #expect(input.normalized() == expected)
        #expect(input.normalized().normalized() == expected)
        #expect(expected.total <= TravelerCounts.maxTravelers)
    }

    @Test func totalAndSummaryUseRawStoredCounts() {
        let counts = TravelerCounts(adults: 1, children: 1, infants: 1)
        #expect(counts.total == 3)
        #expect(counts.summary() == "1 Adult · 1 Child · 1 Infant")
        #expect(TravelerCounts(adults: 2, children: 2, infants: 2).summary() == "2 Adults · 2 Children · 2 Infants")
        #expect(TravelerCounts(adults: 1).summary() == "1 Adult")
        #expect(TravelerCounts(adults: -1, children: -1, infants: -1).summary() == "-1 Adults")
    }
}
