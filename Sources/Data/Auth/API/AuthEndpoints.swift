/// Better Auth routes exposed from API root.
enum AuthEndpoints {
    static let signInEmail = "/api/auth/sign-in/email"
    static let signUpEmail = "/api/auth/sign-up/email"
    static let session = "/api/auth/get-session"
    static let passwordResetRequest = "/api/auth/request-password-reset"
    static let signOut = "/api/auth/sign-out"
}
