import Foundation
import Testing
@testable import NexusTravel

struct ProfilePreferencesStoreTests {
    @Test func preferencesPersistAcrossStoreRecreation() async throws {
        let suite = "profile-\(UUID())"; try #require(UserDefaults(suiteName: suite)).removePersistentDomain(forName: suite)
        let first = ProfilePreferencesStore(suiteName: suite)
        let expected = CustomerPreferences(theme: .dark, homeAirportCode: "DXB", notifications: .init(promotionalOffers: true))
        await first.save(expected)
        #expect(await ProfilePreferencesStore(suiteName: suite).value() == expected)
    }
}
