import Foundation
import Testing
@testable import NexusTravel

struct AirportCacheTests {
    @Test func normalizesKeysAndExpiresAtTenMinutes() async {
        let now = Date(timeIntervalSince1970: 1_000)
        let cache = AirportCache(clock: { now })
        await cache.store([airport("ADD")], for: " SEARCH:  jFk ")
        #expect(await cache.entry(for: "search:  JFK") == AirportCacheEntry(airports: [airport("ADD")], needsRevalidation: false))
        #expect(await cache.entry(for: "search:  jfk", now: now.addingTimeInterval(600))?.needsRevalidation == true)
    }

    @Test func emptyResultsNeverReplaceCache() async {
        let cache = AirportCache(clock: { Date(timeIntervalSince1970: 0) })
        await cache.store([airport("ADD")], for: "popular")
        await cache.store([], for: "popular")
        #expect(await cache.entry(for: "popular")?.airports == [airport("ADD")])
    }

    private func airport(_ code: String) -> Airport {
        Airport(code: code, city: "City", name: "Airport", country: "Country")
    }
}
