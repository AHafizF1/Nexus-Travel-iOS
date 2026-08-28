/// Editable state shown by the login flow.
public struct LoginUiState: Equatable, Sendable {
    /// Current email input.
    public var email: String
    /// Current password input.
    public var password: String
    /// Email field error, when present.
    public var emailError: String?
    /// Password field error, when present.
    public var passwordError: String?
    /// Flow-level feedback message, when present.
    public var message: String?
    /// Whether a submission is active.
    public var isSubmitting: Bool
    /// Whether the latest operation succeeded.
    public var isSuccess: Bool

    /// Creates login UI state.
    public init(
        email: String = "",
        password: String = "",
        emailError: String? = nil,
        passwordError: String? = nil,
        message: String? = nil,
        isSubmitting: Bool = false,
        isSuccess: Bool = false
    ) {
        self.email = email
        self.password = password
        self.emailError = emailError
        self.passwordError = passwordError
        self.message = message
        self.isSubmitting = isSubmitting
        self.isSuccess = isSuccess
    }
}

/// Editable state shown by the signup flow.
public struct SignupUiState: Equatable, Sendable {
    /// Current full-name input.
    public var fullName: String
    /// Current email input.
    public var email: String
    /// Current password input.
    public var password: String
    /// Current password-confirmation input.
    public var confirmPassword: String
    /// Whether required terms are accepted.
    public var acceptedTerms: Bool
    /// Full-name field error, when present.
    public var fullNameError: String?
    /// Email field error, when present.
    public var emailError: String?
    /// Password field error, when present.
    public var passwordError: String?
    /// Password-confirmation field error, when present.
    public var confirmPasswordError: String?
    /// Terms field error, when present.
    public var termsError: String?
    /// Flow-level feedback message, when present.
    public var message: String?
    /// Whether a submission is active.
    public var isSubmitting: Bool
    /// Whether the latest operation succeeded.
    public var isSuccess: Bool

    /// Creates signup UI state.
    public init(
        fullName: String = "",
        email: String = "",
        password: String = "",
        confirmPassword: String = "",
        acceptedTerms: Bool = false,
        fullNameError: String? = nil,
        emailError: String? = nil,
        passwordError: String? = nil,
        confirmPasswordError: String? = nil,
        termsError: String? = nil,
        message: String? = nil,
        isSubmitting: Bool = false,
        isSuccess: Bool = false
    ) {
        self.fullName = fullName
        self.email = email
        self.password = password
        self.confirmPassword = confirmPassword
        self.acceptedTerms = acceptedTerms
        self.fullNameError = fullNameError
        self.emailError = emailError
        self.passwordError = passwordError
        self.confirmPasswordError = confirmPasswordError
        self.termsError = termsError
        self.message = message
        self.isSubmitting = isSubmitting
        self.isSuccess = isSuccess
    }
}

/// Authentication form currently shown to the user.
public enum AuthMode: Equatable, Sendable {
    /// Login form is active.
    case login
    /// Signup form is active.
    case signup
}

/// Startup authentication-gate state.
public enum AuthGateState: Equatable, Sendable {
    /// Existing-session check is running.
    case checking
    /// No existing authenticated session is available.
    case unauthenticated
    /// Existing authenticated session is available.
    case authenticated(AuthSession)
}
