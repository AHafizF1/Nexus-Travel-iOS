import Foundation
import Testing
@testable import NexusTravel

struct LocalTimeTests {
    @Test func validatesAndFormatsExactTime() throws {
        let time = try #require(LocalTime(hour: 5, minute: 7))
        #expect(time.hhmm == "05:07")
        #expect(LocalTime(hour: -1, minute: 0) == nil)
        #expect(LocalTime(hour: 24, minute: 0) == nil)
        #expect(LocalTime(hour: 0, minute: 60) == nil)
    }

    @Test func parsesOnlyExactHHMMAndOrdersChronologically() throws {
        let early = try #require(LocalTime(hhmm: "05:07"))
        let late = try #require(LocalTime(hhmm: "23:59"))
        #expect(early < late)
        #expect(LocalTime(hhmm: "5:07") == nil)
        #expect(LocalTime(hhmm: "05-07") == nil)
    }

    @Test func codableRoundTripsAsHHMMString() throws {
        let time = try #require(LocalTime(hhmm: "09:45"))
        let data = try JSONEncoder().encode(time)
        #expect(String(decoding: data, as: UTF8.self) == "\"09:45\"")
        #expect(try JSONDecoder().decode(LocalTime.self, from: data) == time)
    }
}
