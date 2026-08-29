/// Result of an authentication repository operation.
enum AuthResult<Value: Sendable>: Sendable {
    case success(Value)
    case failure(AuthError)
}

/// Email authentication and persisted-session boundary.
protocol AuthRepository: Sendable {
    func signInEmail(request: SignInRequest) async throws -> AuthResult<AuthSession>
    func signUpEmail(request: SignUpRequest) async throws -> AuthResult<AuthSession>
    func getSession() async throws -> AuthResult<AuthSession>
    func getLocalSession() async throws -> AuthSession?
    func requestPasswordReset(email: String) async throws -> AuthResult<Void>
    func signOut() async throws -> AuthResult<Void>
}
