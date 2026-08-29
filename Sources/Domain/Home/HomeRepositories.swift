/// Loads airport choices while preserving cancellation and contract failures.
protocol AirportRepository: Sendable {
    func searchAirports(query: String) async throws -> [Airport]
}

/// Loads complete Home content while preserving cancellation.
protocol HomeRepository: Sendable {
    func getHomeContent() async throws -> HomeResult<HomeContent>
}

/// Domain outcomes presented by Home loading.
enum HomeResult<Value: Equatable & Sendable>: Equatable, Sendable {
    case success(Value)
    case networkUnavailable
    case unknownError
}
