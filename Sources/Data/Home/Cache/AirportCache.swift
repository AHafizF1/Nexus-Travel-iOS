import Foundation

struct AirportCacheEntry: Equatable, Sendable {
    let airports: [Airport]
    let needsRevalidation: Bool
}

actor AirportCache {
    private struct StoredEntry: Sendable {
        let airports: [Airport]
        let storedAt: Date
    }

    static let defaultTTL: TimeInterval = 10 * 60
    private let ttl: TimeInterval
    private let clock: @Sendable () -> Date
    private var entries: [String: StoredEntry] = [:]

    init(ttl: TimeInterval = AirportCache.defaultTTL, clock: @escaping @Sendable () -> Date = Date.init) {
        self.ttl = ttl
        self.clock = clock
    }

    func entry(for key: String, now: Date? = nil) -> AirportCacheEntry? {
        guard let stored = entries[Self.normalized(key)] else { return nil }
        return AirportCacheEntry(
            airports: stored.airports,
            needsRevalidation: (now ?? clock()).timeIntervalSince(stored.storedAt) >= ttl
        )
    }

    func store(_ airports: [Airport], for key: String, at date: Date? = nil) {
        guard !airports.isEmpty else { return }
        entries[Self.normalized(key)] = StoredEntry(airports: airports, storedAt: date ?? clock())
    }

    static func key(for query: String) -> String {
        query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "popular"
            : "search:\(query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())"
    }

    private static func normalized(_ key: String) -> String {
        key.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
