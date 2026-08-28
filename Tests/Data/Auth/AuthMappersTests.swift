import Foundation
import Testing
@testable import NexusTravel

struct AuthMappersTests {
    @Test func tokenEnvelopeUsesBodyBeforeHeaderAndAndroidFallbacks() throws {
        let dto = try JSONDecoder().decode(AuthTokenEnvelopeDTO.self, from: AuthContractFixtures.tokenEnvelope)
        let session = try AuthMapper.session(
            from: dto,
            responseHeaderToken: "header-token",
            now: AuthContractFixtures.now
        )

        #expect(session.sessionId == "user-1")
        #expect(session.tokens?.accessToken == "body-token")
        #expect(session.tokens?.refreshToken == nil)
        #expect(session.expiresAt == AuthContractFixtures.now.addingTimeInterval(30 * 24 * 60 * 60))
    }

    @Test func blankBodyTokenFallsBackToHeaderAndMissingTokenIsUnauthenticated() throws {
        var dto = try JSONDecoder().decode(AuthTokenEnvelopeDTO.self, from: AuthContractFixtures.tokenEnvelopeWithoutToken)
        #expect(try AuthMapper.session(from: dto, responseHeaderToken: "header-token", now: .distantPast)
            .tokens?.accessToken == "header-token")

        dto = AuthTokenEnvelopeDTO(token: "  ", user: dto.user)
        #expect(throws: AuthMappingError.missingToken) {
            try AuthMapper.session(from: dto, responseHeaderToken: "\n", now: .distantPast)
        }
    }

    @Test func sessionEnvelopeUsesServerIdentityTokenAndFractionalExpiry() throws {
        let dto = try JSONDecoder().decode(AuthSessionEnvelopeDTO.self, from: AuthContractFixtures.sessionEnvelope)
        let session = try AuthMapper.session(from: dto)

        #expect(session.sessionId == "session-1")
        #expect(session.tokens?.accessToken == "session-token")
        #expect(session.expiresAt == ISO8601DateFormatter().date(from: "2026-09-04T12:00:00Z"))
    }

    @Test func additiveFieldsDecodeButMissingRequiredUserFails() throws {
        _ = try JSONDecoder().decode(AuthTokenEnvelopeDTO.self, from: AuthContractFixtures.tokenEnvelope)
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(AuthTokenEnvelopeDTO.self, from: AuthContractFixtures.tokenEnvelopeMissingUser)
        }
    }

    @Test(arguments: [
        ("INVALID_EMAIL_OR_PASSWORD", AuthError.invalidCredentials),
        ("INVALID_CREDENTIALS", AuthError.invalidCredentials),
        ("USER_ALREADY_EXISTS_USE_ANOTHER_EMAIL", AuthError.emailAlreadyUsed),
        ("USER_ALREADY_EXISTS", AuthError.emailAlreadyUsed),
        ("EMAIL_ALREADY_EXISTS", AuthError.emailAlreadyUsed),
        ("EMAIL_NOT_VERIFIED", AuthError.emailNotVerified),
        ("UNAUTHENTICATED", AuthError.unauthenticated),
        ("SESSION_EXPIRED", AuthError.sessionExpired)
    ])
    func mapsBackendErrorCodes(_ code: String, _ expected: AuthError) {
        #expect(AuthMapper.error(AuthErrorDTO(code: code, message: "message", fieldErrors: nil), statusCode: 400) == expected)
    }

    @Test func mapsValidationRateLimitAndUnknownFieldsSafely() {
        let validation = AuthErrorDTO(
            code: "VALIDATION",
            message: "invalid",
            fieldErrors: ["name": "Name", "email": "Email", "future": "Ignore"]
        )
        #expect(AuthMapper.error(validation, statusCode: 422) == .validation([.fullName: "Name", .email: "Email"]))
        #expect(AuthMapper.error(.init(code: "INVALID_EMAIL", message: "Invalid email", fieldErrors: nil), statusCode: 400)
            == .validation([.email: "Invalid email"]))
        #expect(AuthMapper.error(.init(code: "PASSWORD_TOO_SHORT", message: "Short", fieldErrors: nil), statusCode: 400)
            == .validation([.password: "Short"]))
        #expect(AuthMapper.error(.init(code: "WHATEVER", message: "x", fieldErrors: nil), statusCode: 429) == .rateLimited)
        #expect(AuthMapper.error(.init(code: "RESET_PASSWORD_DISABLED", message: "x", fieldErrors: nil), statusCode: 400) == .unknown)
    }
}
