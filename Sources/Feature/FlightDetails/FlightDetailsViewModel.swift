import Observation

struct PriceChangeConfirmation: Equatable, Sendable { let previousPrice: String; let updatedPrice: String }
enum FlightDetailsSection: Hashable, Sendable { case seat, baggage, fareRules, details }
enum FlightDetailsUiEvent: Sendable { case backClicked, retryClicked, continueClicked, acceptPriceChangeClicked, dismissPriceChangeClicked, chooseSeatClicked, sectionToggled(FlightDetailsSection) }
enum FlightDetailsNavigationEvent: Equatable, Sendable { case back, toPassengerDetails }

struct FlightDetailsUiState: Equatable, Sendable {
    var isLoading = true
    var details: FlightDetails?
    var display: FlightDetailsDisplayModel?
    var expandedSections: Set<FlightDetailsSection> = []
    var errorMessage: String?
    var warningMessage: String?
    var actionMessage: String?
    var isRevalidating = false
    var pendingPriceChange: PriceChangeConfirmation?
}

@MainActor @Observable final class FlightDetailsViewModel {
    private(set) var uiState = FlightDetailsUiState()
    private let reference: FlightOfferReference
    private let repository: any FlightDetailsRepository
    private var navigation: [FlightDetailsNavigationEvent] = []
    init(reference: FlightOfferReference, repository: any FlightDetailsRepository) { self.reference = reference; self.repository = repository }

    func load() async throws { uiState.isLoading = true; uiState.errorMessage = nil; try await apply(awaitResult()) }
    func onEvent(_ event: FlightDetailsUiEvent) async throws {
        switch event {
        case .backClicked: navigation.append(.back)
        case .retryClicked: try await load()
        case .continueClicked:
            guard !uiState.isRevalidating else { return }; uiState.isRevalidating = true
            defer { uiState.isRevalidating = false }; try await apply(awaitResult(), continuing: true)
        case .acceptPriceChangeClicked: uiState.pendingPriceChange = nil; navigation.append(.toPassengerDetails)
        case .dismissPriceChangeClicked: uiState.pendingPriceChange = nil
        case .chooseSeatClicked: uiState.actionMessage = "Seat selection will be available before checkout."
        case let .sectionToggled(section): if uiState.expandedSections.contains(section) { uiState.expandedSections.remove(section) } else { uiState.expandedSections.insert(section) }
        }
    }
    func consumeNavigationEvent() -> FlightDetailsNavigationEvent? { navigation.isEmpty ? nil : navigation.removeFirst() }
    private func awaitResult() async throws -> FlightDetailsResult { try await repository.priceOffer(reference: reference) }
    private func apply(_ result: FlightDetailsResult, continuing: Bool = false) throws {
        try Task.checkCancellation(); uiState.isLoading = false
        switch result {
        case let .success(details): uiState.details = details; uiState.display = details.toDisplayModel(); if continuing { navigation.append(.toPassengerDetails) }
        case let .priceChanged(previous, details): uiState.details = details; uiState.warningMessage = "Price changed from \(previous.formatted) to \(details.price.formatted)."; uiState.display = details.toDisplayModel(warningMessage: uiState.warningMessage); if continuing { uiState.pendingPriceChange = .init(previousPrice: previous.formatted, updatedPrice: details.price.formatted) }
        default: uiState.errorMessage = FlightDetailsErrorPresenter.present(result: result)?.message
        }
    }
}
