/// Creates remote flight searches while preserving transport cancellation.
protocol FlightSearchRepository: Sendable {
    func createSearch(request: FlightSearchRequest) async throws -> FlightSearchResult
}

/// Loads results previously created for an exact search identifier.
protocol SearchResultsRepository: Sendable {
    func getSearchResults(searchId: String) async throws -> SearchResultsResult
}
