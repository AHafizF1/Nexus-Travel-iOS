import SwiftUI

struct SearchResultsScreenRoute: View {
    @State private var viewModel: SearchResultsViewModel
    @State private var eventTask: Task<Void, Never>?
    let router: Router

    init(viewModel: SearchResultsViewModel, router: Router) {
        _viewModel = State(initialValue: viewModel)
        self.router = router
    }

    var body: some View {
        SearchResultsScreen(state: viewModel.uiState, onEvent: send)
            .task {
                do { try await viewModel.loadResults() } catch is CancellationError { return } catch { return }
            }
            .onDisappear { eventTask?.cancel() }
    }

    private func send(_ event: SearchResultsUiEvent) {
        eventTask?.cancel()
        eventTask = Task {
            await viewModel.onEvent(event)
            while let navigation = viewModel.consumeNavigationEvent() {
                switch navigation {
                case .back, .toModifySearch, .toNearbyDates: router.pop()
                case let .toFlightDetails(reference):
                    router.push(.flightDetails(FlightDetailsRoute(reference: reference)))
                }
            }
            eventTask = nil
        }
    }
}

struct SearchResultsScreen: View {
    let state: SearchResultsUiState
    let onEvent: (SearchResultsUiEvent) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: NexusSpacing.space8) {
            header
            filters
            content
        }
        .background(NexusSemanticColors.backgroundPage)
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        VStack(spacing: NexusSpacing.space8) {
            HStack {
                NexusIconButton("Back") { onEvent(.backClicked) } icon: { Image(systemName: "chevron.left") }
                Text("Search Results").nexusTextStyle(NexusText.styles.sectionTitle)
                Spacer()
            }
            if let summary = state.querySummary {
                Button { onEvent(.modifyClicked) } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(summary.originCode) → \(summary.destinationCode)").nexusTextStyle(NexusText.styles.listTitle)
                            Text(summaryLine(summary)).nexusTextStyle(NexusText.styles.bodySmall)
                                .foregroundStyle(NexusSemanticColors.textSecondary)
                        }
                        Spacer()
                        Text("Edit search").nexusTextStyle(NexusText.styles.link)
                    }
                    .padding(NexusSpacing.space12)
                    .background(NexusSemanticColors.surfaceBase)
                    .clipShape(RoundedRectangle(cornerRadius: NexusRadius.lg))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Edit search: \(summary.originCode) to \(summary.destinationCode), \(summaryLine(summary))")
            }
        }
        .padding(.horizontal, NexusLayout.screenMargin)
    }

    private var filters: some View {
        ScrollView(.horizontal) {
            HStack(spacing: NexusSpacing.space8) {
                Menu {
                    ForEach([SortOption.recommended, .bestPrice, .fastest, .departureEarly], id: \.self) { option in
                        Button(option.label) { onEvent(.sortChanged(option)) }
                    }
                } label: { Text(state.sortOption.label).nexusTextStyle(NexusText.styles.label) }
                ForEach([SearchFilter.nonStop, .bestPrice, .morning, .oneStop], id: \.self) { filter in
                    Button(filter.label) { onEvent(.filterToggled(filter)) }
                        .buttonStyle(.borderedProminent)
                        .tint(state.selectedFilters.contains(filter) ? NexusSemanticColors.brandPrimary : NexusSemanticColors.surfaceMuted)
                        .foregroundStyle(state.selectedFilters.contains(filter) ? NexusSemanticColors.actionPrimaryText : NexusSemanticColors.textPrimary)
                        .accessibilityValue(state.selectedFilters.contains(filter) ? "Selected" : "Not selected")
                }
            }.padding(.horizontal, NexusLayout.screenMargin)
        }.scrollIndicators(.hidden)
    }

    @ViewBuilder private var content: some View {
        switch state.resultState {
        case .loading: loading
        case .content: results
        case .empty: empty
        case .error: error
        }
    }

    private var loading: some View {
        VStack(spacing: NexusSpacing.space16) {
            ProgressView()
            Text("Searching live fares...")
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: NexusRadius.lg).fill(NexusSemanticColors.surfaceMuted)
                    .frame(height: NexusLayout.bottomCtaMinHeight)
                    .opacity(reduceMotion ? 1 : 0.7)
            }
        }.padding(NexusLayout.screenMargin).accessibilityLabel("Searching live fares")
    }

    private var results: some View {
        ScrollView {
            LazyVStack(spacing: NexusSpacing.space0) {
                HStack {
                    Text(state.resultCountLabel()).nexusTextStyle(NexusText.styles.body)
                    Spacer()
                    Text("Taxes & fees included").nexusTextStyle(NexusText.styles.bodySmall)
                }.padding(.horizontal, NexusLayout.screenMargin)
                if !state.selectedFilters.isEmpty {
                    HStack {
                        Text("Filter applied").nexusTextStyle(NexusText.styles.label)
                        Spacer()
                        Button("Clear filters") { onEvent(.clearFiltersClicked) }
                    }.padding(NexusSpacing.space12).background(NexusSemanticColors.brandSoft)
                }
                ForEach(state.visibleFlights, id: \.id) { offer in
                    SearchResultOfferRow(offer: offer, tripType: state.querySummary?.tripType ?? .roundTrip) {
                        onEvent(.flightCardClicked(offer.reference))
                    }
                    Divider()
                }
            }
        }
    }

    private var empty: some View {
        ContentUnavailableView {
            Label("No flights found", systemImage: "magnifyingglass")
        } description: {
            Text(state.selectedFilters.isEmpty
                 ? "We couldn't find available flights for these dates. Try adjusting your search to see more options."
                 : "We couldn't find available flights for these filters. Try adjusting your search to see more options.")
        } actions: {
            NexusPrimaryButton("Try searching nearby dates", fillsWidth: true) { onEvent(.nearbyDatesClicked) }
            NexusTextButton("Modify search") { onEvent(.modifyClicked) }
        }.padding(NexusLayout.screenMargin)
    }

    private var error: some View {
        ContentUnavailableView {
            Label("Connection Lost", systemImage: "wifi.slash")
        } description: { Text(state.errorMessage ?? "Could not load flights. Please retry.") }
        actions: {
            NexusPrimaryButton("Retry Search", fillsWidth: true) { onEvent(.retryClicked) }
            NexusTextButton("Change search") { onEvent(.modifyClicked) }
        }.padding(NexusLayout.screenMargin)
    }

    private func summaryLine(_ summary: SearchResultsQuerySummary) -> String {
        let dates = summary.returnDate.map { "\(summary.departureDate.iso8601) - \($0.iso8601)" } ?? summary.departureDate.iso8601
        let oneWay = summary.tripType == .oneWay ? " · One way" : ""
        return "\(dates) · \(summary.travelers.summary()) · \(summary.cabinClass.label)\(oneWay)"
    }
}

private struct SearchResultOfferRow: View {
    let offer: SearchResultUiOffer
    let tripType: TripType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: NexusSpacing.space12) {
                HStack {
                    Text(offer.airlineCode).nexusTextStyle(NexusText.styles.airportCode)
                    VStack(alignment: .leading) {
                        Text(offer.airlineName).nexusTextStyle(NexusText.styles.listTitle)
                        Text(offer.flightNumber).nexusTextStyle(NexusText.styles.bodySmall)
                    }
                    Spacer()
                    if let badge = offer.badgeLabel { Text(badge).nexusTextStyle(NexusText.styles.statusBadge) }
                }
                ForEach(Array(offer.legs.enumerated()), id: \.offset) { index, leg in
                    HStack {
                        if tripType == .roundTrip { Text(index == 0 ? "OUT" : "RET").nexusTextStyle(NexusText.styles.statusBadge) }
                        VStack { Text(leg.departureTimeLabel).nexusTextStyle(NexusText.styles.flightTimeCompact); Text(leg.departureAirportCode) }
                        Spacer()
                        VStack { Text(leg.durationLabel); Text(leg.stopLabel) }.nexusTextStyle(NexusText.styles.durationStop)
                        Spacer()
                        VStack { Text(leg.arrivalTimeLabel).nexusTextStyle(NexusText.styles.flightTimeCompact); Text(leg.arrivalAirportCode) }
                    }
                }
                HStack {
                    if let seats = offer.seatsLeftLabel { Text(seats).nexusTextStyle(NexusText.styles.statusBadge) }
                    Spacer()
                    VStack(alignment: .trailing) {
                        if let old = offer.oldPriceLabel { Text(old).strikethrough().nexusTextStyle(NexusText.styles.bodySmall) }
                        Text(offer.priceLabel).nexusTextStyle(NexusText.styles.priceAmountSmall)
                        Text(offer.priceMetaLabel).nexusTextStyle(NexusText.styles.currencyLabel)
                    }
                    NexusIcon(name: .chevronRight)
                }
            }.padding(.horizontal, NexusLayout.screenMargin).padding(.vertical, NexusSpacing.space16)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(offer.airlineName), \(offer.flightNumber), \(offer.priceLabel) \(offer.priceMetaLabel)")
    }
}
