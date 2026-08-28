import Foundation

/// Wall-clock time without date or time-zone state.
struct LocalTime: Equatable, Hashable, Codable, Sendable, Comparable {
    /// Hour in `0...23`.
    let hour: Int
    /// Minute in `0...59`.
    let minute: Int

    /// Creates time when hour and minute are valid.
    init?(hour: Int, minute: Int) {
        guard (0...23).contains(hour), (0...59).contains(minute) else { return nil }
        self.hour = hour
        self.minute = minute
    }

    /// Parses exact `HH:mm` time.
    init?(hhmm: String) {
        let parts = hhmm.split(separator: ":", omittingEmptySubsequences: false)
        guard hhmm.count == 5, parts.count == 2, parts[0].count == 2, parts[1].count == 2,
              let hour = Int(parts[0]), let minute = Int(parts[1]) else { return nil }
        self.init(hour: hour, minute: minute)
    }

    /// Stable `HH:mm` representation.
    var hhmm: String { String(format: "%02d:%02d", hour, minute) }

    /// Orders times by hour then minute.
    static func < (lhs: LocalTime, rhs: LocalTime) -> Bool {
        (lhs.hour, lhs.minute) < (rhs.hour, rhs.minute)
    }

    /// Encodes time as one `HH:mm` string.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(hhmm)
    }

    /// Decodes time from one valid `HH:mm` string.
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard let time = LocalTime(hhmm: value) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected valid HH:mm time")
        }
        self = time
    }
}
