import SwiftUI
import UserNotifications

struct ProfileScreenRoute: View {
    @State private var viewModel: ProfileViewModel; let router: Router
    init(viewModel: ProfileViewModel, router: Router) { _viewModel = State(initialValue: viewModel); self.router = router }
    var body: some View { ProfileScreen(state: viewModel.state, router: router, onLogout: viewModel.requestLogout, onSignIn: { router.beginMainAuth(returningTo: .profile) }).task { try? await viewModel.load() }.refreshable { try? await viewModel.load() }.confirmationDialog("Log out?", isPresented: Binding(get: { viewModel.state.showLogoutConfirmation }, set: { if !$0 { viewModel.dismissLogout() } })) { Button("Log out", role: .destructive) { Task { try? await viewModel.signOut() } }; Button("Cancel", role: .cancel) {} } message: { Text("You will need to sign in again to access trips and saved details.") } }
}
private struct ProfileScreen: View {
    let state: ProfileUiState; let router: Router; let onLogout, onSignIn: () -> Void
    var body: some View { List { Section { Text("Profile").nexusTextStyle(NexusText.styles.screenTitle) }; content }.listStyle(.insetGrouped).navigationBarHidden(true) }
    @ViewBuilder private var content: some View {
        switch state.access {
        case .loading: ProgressView().accessibilityLabel("Loading profile")
        case .guest: ContentUnavailableView("Your travel account", systemImage: "person.crop.circle", description: Text("Sign in to manage trips, tickets, verified travelers, and preferences.")); Button("Sign in", action: onSignIn)
        case let .recoverableError(profile): if let profile { header(profile) }; ContentUnavailableView("Profile could not refresh.", systemImage: "wifi.exclamationmark")
        case let .authenticated(profile): header(profile); Section("Account") { row("Saved travelers", "person.2") { router.push(.savedTravelers(.init())) }; LabeledContent("Payment methods", value: "Coming later") }; Section("Preferences") { row("Settings", "gearshape") { router.push(.settings(.init())) }; row("Notifications", "bell") { router.push(.notificationSettings(.init())) }; row("Security", "lock") { router.push(.security(.init())) } }; Section { Button("Log out", role: .destructive, action: onLogout) }
        }
    }
    private func header(_ profile: CustomerProfile) -> some View { Section { HStack { Text(initials(profile.name)).font(.title.bold()).frame(width: 72, height: 72).foregroundStyle(.white).background(NexusSemanticColors.brandPrimary, in: Circle()); VStack(alignment: .leading) { Text(profile.name).nexusTextStyle(NexusText.styles.sectionTitle); Text(profile.email).nexusTextStyle(NexusText.styles.bodySmall); Text("\(profile.verifiedTravelerCount) verified travelers").nexusTextStyle(NexusText.styles.caption); Button("Edit profile") { router.push(.editProfile(.init())) } } } } }
    private func row(_ title: String, _ icon: String, subtitle: String? = nil, action: @escaping () -> Void) -> some View { Button(action: action) { Label { VStack(alignment: .leading) { Text(title); if let subtitle { Text(subtitle).font(.caption).foregroundStyle(.secondary) } } } icon: { Image(systemName: icon).accessibilityHidden(true) } } }
}

struct EditProfileScreen: View {
    @State private var viewModel: EditProfileViewModel
    init(viewModel: EditProfileViewModel) { _viewModel = State(initialValue: viewModel) }
    var body: some View { Form { TextField("Full name", text: Binding(get: { viewModel.state.name }, set: viewModel.name)); TextField("Email", text: .constant(viewModel.state.email)).disabled(true); TextField("Phone", text: Binding(get: { viewModel.state.phone }, set: viewModel.phone)).keyboardType(.phonePad); if let error = viewModel.state.error { Text(error).foregroundStyle(NexusSemanticColors.errorText) }; Button(viewModel.state.saved ? "Saved" : "Save changes") { Task { try? await viewModel.save() } }.disabled(viewModel.state.loading || viewModel.state.saving) }.navigationTitle("Edit profile").task { try? await viewModel.load() } }
}

struct SavedTravelersScreen: View { let travelers: [SavedTraveler]; var body: some View { List { if travelers.isEmpty { ContentUnavailableView("No saved travelers yet.", systemImage: "person.2") } else { ForEach(travelers, id: \.id) { traveler in VStack(alignment: .leading) { Text("\(traveler.firstName) \(traveler.lastName)"); Text("\(traveler.nationality) · \(traveler.passportNumber)").font(.subheadline).foregroundStyle(.secondary); Text(humanizeProfile(traveler.status)).font(.caption).foregroundStyle(NexusSemanticColors.brandPrimary) } } } }.navigationTitle("Saved travelers") } }

struct SettingsScreen: View {
    @Bindable var viewModel: PreferencesViewModel; let router: Router
    var body: some View { Form { Section("Preferences") { LabeledContent("Language", value: "English"); LabeledContent("Currency", value: "INR"); NavigationLink("Theme", value: AppRoute.theme(.init())); NavigationLink("Home airport", value: AppRoute.homeAirport(.init())) }; Section("Notifications") { NavigationLink("Notification preferences", value: AppRoute.notificationSettings(.init())) }; if let error = viewModel.state.error { Text(error).foregroundStyle(.secondary) } }.navigationTitle("Settings").task { try? await viewModel.load() } }
}
struct ThemeScreen: View { @Bindable var viewModel: PreferencesViewModel; var body: some View { Form { Picker("Theme", selection: Binding(get: { viewModel.state.value.theme }, set: { value in var next = viewModel.state.value; next.theme = value; Task { try? await viewModel.save(next) } })) { ForEach(ThemePreference.allCases, id: \.self) { Text(humanizeProfile($0.rawValue)).tag($0) } } }.navigationTitle("Theme") } }
struct NotificationSettingsScreen: View {
    @Bindable var viewModel: PreferencesViewModel
    var body: some View { Form { Text("Choose which updates Nexus may send when notification delivery becomes available."); notificationToggle("Push notifications", .push); notificationToggle("Flight updates", .flight); notificationToggle("Gate changes", .gate); notificationToggle("Check-in reminders", .checkIn); notificationToggle("Payment alerts", .payment); notificationToggle("Promotional offers", .promotional) }.navigationTitle("Notifications") }
    private func notificationToggle(_ title: String, _ kind: NotificationKind) -> some View {
        Toggle(title, isOn: Binding(get: { kind.value(in: viewModel.state.value.notifications) }, set: { enabled in Task { if enabled && kind == .push { let allowed = (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])) == true; guard allowed else { return } }; var next = viewModel.state.value; kind.set(enabled, in: &next.notifications); try? await viewModel.save(next) } })).disabled(kind != .push && !viewModel.state.value.notifications.pushEnabled)
    }
}
struct SecurityScreen: View { @State private var viewModel: AccountSecurityViewModel; let router: Router; init(viewModel: AccountSecurityViewModel, router: Router) { _viewModel = State(initialValue: viewModel); self.router = router }; var body: some View { Form { Section("Current session") { LabeledContent("Signed-in device", value: viewModel.state.value?.device ?? "Loading"); LabeledContent("Email verification", value: viewModel.state.value?.emailVerified == true ? "Verified" : "Not verified") }; Section("Password") { Text("Password reset is currently unavailable. Contact Nexus support if you cannot access your account.") }; Section("Account") { Button("Delete account", role: .destructive) { router.push(.deleteAccount(.init())) } }; if let error = viewModel.state.error { Text(error).foregroundStyle(NexusSemanticColors.errorText) } }.navigationTitle("Security").task { try? await viewModel.load() } } }
struct HomeAirportScreen: View { @Bindable var viewModel: PreferencesViewModel; let airports: any AirportRepository; @State private var query = ""; @State private var results: [Airport] = []; var body: some View { List { TextField("Search airport or city", text: $query); ForEach(results, id: \.code) { airport in Button { var next = viewModel.state.value; next.homeAirportCode = airport.code; Task { try? await viewModel.save(next) } } label: { HStack { VStack(alignment: .leading) { Text(airport.name); Text("\(airport.city), \(airport.country)").font(.caption) }; Spacer(); Text(airport.code) } } } }.navigationTitle("Home airport").task(id: query) { results = (try? await airports.searchAirports(query: query)) ?? [] } } }
private func initials(_ name: String) -> String { name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined().uppercased().isEmpty ? "N" : name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined().uppercased() }
private func humanizeProfile(_ value: String) -> String { value.replacingOccurrences(of: "_", with: " ").lowercased().capitalized }
private enum NotificationKind: Equatable {
    case push, flight, gate, checkIn, payment, promotional
    func value(in value: NotificationPreferences) -> Bool { switch self { case .push: value.pushEnabled; case .flight: value.flightUpdates; case .gate: value.gateChanges; case .checkIn: value.checkInReminders; case .payment: value.paymentAlerts; case .promotional: value.promotionalOffers } }
    func set(_ enabled: Bool, in value: inout NotificationPreferences) { switch self { case .push: value.pushEnabled = enabled; case .flight: value.flightUpdates = enabled; case .gate: value.gateChanges = enabled; case .checkIn: value.checkInReminders = enabled; case .payment: value.paymentAlerts = enabled; case .promotional: value.promotionalOffers = enabled } }
}
