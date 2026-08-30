import Foundation

actor TripCache {
    struct Entry: Sendable { let data: Data; let fetchedAt: Date }
    private var entries: [String: Entry] = [:]
    private let clock: @Sendable () -> Date
    init(clock: @escaping @Sendable () -> Date = Date.init) { self.clock = clock }
    func fresh(key: String) -> Entry? { entry(key, maximumAge: 5 * 60) }
    func stale(key: String) -> Entry? { entry(key, maximumAge: 24 * 60 * 60) }
    func put(key: String, data: Data) { entries[key] = Entry(data: data, fetchedAt: clock()) }
    func clear() { entries.removeAll() }
    private func entry(_ key: String, maximumAge: TimeInterval) -> Entry? {
        guard let value = entries[key], clock().timeIntervalSince(value.fetchedAt) < maximumAge else { return nil }
        return value
    }
}
