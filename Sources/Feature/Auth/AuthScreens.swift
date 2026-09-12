import SwiftUI

struct AuthRoute: View {
    @State private var viewModel: AuthViewModel
    @State private var actionTask: Task<Void, Never>?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let purpose: AuthPresentation?
    let onAuthenticated: () -> Void

    init(
        viewModel: AuthViewModel,
        purpose: AuthPresentation? = nil,
        onAuthenticated: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.purpose = purpose
        self.onAuthenticated = onAuthenticated
    }

    var body: some View {
        Group {
            if viewModel.gateState == .checking {
                ProgressView("Checking your session…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.mode == .login {
                LoginScreen(viewModel: viewModel, subtitle: loginSubtitle, perform: perform)
                    .transition(.opacity)
            } else {
                SignupScreen(viewModel: viewModel, perform: perform)
                    .transition(.opacity)
            }
        }
        .task {
            await run { try await viewModel.checkExistingSession() }
        }
        .onDisappear { actionTask?.cancel() }
        .interactiveDismissDisabled(viewModel.isSubmitting)
        .toolbar {
            if purpose != nil {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .disabled(viewModel.isSubmitting)
                }
            }
        }
        .animation(
            reduceMotion ? .easeOut(duration: NexusMotion.durationFastSeconds) : NexusMotion.authModeTransition,
            value: viewModel.mode
        )
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
    }

    private func perform(_ operation: @escaping @MainActor () async throws -> Void) {
        actionTask?.cancel()
        actionTask = Task { await run(operation) }
    }

    private func run(_ operation: @escaping @MainActor () async throws -> Void) async {
        do { try await operation() } catch is CancellationError { return } catch { return }
        while case .authenticated = viewModel.consumeEvent() { onAuthenticated() }
        actionTask = nil
    }

    private var loginSubtitle: String {
        switch purpose {
        case .booking:
            "Your passenger details are saved. Sign in to continue to seat selection."
        case .trips:
            "Sign in to view your trips and tickets."
        case .sessionExpired:
            "Your session expired. Sign in again to continue."
        case .profile, .none:
            "Sign in to manage trips, tickets, and check-in."
        }
    }
}

struct LoginScreen: View {
    @Bindable var viewModel: AuthViewModel
    let subtitle: String
    let perform: (@escaping @MainActor () async throws -> Void) -> Void

    var body: some View {
        AuthScaffold(title: "Welcome back", subtitle: subtitle) {
            NexusAuthTextField(
                text: Binding(
                    get: { viewModel.loginState.email },
                    set: { viewModel.updateLoginEmail($0) }
                ),
                placeholder: "Email",
                label: "Email",
                error: viewModel.loginState.emailError,
                isEnabled: !viewModel.loginState.isSubmitting
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            PasswordAuthField(
                text: Binding(
                    get: { viewModel.loginState.password },
                    set: { viewModel.updateLoginPassword($0) }
                ),
                label: "Password",
                error: viewModel.loginState.passwordError,
                isEnabled: !viewModel.loginState.isSubmitting
            )
            Text("Password reset is currently unavailable. Contact Nexus support if you cannot access your account.")
                .nexusTextStyle(NexusText.styles.bodySmall)
                .foregroundStyle(NexusSemanticColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            AuthMessage(state: viewModel.loginState)
            NexusPrimaryButton("Sign in", isLoading: viewModel.loginState.isSubmitting, loadingTitle: "Signing in…", fillsWidth: true) {
                perform { try await viewModel.submitLogin() }
            }
            HStack {
                Text("Don’t have an account?")
                Button("Sign up") { viewModel.showSignup() }
                    .disabled(viewModel.loginState.isSubmitting)
            }
            .nexusTextStyle(NexusText.styles.body)
        }
    }
}

struct SignupScreen: View {
    @Bindable var viewModel: AuthViewModel
    let perform: (@escaping @MainActor () async throws -> Void) -> Void

    var body: some View {
        AuthScaffold(title: "Create your account", subtitle: "Book faster, manage trips, and keep every journey in one place.") {
            NexusAuthTextField(
                text: Binding(
                    get: { viewModel.signupState.fullName },
                    set: { viewModel.updateSignupName($0) }
                ),
                placeholder: "Full name", label: "Full name", error: viewModel.signupState.fullNameError,
                isEnabled: !viewModel.signupState.isSubmitting
            )
            .textContentType(.name)
            NexusAuthTextField(
                text: Binding(
                    get: { viewModel.signupState.email },
                    set: { viewModel.updateSignupEmail($0) }
                ),
                placeholder: "Email", label: "Email", error: viewModel.signupState.emailError,
                isEnabled: !viewModel.signupState.isSubmitting
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            PasswordAuthField(
                text: Binding(
                    get: { viewModel.signupState.password },
                    set: { viewModel.updateSignupPassword($0) }
                ),
                label: "Password", error: viewModel.signupState.passwordError,
                isEnabled: !viewModel.signupState.isSubmitting, contentType: .newPassword
            )
            PasswordAuthField(
                text: Binding(
                    get: { viewModel.signupState.confirmPassword },
                    set: { viewModel.updateSignupConfirmPassword($0) }
                ),
                label: "Confirm password", error: viewModel.signupState.confirmPasswordError,
                isEnabled: !viewModel.signupState.isSubmitting, contentType: .newPassword
            )
            Toggle("I agree to the terms and privacy policy.", isOn: Binding(
                get: { viewModel.signupState.acceptedTerms },
                set: { viewModel.updateTerms($0) }
            ))
            .disabled(viewModel.signupState.isSubmitting)
            if let error = viewModel.signupState.termsError {
                Text(error).nexusTextStyle(NexusText.styles.errorText).foregroundStyle(NexusSemanticColors.errorText)
            }
            AuthMessage(state: viewModel.signupState)
            NexusPrimaryButton("Create account", isLoading: viewModel.signupState.isSubmitting, loadingTitle: "Creating account…", fillsWidth: true) {
                perform { try await viewModel.submitSignup() }
            }
            HStack {
                Text("Already have an account?")
                Button("Sign in") { viewModel.showLogin() }
                    .disabled(viewModel.signupState.isSubmitting)
            }
            .nexusTextStyle(NexusText.styles.body)
        }
    }
}

private struct AuthScaffold<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: NexusSpacing.space16) {
                Text("Nexus Travel").nexusTextStyle(NexusText.styles.sectionTitle)
                    .foregroundStyle(NexusSemanticColors.brandPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text(title).nexusTextStyle(NexusText.styles.displayHeroCompact)
                    .multilineTextAlignment(.center)
                Text(subtitle).nexusTextStyle(NexusText.styles.body)
                    .foregroundStyle(NexusSemanticColors.textSecondary)
                    .multilineTextAlignment(.center)
                content
            }
            .frame(maxWidth: NexusLayout.formMaxWidth)
            .padding(.horizontal, NexusLayout.screenMargin)
            .padding(.vertical, NexusSpacing.space32)
            .frame(maxWidth: .infinity)
        }
        .background(NexusSemanticColors.backgroundPage)
        .scrollDismissesKeyboard(.interactively)
    }
}

private struct PasswordAuthField: View {
    @Binding var text: String
    let label: String
    let error: String?
    var isEnabled = true
    var contentType: UITextContentType = .password
    @State private var isVisible = false

    var body: some View {
        NexusAuthTextField(
            text: $text,
            placeholder: label,
            label: label,
            error: error,
            isEnabled: isEnabled,
            isSecure: !isVisible,
            leadingIcon: { NexusPlatformIcon(.password) },
            trailingContent: {
                NexusIconButton(isVisible ? "Hide password" : "Show password") {
                    isVisible.toggle()
                } icon: {
                    NexusPlatformIcon(isVisible ? .revealedPassword : .concealedPassword)
                }
            }
        )
        .textContentType(contentType)
    }
}

private struct AuthMessage: View {
    let text: String?
    let isSuccess: Bool

    init(state: LoginUiState) { text = state.message; isSuccess = state.isSuccess }
    init(state: SignupUiState) { text = state.message; isSuccess = state.isSuccess }

    var body: some View {
        if let text {
            Text(text)
                .nexusTextStyle(isSuccess ? NexusText.styles.body : NexusText.styles.errorText)
                .foregroundStyle(isSuccess ? NexusSemanticColors.successText : NexusSemanticColors.errorText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
