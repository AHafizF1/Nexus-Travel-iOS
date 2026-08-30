import Foundation

struct RemoteProfileRepository: ProfileRepository {
    private let transport: HTTPTransport; private let tokenProvider: AuthTokenProvider
    init(transport: HTTPTransport, tokenProvider: AuthTokenProvider) { self.transport = transport; self.tokenProvider = tokenProvider }
    func profile() async throws -> ProfileResult<CustomerProfile> { try await requestProfile(HTTPRequest(target: .mobile("profile"))) }
    func updateProfile(name: String, phone: String?) async throws -> ProfileResult<CustomerProfile> {
        guard case let .valid(name, phone) = ProfileValidation.validate(name: name, phone: phone) else { return .invalidInput }
        let body = try JSONEncoder().encode(UpdateProfileDTO(name: name, phone: phone)); let updated = try await authorized(HTTPRequest(target: .mobile("profile"), method: .patch, body: body))
        guard case .success = updated else { return updated.mapProfile() }; return try await profile()
    }
    func travelers() async throws -> ProfileResult<[SavedTraveler]> {
        switch try await authorized(HTTPRequest(target: .mobile("travelers"))) {
        case let .success(response): guard let dto = try? JSONDecoder().decode([TravelerDTO].self, from: response.data) else { return .failed }; return .success(dto.map(\.domain))
        case .authRequired: return .authRequired; case .networkUnavailable: return .networkUnavailable; case .notFound: return .notFound; case .invalidInput: return .invalidInput; case .failed: return .failed
        }
    }
    private func requestProfile(_ request: HTTPRequest) async throws -> ProfileResult<CustomerProfile> {
        switch try await authorized(request) {
        case let .success(response): guard let dto = try? JSONDecoder().decode(ProfileDTO.self, from: response.data) else { return .failed }; return .success(dto.domain)
        case .authRequired: return .authRequired; case .networkUnavailable: return .networkUnavailable; case .notFound: return .notFound; case .invalidInput: return .invalidInput; case .failed: return .failed
        }
    }
    private func authorized(_ request: HTTPRequest) async throws -> ProfileResult<HTTPResponse> {
        do { guard let token = try await tokenProvider.accessToken() else { return .authRequired }; let response = try await transport.send(HTTPRequest(target: request.target, queryItems: request.queryItems, method: request.method, headers: request.headers, body: request.body, authorization: .bearer(token), timeout: request.timeout)); if response.statusCode == 401 { return .authRequired }; if response.statusCode == 404 { return .notFound }; if response.statusCode == 400 || response.statusCode == 422 { return .invalidInput }; return (200..<300).contains(response.statusCode) ? .success(response) : .failed }
        catch is CancellationError { throw CancellationError() } catch HTTPTransportError.networkUnavailable, HTTPTransportError.timedOut { return .networkUnavailable } catch { return .failed }
    }
}
private struct UpdateProfileDTO: Encodable { let name: String; let phone: String? }
private struct ProfileDTO: Decodable { let user: UserDTO; let phone: String?; let travelerSummary: SummaryDTO; var domain: CustomerProfile { .init(id: user.id, name: user.name, email: user.email, image: user.image, phone: phone, travelerCount: travelerSummary.total, verifiedTravelerCount: travelerSummary.verified, pendingTravelerCount: travelerSummary.pending) } }
private struct UserDTO: Decodable { let id, name, email: String; let image: String? }; private struct SummaryDTO: Decodable { let total, verified, pending: Int }
private struct TravelerDTO: Decodable { let id, firstName, lastName, nationality, passportNumber, passportExpiryDate, status: String; let locked: Bool; var domain: SavedTraveler { .init(id: id, firstName: firstName, lastName: lastName, nationality: nationality, passportNumber: passportNumber.count <= 4 ? "••••" : "•••• \(passportNumber.suffix(4))", passportExpiryDate: passportExpiryDate, status: status, locked: locked) } }
private extension ProfileResult where Value == HTTPResponse { func mapProfile<T>() -> ProfileResult<T> { switch self { case .authRequired: .authRequired; case .networkUnavailable: .networkUnavailable; case .notFound: .notFound; case .invalidInput: .invalidInput; case .failed: .failed; case .success: .failed } } }

struct RemotePreferencesRepository: PreferencesRepository {
    private let transport: HTTPTransport; private let tokenProvider: AuthTokenProvider; private let store: ProfilePreferencesStore
    init(transport: HTTPTransport, tokenProvider: AuthTokenProvider, store: ProfilePreferencesStore) { self.transport = transport; self.tokenProvider = tokenProvider; self.store = store }
    func local() async -> CustomerPreferences { await store.value() }
    func refresh() async throws -> ProfileResult<CustomerPreferences> { try await send(nil) }
    func save(_ preferences: CustomerPreferences) async throws -> ProfileResult<CustomerPreferences> { await store.save(preferences); return try await send(preferences) }
    private func send(_ value: CustomerPreferences?) async throws -> ProfileResult<CustomerPreferences> {
        do { guard let token = try await tokenProvider.accessToken() else { return .authRequired }; let body = try value.map { try JSONEncoder().encode($0) }; let response = try await transport.send(HTTPRequest(target: .mobile("profile/preferences"), method: value == nil ? .get : .patch, body: body, authorization: .bearer(token))); guard response.statusCode != 401 else { return .authRequired }; guard (200..<300).contains(response.statusCode), let result = try? JSONDecoder().decode(CustomerPreferences.self, from: response.data) else { return .failed }; await store.save(result); return .success(result) }
        catch is CancellationError { throw CancellationError() } catch HTTPTransportError.networkUnavailable, HTTPTransportError.timedOut { return .networkUnavailable } catch { return .failed }
    }
}

struct RemoteAccountSecurityRepository: AccountSecurityRepository {
    private let transport: HTTPTransport; private let tokenProvider: AuthTokenProvider
    init(transport: HTTPTransport, tokenProvider: AuthTokenProvider) { self.transport = transport; self.tokenProvider = tokenProvider }
    func security() async throws -> ProfileResult<AccountSecurity> { do { guard let token = try await tokenProvider.accessToken() else { return .authRequired }; let response = try await transport.send(HTTPRequest(target: .mobile("profile/security"), authorization: .bearer(token))); guard response.statusCode != 401 else { return .authRequired }; guard (200..<300).contains(response.statusCode), let dto = try? JSONDecoder().decode(SecurityDTO.self, from: response.data) else { return .failed }; return .success(.init(emailVerified: dto.emailVerified, device: dto.session.device, createdAt: dto.session.createdAt, expiresAt: dto.session.expiresAt)) } catch is CancellationError { throw CancellationError() } catch HTTPTransportError.networkUnavailable, HTTPTransportError.timedOut { return .networkUnavailable } catch { return .failed } }
}
private struct SecurityDTO: Decodable { let emailVerified: Bool; let session: SessionDTO }; private struct SessionDTO: Decodable { let device, createdAt, expiresAt: String }
