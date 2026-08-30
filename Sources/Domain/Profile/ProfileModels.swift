import Foundation

struct CustomerProfile: Equatable, Sendable { let id, name, email: String; let image, phone: String?; let travelerCount, verifiedTravelerCount, pendingTravelerCount: Int }
struct SavedTraveler: Equatable, Sendable { let id, firstName, lastName, nationality, passportNumber, passportExpiryDate, status: String; let locked: Bool }
enum ThemePreference: String, CaseIterable, Codable, Sendable { case system = "SYSTEM", light = "LIGHT", dark = "DARK" }
struct NotificationPreferences: Codable, Equatable, Sendable {
    var pushEnabled = true; var flightUpdates = true; var gateChanges = true; var checkInReminders = true; var paymentAlerts = true; var promotionalOffers = false
}
struct CustomerPreferences: Codable, Equatable, Sendable {
    var language = "en"; var currency = "INR"; var theme: ThemePreference = .system; var homeAirportCode = "ADD"; var notifications = NotificationPreferences()
}
struct AccountSecurity: Equatable, Sendable { let emailVerified: Bool; let device, createdAt, expiresAt: String }
enum AccountDeletionStatus: String, Decodable, Equatable, Sendable { case requested = "REQUESTED" }
struct AccountDeletionRequest: Decodable, Equatable, Sendable { let requestId: String; let status: AccountDeletionStatus }
enum ProfileResult<Value: Equatable & Sendable>: Equatable, Sendable { case success(Value); case authRequired, networkUnavailable, notFound, invalidInput, failed }
protocol ProfileRepository: Sendable {
    func profile() async throws -> ProfileResult<CustomerProfile>
    func updateProfile(name: String, phone: String?) async throws -> ProfileResult<CustomerProfile>
    func travelers() async throws -> ProfileResult<[SavedTraveler]>
}
protocol PreferencesRepository: Sendable {
    func local() async -> CustomerPreferences
    func refresh() async throws -> ProfileResult<CustomerPreferences>
    func save(_ preferences: CustomerPreferences) async throws -> ProfileResult<CustomerPreferences>
}
protocol AccountSecurityRepository: Sendable {
    func security() async throws -> ProfileResult<AccountSecurity>
    func deleteAccount(password: String, confirmation: String, idempotencyKey: String) async throws -> ProfileResult<AccountDeletionRequest>
}

enum ProfileValidation: Equatable, Sendable {
    case valid(name: String, phone: String?); case invalidName, invalidPhone
    static func validate(name: String, phone: String?) -> ProfileValidation {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines); let phone = phone?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (2...80).contains(name.count) else { return .invalidName }
        guard let phone, !phone.isEmpty else { return .valid(name: name, phone: nil) }
        guard phone.range(of: #"^\+[1-9]\d{7,14}$"#, options: .regularExpression) != nil else { return .invalidPhone }
        return .valid(name: name, phone: phone)
    }
}
