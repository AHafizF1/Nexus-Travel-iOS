import Foundation
import Testing
@testable import NexusTravel

struct ExploreCacheTests {
    @Test func cachePersistsAcrossRecreationWithExactWindows() async throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        let start = Date(timeIntervalSince1970: 1_000)
        let first = ExploreCache(now: start, directory: directory)
        await first.put(key: "explore:home", data: Data("home".utf8))

        let recreated = ExploreCache(now: start.addingTimeInterval(10 * 60 - 1), directory: directory)
        #expect(await recreated.fresh(key: "explore:home")?.data == Data("home".utf8))
        await recreated.setNow(start.addingTimeInterval(10 * 60))
        #expect(await recreated.fresh(key: "explore:home") == nil)
        #expect(await recreated.stale(key: "explore:home")?.data == Data("home".utf8))
        await recreated.setNow(start.addingTimeInterval(60 * 60))
        #expect(await recreated.stale(key: "explore:home") == nil)
    }
}
