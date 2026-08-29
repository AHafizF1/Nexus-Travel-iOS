/// Cache-backed search-results adapter with no duplicate network request.
struct RemoteSearchResultsRepository: SearchResultsRepository {
    let cache: SearchResultsCache
    func getSearchResults(searchId: String) async throws -> SearchResultsResult { await cache.result(for: searchId) ?? .empty }
}
