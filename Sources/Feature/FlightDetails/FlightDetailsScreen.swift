import SwiftUI

struct FlightDetailsScreenRoute: View {
    @State private var viewModel: FlightDetailsViewModel
    @State private var eventTask: Task<Void, Never>?
    let router: Router
    let bookingFlowState: BookingFlowState
    let reference: FlightOfferReference
    init(
        viewModel: FlightDetailsViewModel,
        router: Router,
        bookingFlowState: BookingFlowState,
        reference: FlightOfferReference
    ) {
        _viewModel = State(initialValue: viewModel)
        self.router = router
        self.bookingFlowState = bookingFlowState
        self.reference = reference
    }
    var body: some View {
        FlightDetailsScreen(state: viewModel.uiState, onEvent: send)
            .task {
                bookingFlowState.selectOffer(reference)
                do { try await viewModel.load() } catch is CancellationError { return } catch { return }
            }
            .onDisappear { eventTask?.cancel() }
    }
    private func send(_ event: FlightDetailsUiEvent) {
        eventTask?.cancel()
        eventTask = Task {
            do { try await viewModel.onEvent(event) } catch is CancellationError { return } catch { return }
            route()
            eventTask = nil
        }
    }
    private func route() {
        while let event = viewModel.consumeNavigationEvent() {
            switch event {
            case .back:
                router.pop()
            case .toPassengerDetails:
                guard let details = viewModel.uiState.details,
                      bookingFlowState.acceptPassengerDetails(details) else { return }
                router.push(.passengerDetails(.init()))
            }
        }
    }
}

struct FlightDetailsScreen: View {
    let state: FlightDetailsUiState
    let onEvent: (FlightDetailsUiEvent) -> Void
    var body: some View {
        Group {
            if state.isLoading { ProgressView("Loading flight details...").frame(maxWidth: .infinity, maxHeight: .infinity) }
            else if let error = state.errorMessage { ContentUnavailableView("Could not load flight details", systemImage: "exclamationmark.triangle", description: Text(error)).overlay(alignment: .bottom) { NexusPrimaryButton("Retry") { onEvent(.retryClicked) }.padding() } }
            else if let details = state.details { content(details) }
            else { ContentUnavailableView("Flight details unavailable", systemImage: "airplane", description: Text("Choose another flight and try again.")) }
        }
        .navigationTitle("Flight Details").navigationBarBackButtonHidden().toolbar { ToolbarItem(placement: .topBarLeading) { Button("Back", systemImage: "chevron.left") { onEvent(.backClicked) } } }
        .alert("Fare changed", isPresented: .constant(state.pendingPriceChange != nil)) { Button("Review", role: .cancel) { onEvent(.dismissPriceChangeClicked) }; Button("Continue") { onEvent(.acceptPriceChangeClicked) } } message: { if let change = state.pendingPriceChange { Text("Price changed from \(change.previousPrice) to \(change.updatedPrice).") } }
    }
    private func content(_ details: FlightDetails) -> some View {
        ScrollView { VStack(alignment: .leading, spacing: NexusSpacing.space16) {
            Text(state.display?.airlineName ?? details.airline.name).nexusTextStyle(NexusText.styles.sectionTitle)
            Text(state.display?.flightMeta ?? details.flightNumber).foregroundStyle(NexusSemanticColors.textSecondary)
            ForEach(Array(details.legs.enumerated()), id: \.offset) { _, leg in VStack(alignment: .leading) { Text(leg.label).nexusTextStyle(NexusText.styles.listTitle); Text("\(leg.departureAirportCode)  \(leg.departureTime.hhmm) → \(leg.arrivalAirportCode)  \(leg.arrivalTime.hhmm)") } }
            if let warning = state.warningMessage { NexusBanner(text: warning, status: .warning) }
            disclosure("Seat selection", summary: details.seat.availabilityLabel, section: .seat)
            disclosure("Baggage Allowance", summary: "Cabin: \(details.baggage.cabin) · Checked: \(details.baggage.checked)", section: .baggage)
            disclosure("Fare Rules", summary: details.fareRules.refundableLabel, section: .fareRules)
            Text("Price details").nexusTextStyle(NexusText.styles.sectionTitle); row("Base fare", details.priceBreakdown.baseFare.formatted); row("Taxes & fees", details.priceBreakdown.taxesAndFees.formatted); row("Total", details.price.formatted)
            Text("Aircraft").nexusTextStyle(NexusText.styles.sectionTitle); Text(details.aircraft.aircraftName); Text(details.aircraft.note).foregroundStyle(NexusSemanticColors.textSecondary)
            if let message = state.actionMessage { Text(message).foregroundStyle(NexusSemanticColors.textSecondary) }
        }.padding(NexusLayout.screenMargin) }
        .safeAreaInset(edge: .bottom) { ViewThatFits(in: .horizontal) { HStack { Text(details.price.formatted).nexusTextStyle(NexusText.styles.priceAmountSmall); Spacer(); NexusPrimaryButton(state.isRevalidating ? "Confirming fare..." : "Continue", isLoading: state.isRevalidating) { onEvent(.continueClicked) } }; VStack(alignment: .leading) { Text(details.price.formatted).nexusTextStyle(NexusText.styles.priceAmountSmall); NexusPrimaryButton(state.isRevalidating ? "Confirming fare..." : "Continue", isLoading: state.isRevalidating, fillsWidth: true) { onEvent(.continueClicked) } } }.padding().background(.regularMaterial) }
    }
    private func disclosure(_ title: String, summary: String, section: FlightDetailsSection) -> some View { DisclosureGroup(isExpanded: .init(get: { state.expandedSections.contains(section) }, set: { _ in onEvent(.sectionToggled(section)) })) { Text(summary) } label: { VStack(alignment: .leading) { Text(title); Text(summary).foregroundStyle(NexusSemanticColors.textSecondary) } } }
    private func row(_ label: String, _ value: String) -> some View { ViewThatFits(in: .horizontal) { HStack { Text(label); Spacer(); Text(value) }; VStack(alignment: .leading) { Text(label); Text(value) } } }
}
