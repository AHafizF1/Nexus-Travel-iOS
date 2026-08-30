import Foundation

actor TripCache {
    struct Entry: Sendable { let data: Data; let fetchedAt: Date }
    private var entries: [String: Entry] = [:]
    private var testNow: Date?
    init(now: Date? = nil) { testNow = now }
    func fresh(key: String) -> Entry? { entry(key, maximumAge: 5 * 60) }
    func stale(key: String) -> Entry? { entry(key, maximumAge: 24 * 60 * 60) }
    func put(key: String, data: Data) { entries[key] = Entry(data: data, fetchedAt: currentDate) }
    func setNow(_ value: Date) { testNow = value }
    func clear() { entries.removeAll() }
    private func entry(_ key: String, maximumAge: TimeInterval) -> Entry? {
        guard let value = entries[key], currentDate.timeIntervalSince(value.fetchedAt) < maximumAge else { return nil }
        return value
    }
    private var currentDate: Date { testNow ?? Date() }
}
