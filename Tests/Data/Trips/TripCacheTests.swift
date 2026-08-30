import Foundation
import Testing
@testable import NexusTravel

struct TripCacheTests {
    @Test func freshAndStaleWindowsMatchAndroid() async {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        let cache = TripCache(now: Date(timeIntervalSince1970: 0), directory: directory)
        await cache.put(key: "k", data: Data([1]))
        await cache.setNow(Date(timeIntervalSince1970: 299)); #expect(await cache.fresh(key: "k") != nil)
        await cache.setNow(Date(timeIntervalSince1970: 301)); #expect(await cache.fresh(key: "k") == nil); #expect(await cache.stale(key: "k") != nil)
        await cache.setNow(Date(timeIntervalSince1970: 86_401)); #expect(await cache.stale(key: "k") == nil)
    }

    @Test func cacheSurvivesRepositoryRecreation() async {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        let first = TripCache(now: Date(timeIntervalSince1970: 0), directory: directory)
        await first.put(key: "k", data: Data([1, 2]))
        let restored = TripCache(now: Date(timeIntervalSince1970: 1), directory: directory)
        #expect(await restored.fresh(key: "k")?.data == Data([1, 2]))
    }
}
