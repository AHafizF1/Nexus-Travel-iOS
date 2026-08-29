/// Submits validated passenger details to booking backend.
protocol PassengerDetailsRepository: Sendable {
    func submitPassengerDetails(_ request: SubmitPassengerDetailsRequest) async throws -> PassengerDetailsResult
}
