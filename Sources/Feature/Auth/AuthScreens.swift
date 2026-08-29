import SwiftUI

struct AuthRoute: View {
    @State private var viewModel: AuthViewModel
    @State private var actionTask: Task<Void, Never>?
    let onAuthenticated: () -> Void

    init(viewModel: AuthViewModel, onAuthenticated: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onAuthenticated = onAuthenticated
    }

    var body: some View {
        Group {
            if viewModel.gateState == .checking {
                ProgressView("Checking your session…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.mode == .login {
                LoginScreen(viewModel: viewModel, perform: perform)
            } else {
                SignupScreen(viewModel: viewModel, perform: perform)
            }
        }
        .task { await run { try await viewModel.checkExistingSession() } }
        .onDisappear { actionTask?.cancel() }
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
}

struct LoginScreen: View {
    @Bindable var viewModel: AuthViewModel
    let perform: (@escaping @MainActor () async throws -> Void) -> Void

    var body: some View {
        AuthScaffold(title: "Welcome back", subtitle: "Sign in to manage trips, tickets, and check-in.") {
            NexusAuthTextField(
                text: Binding(get: { viewModel.loginState.email }, set: viewModel.updateLoginEmail),
                placeholder: "Email",
                label: "Email",
                error: viewModel.loginState.emailError
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            PasswordAuthField(
                text: Binding(get: { viewModel.loginState.password }, set: viewModel.updateLoginPassword),
                label: "Password",
                error: viewModel.loginState.passwordError
            )
            Button("Forgot password?") { perform { try await viewModel.requestPasswordReset() } }
                .frame(maxWidth: .infinity, alignment: .trailing)
            AuthMessage(state: viewModel.loginState)
            NexusPrimaryButton("Sign in", isLoading: viewModel.loginState.isSubmitting, fillsWidth: true) {
                perform { try await viewModel.submitLogin() }
            }
            HStack {
                Text("Don’t have an account?")
                Button("Sign up", action: viewModel.showSignup)
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
                text: Binding(get: { viewModel.signupState.fullName }, set: viewModel.updateSignupName),
                placeholder: "Full name", label: "Full name", error: viewModel.signupState.fullNameError
            )
            .textContentType(.name)
            NexusAuthTextField(
                text: Binding(get: { viewModel.signupState.email }, set: viewModel.updateSignupEmail),
                placeholder: "Email", label: "Email", error: viewModel.signupState.emailError
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            PasswordAuthField(
                text: Binding(get: { viewModel.signupState.password }, set: viewModel.updateSignupPassword),
                label: "Password", error: viewModel.signupState.passwordError, contentType: .newPassword
            )
            PasswordAuthField(
                text: Binding(get: { viewModel.signupState.confirmPassword }, set: viewModel.updateSignupConfirmPassword),
                label: "Confirm password", error: viewModel.signupState.confirmPasswordError, contentType: .newPassword
            )
            Toggle("I agree to the terms and privacy policy.", isOn: Binding(
                get: { viewModel.signupState.acceptedTerms }, set: viewModel.updateTerms
            ))
            if let error = viewModel.signupState.termsError {
                Text(error).nexusTextStyle(NexusText.styles.errorText).foregroundStyle(NexusSemanticColors.errorText)
            }
            AuthMessage(state: viewModel.signupState)
            NexusPrimaryButton("Create account", isLoading: viewModel.signupState.isSubmitting, fillsWidth: true) {
                perform { try await viewModel.submitSignup() }
            }
            HStack {
                Text("Already have an account?")
                Button("Sign in", action: viewModel.showLogin)
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
    var contentType: UITextContentType = .password
    @State private var isVisible = false

    var body: some View {
        NexusAuthTextField(
            text: $text,
            placeholder: label,
            label: label,
            error: error,
            isSecure: !isVisible,
            leadingIcon: { Image(systemName: "lock") },
            trailingContent: {
                NexusIconButton(isVisible ? "Hide password" : "Show password") {
                    isVisible.toggle()
                } icon: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
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
