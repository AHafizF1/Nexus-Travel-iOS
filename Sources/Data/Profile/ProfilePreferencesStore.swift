import Foundation

actor ProfilePreferencesStore {
    private let defaults: UserDefaults; private let key = "profile_preferences"
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }
    func value() -> CustomerPreferences { guard let data = defaults.data(forKey: key), let value = try? JSONDecoder().decode(CustomerPreferences.self, from: data) else { return CustomerPreferences() }; return value }
    func save(_ value: CustomerPreferences) { if let data = try? JSONEncoder().encode(value) { defaults.set(data, forKey: key) } }
}
