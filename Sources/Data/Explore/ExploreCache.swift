import Foundation

actor ExploreCache {
    struct Entry: Codable, Equatable, Sendable { let data: Data; let fetchedAt: Date }
    private var entries: [String: Entry] = [:]
    private var testNow: Date?
    private let fileURL: URL
    init(now: Date? = nil, directory: URL? = nil) {
        testNow = now
        let root = directory ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        fileURL = root.appending(path: "explore-cache.json")
        if let data = try? Data(contentsOf: fileURL), let stored = try? JSONDecoder().decode([String: Entry].self, from: data) { entries = stored }
    }
    func fresh(key: String) -> Entry? { entry(key, maximumAge: 10 * 60) }
    func stale(key: String) -> Entry? { entry(key, maximumAge: 60 * 60) }
    func put(key: String, data: Data) { entries[key] = Entry(data: data, fetchedAt: currentDate); persist() }
    func setNow(_ value: Date) { testNow = value }
    private func entry(_ key: String, maximumAge: TimeInterval) -> Entry? { guard let value = entries[key], currentDate.timeIntervalSince(value.fetchedAt) < maximumAge else { return nil }; return value }
    private var currentDate: Date { testNow ?? Date() }
    private func persist() { try? FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true); if let data = try? JSONEncoder().encode(entries) { try? data.write(to: fileURL, options: .atomic) } }
}
