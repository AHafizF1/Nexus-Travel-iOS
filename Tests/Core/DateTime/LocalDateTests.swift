import Foundation
import Testing
@testable import NexusTravel

struct LocalDateTests {
    @Test func validatesCalendarComponents() {
        #expect(LocalDate(year: 2024, month: 2, day: 29) != nil)
        #expect(LocalDate(year: 2025, month: 2, day: 29) == nil)
        #expect(LocalDate(year: 2025, month: 13, day: 1) == nil)
    }

    @Test func parsesAndFormatsStableISODate() throws {
        let date = try #require(LocalDate(iso8601: "2026-08-28"))
        #expect(date.year == 2026)
        #expect(date.month == 8)
        #expect(date.day == 28)
        #expect(date.iso8601 == "2026-08-28")
        #expect(LocalDate(iso8601: "2026-8-28") == nil)
        #expect(LocalDate(iso8601: "not-a-date") == nil)
    }

    @Test func ordersByCalendarDay() throws {
        let earlier = try #require(LocalDate(iso8601: "2026-12-31"))
        let later = try #require(LocalDate(iso8601: "2027-01-01"))
        #expect(earlier < later)
    }

    @Test func addsDaysAcrossMonthYearAndLeapDay() throws {
        let yearEnd = try #require(LocalDate(iso8601: "2026-12-31"))
        let leapEve = try #require(LocalDate(iso8601: "2024-02-28"))
        #expect(yearEnd.addingDays(1)?.iso8601 == "2027-01-01")
        #expect(leapEve.addingDays(1)?.iso8601 == "2024-02-29")
    }

    @Test func codableRoundTripsAsISOString() throws {
        let date = try #require(LocalDate(iso8601: "2026-08-28"))
        let data = try JSONEncoder().encode(date)
        #expect(String(decoding: data, as: UTF8.self) == "\"2026-08-28\"")
        #expect(try JSONDecoder().decode(LocalDate.self, from: data) == date)
    }
}
