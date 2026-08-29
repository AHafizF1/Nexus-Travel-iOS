/// Actor-isolated in-memory results keyed by exact backend session identifier.
actor SearchResultsCache {
    private var results: [String: SearchResultsResult] = [:]
    func store(_ result: SearchResultsResult, for searchID: String) { results[searchID] = result }
    func result(for searchID: String) -> SearchResultsResult? { results[searchID] }
}
