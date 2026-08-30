import Foundation
import Testing
@testable import NexusTravel

struct ProfilePreferencesStoreTests {
    @Test func preferencesPersistAcrossStoreRecreation() async throws {
        let suite = "profile-\(UUID())"; let defaults = try #require(UserDefaults(suiteName: suite)); defaults.removePersistentDomain(forName: suite)
        let first = ProfilePreferencesStore(defaults: defaults)
        let expected = CustomerPreferences(theme: .dark, homeAirportCode: "DXB", notifications: .init(promotionalOffers: true))
        await first.save(expected)
        #expect(await ProfilePreferencesStore(defaults: defaults).value() == expected)
    }
}
