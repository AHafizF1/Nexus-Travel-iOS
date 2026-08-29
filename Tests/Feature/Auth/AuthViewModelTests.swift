import Foundation
import Testing
@testable import NexusTravel

@MainActor
struct AuthViewModelTests {
    @Test func sessionSuccessAuthenticatesAndEmitsEvent() async throws {
        let session = makeAuthSession()
        let model = AuthViewModel(repository: StubAuthRepository(sessionResult: .success(session)))
        try await model.checkExistingSession()
        #expect(model.gateState == .authenticated(session))
        #expect(model.consumeEvent() == .authenticated(session))
        #expect(model.consumeEvent() == nil)
    }

    @Test func missingSessionShowsForms() async throws {
        let model = AuthViewModel(repository: StubAuthRepository(sessionResult: .failure(.unauthenticated)))
        try await model.checkExistingSession()
        #expect(model.gateState == .unauthenticated)
    }

    @Test func editsClearOnlyRelatedErrorsAndModeSwitches() {
        let model = AuthViewModel(repository: StubAuthRepository())
        model.updateLoginEmail("a@example.com")
        model.updateLoginPassword("password")
        model.showSignup()
        model.updateSignupName("Selam")
        model.updateSignupEmail("s@example.com")
        model.updateSignupPassword("password")
        model.updateSignupConfirmPassword("password")
        model.updateTerms(true)
        #expect(model.mode == .signup)
        #expect(model.loginState.email == "a@example.com")
        #expect(model.signupState.acceptedTerms)
        model.showLogin()
        #expect(model.mode == .login)
    }

    @Test func loginFailureUsesPresenterAndPreservesInput() async throws {
        let model = AuthViewModel(repository: StubAuthRepository(signInResult: .failure(.invalidCredentials)))
        model.updateLoginEmail(" selam@example.com ")
        model.updateLoginPassword("password123")
        try await model.submitLogin()
        #expect(model.loginState.message == "Email or password is incorrect.")
        #expect(model.loginState.email == " selam@example.com ")
        #expect(model.loginState.password == "password123")
        #expect(!model.loginState.isSubmitting)
    }

    @Test func signupRejectsPasswordMismatchWithoutRepositoryCall() async throws {
        let repository = AuthRepositorySpy()
        let model = AuthViewModel(repository: repository)
        model.updateSignupPassword("password123")
        model.updateSignupConfirmPassword("different")
        try await model.submitSignup()
        #expect(model.signupState.confirmPasswordError == "Passwords do not match.")
        #expect(await repository.signUpCallCount == 0)
    }

    @Test func loginAndSignupSuccessEmitAuthenticatedSession() async throws {
        let session = makeAuthSession()
        let login = AuthViewModel(repository: StubAuthRepository(signInResult: .success(session)))
        login.updateLoginEmail("selam@example.com")
        login.updateLoginPassword("password123")
        try await login.submitLogin()
        #expect(login.loginState.message == "Welcome back, Selam.")
        #expect(login.consumeEvent() == .authenticated(session))

        let signup = AuthViewModel(repository: StubAuthRepository(signUpResult: .success(session)))
        signup.updateSignupName("Selam Abebe")
        signup.updateSignupEmail("selam@example.com")
        signup.updateSignupPassword("password123")
        signup.updateSignupConfirmPassword("password123")
        signup.updateTerms(true)
        try await signup.submitSignup()
        #expect(signup.signupState.message == "Account ready for Selam.")
        #expect(signup.consumeEvent() == .authenticated(session))
    }

    @Test func passwordResetValidatesThenReportsBackendFailureHonestly() async throws {
        let model = AuthViewModel(repository: StubAuthRepository(resetResult: .failure(.unknown)))
        model.updateLoginEmail("bad")
        try await model.requestPasswordReset()
        #expect(model.loginState.emailError == "Please enter a valid email address.")
        model.updateLoginEmail("selam@example.com")
        try await model.requestPasswordReset()
        #expect(model.loginState.message == "Something went wrong. Please try again.")
        #expect(!model.loginState.isSuccess)
    }
}

private struct StubAuthRepository: AuthRepository {
    var signInResult: AuthResult<AuthSession> = .failure(.unknown)
    var signUpResult: AuthResult<AuthSession> = .failure(.unknown)
    var sessionResult: AuthResult<AuthSession> = .failure(.unauthenticated)
    var resetResult: AuthResult<Void> = .failure(.unknown)
    func signInEmail(request: SignInRequest) async throws -> AuthResult<AuthSession> { signInResult }
    func signUpEmail(request: SignUpRequest) async throws -> AuthResult<AuthSession> { signUpResult }
    func getSession() async throws -> AuthResult<AuthSession> { sessionResult }
    func getLocalSession() async throws -> AuthSession? { nil }
    func requestPasswordReset(email: String) async throws -> AuthResult<Void> { resetResult }
    func signOut() async throws -> AuthResult<Void> { .success(()) }
}

private actor AuthRepositorySpy: AuthRepository {
    private(set) var signUpCallCount = 0
    func signInEmail(request: SignInRequest) async throws -> AuthResult<AuthSession> { .failure(.unknown) }
    func signUpEmail(request: SignUpRequest) async throws -> AuthResult<AuthSession> {
        signUpCallCount += 1
        return .failure(.unknown)
    }
    func getSession() async throws -> AuthResult<AuthSession> { .failure(.unauthenticated) }
    func getLocalSession() async throws -> AuthSession? { nil }
    func requestPasswordReset(email: String) async throws -> AuthResult<Void> { .failure(.unknown) }
    func signOut() async throws -> AuthResult<Void> { .success(()) }
}

private func makeAuthSession() -> AuthSession {
    AuthSession(
        sessionId: "session",
        user: AuthUser(id: "user", displayName: "Selam", email: "selam@example.com", avatarUrl: nil),
        tokens: nil,
        expiresAt: Date(timeIntervalSince1970: 2_000_000_000)
    )
}
