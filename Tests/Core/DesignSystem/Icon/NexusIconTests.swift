import SwiftUI
import Testing
@testable import NexusTravel

@Suite("Nexus icon catalog")
struct NexusIconTests {
    @Test("Catalog mirrors all Android icon names")
    func catalogMirrorsAndroidNames() {
        let expectedNames = [
            "home", "search", "trips", "profile", "more", "back", "close",
            "chevronDown", "chevronRight", "share", "download", "wallet", "calendar",
            "filter", "sort", "flight", "flightDeparture", "flightArrival", "hotel", "car",
            "map", "location", "seat", "seatAlt", "seatSide", "armchair", "baggage",
            "boardingPass", "ticket", "qr", "gate", "payment", "shield", "headset", "chat",
            "phone", "email", "help", "check", "info", "warning", "error", "clock",
            "offline", "loading", "bell", "tag", "refund", "continue", "arrowsExchange"
        ]

        #expect(NexusIconName.allCases.count == 51)
        #expect(NexusIconName.allCases.map(\.rawValue) == expectedNames)
        #expect(Set(NexusIconName.allCases.map(\.rawValue)).count == 51)
    }

    @Test("Every icon has one nonempty native symbol mapping")
    func everyIconHasOneNativeMapping() {
        let mappings = NexusIconName.allCases.map(\.systemName)

        #expect(mappings.allSatisfy { !$0.isEmpty })
        #expect(mappings.count == 51)
    }

    @Test("Icons construct decorative and labeled forms")
    @MainActor
    func iconsConstructDecorativeAndLabeledForms() {
        _ = NexusIcon(name: .flight)
        _ = NexusIcon(name: .flight, accessibilityLabel: "Flight")
    }
}
