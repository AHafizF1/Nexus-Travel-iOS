import Foundation
import Observation

enum AuthEvent: Equatable, Sendable {
    case authenticated(AuthSession)
}

@MainActor
@Observable
final class AuthViewModel {
    private(set) var mode: AuthMode = .login
    private(set) var loginState = LoginUiState()
    private(set) var signupState = SignupUiState()
    private(set) var gateState: AuthGateState = .checking

    private let repository: any AuthRepository
    private var events: [AuthEvent] = []

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    func checkExistingSession() async throws {
        let previous = gateState
        gateState = .checking
        do {
            switch try await repository.getSession() {
            case let .success(session): finishAuth(.session, session: session)
            case .failure: gateState = .unauthenticated
            }
        } catch is CancellationError {
            gateState = previous
            throw CancellationError()
        }
    }

    func showLogin() { mode = .login }
    func showSignup() { mode = .signup }

    func updateLoginEmail(_ email: String) {
        loginState.email = email
        loginState.emailError = nil
        loginState.message = nil
        loginState.isSuccess = false
    }

    func updateLoginPassword(_ password: String) {
        loginState.password = password
        loginState.passwordError = nil
        loginState.message = nil
        loginState.isSuccess = false
    }

    func updateSignupName(_ fullName: String) {
        signupState.fullName = fullName
        signupState.fullNameError = nil
        signupState.message = nil
    }

    func updateSignupEmail(_ email: String) {
        signupState.email = email
        signupState.emailError = nil
        signupState.message = nil
    }

    func updateSignupPassword(_ password: String) {
        signupState.password = password
        signupState.passwordError = nil
        signupState.confirmPasswordError = nil
        signupState.message = nil
    }

    func updateSignupConfirmPassword(_ password: String) {
        signupState.confirmPassword = password
        signupState.confirmPasswordError = nil
        signupState.message = nil
    }

    func updateTerms(_ accepted: Bool) {
        signupState.acceptedTerms = accepted
        signupState.termsError = nil
        signupState.message = nil
    }

    func submitLogin() async throws {
        guard !loginState.isSubmitting else { return }
        let previous = loginState
        loginState.isSubmitting = true
        loginState.emailError = nil
        loginState.passwordError = nil
        loginState.message = nil
        do {
            let request = SignInRequest(
                email: loginState.email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: loginState.password
            )
            switch try await repository.signInEmail(request: request) {
            case let .success(session): finishAuth(.login, session: session)
            case let .failure(error): loginState = AuthErrorPresenter.loginState(from: loginState, error: error)
            }
        } catch is CancellationError {
            loginState = previous
            throw CancellationError()
        }
    }

    func submitSignup() async throws {
        guard !signupState.isSubmitting else { return }
        let previous = signupState
        signupState.isSubmitting = true
        clearSignupFeedback()
        guard signupState.password == signupState.confirmPassword else {
            signupState.isSubmitting = false
            signupState.confirmPasswordError = "Passwords do not match."
            return
        }
        do {
            let request = SignUpRequest(
                fullName: signupState.fullName,
                email: signupState.email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: signupState.password,
                acceptedTerms: signupState.acceptedTerms
            )
            switch try await repository.signUpEmail(request: request) {
            case let .success(session): finishAuth(.signup, session: session)
            case let .failure(error): signupState = AuthErrorPresenter.signupState(from: signupState, error: error)
            }
        } catch is CancellationError {
            signupState = previous
            throw CancellationError()
        }
    }

    func requestPasswordReset() async throws {
        guard !loginState.isSubmitting else { return }
        let validation = AuthValidator.validatePasswordReset(email: loginState.email)
        guard validation.isEmpty else {
            loginState.emailError = validation[.email]
            loginState.message = nil
            return
        }
        let previous = loginState
        loginState.isSubmitting = true
        loginState.emailError = nil
        loginState.message = nil
        do {
            switch try await repository.requestPasswordReset(email: loginState.email) {
            case .success:
                loginState.isSubmitting = false
                loginState.isSuccess = true
                loginState.message = "Password reset instructions sent if an account exists."
            case let .failure(error):
                loginState = AuthErrorPresenter.loginState(from: loginState, error: error)
            }
        } catch is CancellationError {
            loginState = previous
            throw CancellationError()
        }
    }

    func consumeEvent() -> AuthEvent? {
        events.isEmpty ? nil : events.removeFirst()
    }

    private func clearSignupFeedback() {
        signupState.fullNameError = nil
        signupState.emailError = nil
        signupState.passwordError = nil
        signupState.confirmPasswordError = nil
        signupState.termsError = nil
        signupState.message = nil
    }

    private func finishAuth(_ completion: AuthCompletion, session: AuthSession) {
        gateState = .authenticated(session)
        switch completion {
        case .session: break
        case .login:
            loginState.isSubmitting = false
            loginState.isSuccess = true
            loginState.message = "Welcome back, \(session.user.displayName)."
        case .signup:
            signupState.isSubmitting = false
            signupState.isSuccess = true
            signupState.message = "Account ready for \(session.user.displayName)."
        }
        events.append(.authenticated(session))
    }
}

private enum AuthCompletion {
    case session
    case login
    case signup
}
