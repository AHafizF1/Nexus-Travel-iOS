import Foundation
import Testing
@testable import NexusTravel

struct TripCacheTests {
    @Test func freshAndStaleWindowsMatchAndroid() async {
        var now = Date(timeIntervalSince1970: 0)
        let cache = TripCache(clock: { now })
        await cache.put(key: "k", data: Data([1]))
        now = Date(timeIntervalSince1970: 299); #expect(await cache.fresh(key: "k") != nil)
        now = Date(timeIntervalSince1970: 301); #expect(await cache.fresh(key: "k") == nil); #expect(await cache.stale(key: "k") != nil)
        now = Date(timeIntervalSince1970: 86_401); #expect(await cache.stale(key: "k") == nil)
    }
}
