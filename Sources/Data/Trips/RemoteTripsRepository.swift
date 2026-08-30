import Foundation

struct RemoteTripsRepository: TripsRepository {
    private let transport: HTTPTransport; private let tokenProvider: AuthTokenProvider
    private let cache: TripCache; private let ticketStore: TicketPdfStore
    init(transport: HTTPTransport, tokenProvider: AuthTokenProvider, cache: TripCache, ticketStore: TicketPdfStore) {
        self.transport = transport; self.tokenProvider = tokenProvider; self.cache = cache; self.ticketStore = ticketStore
    }
    func trips(group: TripGroup, forceRefresh: Bool) async throws -> TripPageState {
        let key = "trips:list:\(group.rawValue)"
        if !forceRefresh, let entry = await cache.fresh(key: key), let page = try? Self.decodePage(entry.data, offline: false, fetchedAt: entry.fetchedAt) { return .content(page, offline: false, lastUpdated: entry.fetchedAt) }
        do { return try await refreshTrips(group: group) }
        catch is CancellationError { throw CancellationError() }
        catch {
            if let entry = await cache.stale(key: key), let page = try? Self.decodePage(entry.data, offline: true, fetchedAt: entry.fetchedAt) { return .content(page, offline: true, lastUpdated: entry.fetchedAt) }
            return .error("Could not load trips.")
        }
    }
    func refreshTrips(group: TripGroup) async throws -> TripPageState {
        guard let token = try await tokenProvider.accessToken() else { return .error("Sign in to view trips.") }
        let response = try await transport.send(HTTPRequest(target: .mobile("trips"), queryItems: [.init(name: "status", value: group.rawValue), .init(name: "limit", value: "20")], authorization: .bearer(token)))
        guard response.statusCode != 401 else { return .error("Sign in again to view trips.") }
        guard (200..<300).contains(response.statusCode) else { return .error("Could not load trips.") }
        let now = Date(); let page = try Self.decodePage(response.data, offline: false, fetchedAt: now)
        await cache.put(key: "trips:list:\(group.rawValue)", data: response.data)
        return .content(page, offline: false, lastUpdated: now)
    }
    func tripDetail(id: String, forceRefresh: Bool) async throws -> TripDetailResult {
        let key = "trips:detail:\(id)"
        if !forceRefresh, let entry = await cache.fresh(key: key), let trip = try? Self.decodeTrip(entry.data, offline: false, fetchedAt: entry.fetchedAt) { return .success(trip) }
        do {
            guard let token = try await tokenProvider.accessToken() else { return .authRequired }
            let response = try await transport.send(HTTPRequest(target: .mobile("trips/\(id)"), authorization: .bearer(token)))
            if response.statusCode == 401 { return .authRequired }; if response.statusCode == 404 { return .notFound }
            guard (200..<300).contains(response.statusCode) else { return .failed }
            let trip = try Self.decodeTrip(response.data, offline: false, fetchedAt: Date()); await cache.put(key: key, data: response.data); return .success(trip)
        } catch is CancellationError { throw CancellationError() }
        catch HTTPTransportError.networkUnavailable, HTTPTransportError.timedOut {
            if let entry = await cache.stale(key: key), let trip = try? Self.decodeTrip(entry.data, offline: true, fetchedAt: entry.fetchedAt) { return .success(trip) }
            return .networkUnavailable
        } catch { return .failed }
    }
    func resolveTicketDocument(id: String) async throws -> TicketDocumentResult {
        do {
            guard let token = try await tokenProvider.accessToken() else { return .authRequired }
            let response = try await transport.send(HTTPRequest(target: .mobile("bookings/\(id)/ticket-document"), authorization: .bearer(token)))
            if response.statusCode == 401 { return .authRequired }; if response.statusCode == 404 { return .unavailable }
            guard (200..<300).contains(response.statusCode), let dto = try? JSONDecoder().decode(TicketDocumentDTO.self, from: response.data), let url = URL(string: dto.downloadUrl) else { return .unknownError }
            return .success(url)
        } catch is CancellationError { throw CancellationError() }
        catch HTTPTransportError.networkUnavailable, HTTPTransportError.timedOut { return .networkUnavailable }
        catch { return .unknownError }
    }
    func cacheTicketPdf(id: String, downloadURL: URL) async throws -> CachedTicketResult {
        do {
            let response = try await transport.send(HTTPRequest(target: .absolute(downloadURL), authorization: .none))
            guard response.statusCode == 200 else { return .networkUnavailable }
            do { return .success(try ticketStore.store(id: id, data: response.data)) } catch { return .storageUnavailable }
        } catch is CancellationError { throw CancellationError() }
        catch HTTPTransportError.networkUnavailable, HTTPTransportError.timedOut { return .networkUnavailable }
        catch { return .unknownError }
    }
    private static func decodePage(_ data: Data, offline: Bool, fetchedAt: Date) throws -> TripPage { let dto = try JSONDecoder().decode(TripPageDTO.self, from: data); return .init(items: dto.items.map { $0.domain(offline: offline, fetchedAt: fetchedAt) }, nextCursor: dto.nextCursor) }
    private static func decodeTrip(_ data: Data, offline: Bool, fetchedAt: Date) throws -> CustomerTrip { try JSONDecoder().decode(TripDTO.self, from: data).domain(offline: offline, fetchedAt: fetchedAt) }
}

private struct TripPageDTO: Decodable { let items: [TripDTO]; let nextCursor: String? }
private struct TicketDocumentDTO: Decodable { let downloadUrl: String }
private struct TripDTO: Decodable {
    let id: String; let group: TripGroup; let status, paymentStatus, paymentProofStatus, ticketingStatus: String
    let amountMinor: Int?; let currency, holdExpiresAt: String?; let ticketDocumentAvailable: Bool; let nextAction, createdAt: String; let updatedAt: String?
    let itinerary: [String: JSONValue]?; let seats: [String: JSONValue]?; let tickets: [TripTicketDTO]?
    func domain(offline: Bool, fetchedAt: Date) -> CustomerTrip {
        let origin = itinerary?["origin"]?.string ?? itinerary?["from"]?.string ?? itinerary?["departureAirport"]?.string
        let destination = itinerary?["destination"]?.string ?? itinerary?["to"]?.string ?? itinerary?["arrivalAirport"]?.string
        let segments = itinerary?["segments"]?.array?.compactMap { $0.object }.map { value in TripSegment(origin: value["origin"]?.string ?? value["from"]?.string, destination: value["destination"]?.string ?? value["to"]?.string, departureTime: value["departureTime"]?.string ?? value["departureAt"]?.string, arrivalTime: value["arrivalTime"]?.string ?? value["arrivalAt"]?.string, carrier: value["carrier"]?.string ?? value["carrierCode"]?.string ?? value["airlineCode"]?.string, flightNumber: value["flightNumber"]?.string ?? value["number"]?.string) } ?? []
        let assignments = seats?["assignments"]?.array?.compactMap { $0.object }.compactMap { value -> TripSeatAssignment? in guard let number = value["seatNumber"]?.string else { return nil }; return .init(passengerIndex: value["passengerIndex"]?.int, segmentId: value["segmentId"]?.string, seatNumber: number) } ?? []
        return CustomerTrip(id: id, group: group, status: status, paymentStatus: paymentStatus, paymentProofStatus: paymentProofStatus, ticketingStatus: ticketingStatus, amountMinor: amountMinor, currency: currency, holdExpiresAt: holdExpiresAt, ticketDocumentAvailable: ticketDocumentAvailable, nextAction: nextAction, createdAt: createdAt, updatedAt: updatedAt, itineraryLabel: origin.flatMap { a in destination.map { "\(a) to \($0)" } } ?? "Trip itinerary", segments: segments, seats: assignments, tickets: tickets?.map { .init(ticketNumber: $0.ticketNumber) } ?? [], offline: offline, fetchedAt: fetchedAt)
    }
}
private struct TripTicketDTO: Decodable { let ticketNumber: String? }
private enum JSONValue: Decodable { case string(String), number(Double), object([String: JSONValue]), array([JSONValue]), bool(Bool), null
    init(from decoder: Decoder) throws { let c = try decoder.singleValueContainer(); if c.decodeNil() { self = .null } else if let v = try? c.decode(String.self) { self = .string(v) } else if let v = try? c.decode(Int.self) { self = .number(Double(v)) } else if let v = try? c.decode(Double.self) { self = .number(v) } else if let v = try? c.decode(Bool.self) { self = .bool(v) } else if let v = try? c.decode([String: JSONValue].self) { self = .object(v) } else { self = .array(try c.decode([JSONValue].self)) } }
    var string: String? { if case let .string(v) = self { v } else { nil } }; var int: Int? { if case let .number(v) = self { Int(v) } else { nil } }; var object: [String: JSONValue]? { if case let .object(v) = self { v } else { nil } }; var array: [JSONValue]? { if case let .array(v) = self { v } else { nil } }
}
