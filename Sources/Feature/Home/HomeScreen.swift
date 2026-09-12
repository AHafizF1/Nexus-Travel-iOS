import SwiftUI
import UIKit

enum HomeScreenKind: Equatable { case loading, content, empty, error }

struct HomeScreenState: Equatable {
    let kind: HomeScreenKind
    init(state: HomeUiState) {
        kind = switch state.loadPhase {
        case .loading: .loading
        case .content: .content
        case .empty: .empty
        case .error: .error
        }
    }
}

struct HomeHeroMetrics: Equatable {
    let heroHeight: CGFloat
    let greetingToLauncherGap: CGFloat
    let launcherToSearchGap: CGFloat
    let headerTopPadding: CGFloat
    let imageLift: CGFloat
    let bottomFadeHeight: CGFloat
    let cardPadding: CGFloat

    init(spacing: NexusAdaptiveSpacing?) {
        switch spacing?.mode ?? .regular {
        case .compact:
            (heroHeight, greetingToLauncherGap, launcherToSearchGap, headerTopPadding, imageLift, bottomFadeHeight, cardPadding) = (220, 24, 28, 12, 64, 72, 16)
        case .regular:
            (heroHeight, greetingToLauncherGap, launcherToSearchGap, headerTopPadding, imageLift, bottomFadeHeight, cardPadding) = (248, 28, 32, 12, 80, 88, 20)
        case .spacious:
            (heroHeight, greetingToLauncherGap, launcherToSearchGap, headerTopPadding, imageLift, bottomFadeHeight, cardPadding) = (272, 32, 32, 12, 88, 96, 24)
        }
    }
}

struct HomeRoute: View {
    @State private var viewModel: HomeViewModel
    @State private var airportQueryTask: Task<Void, Never>?
    @State private var searchTask: Task<Void, Never>?
    @State private var reloadTask: Task<Void, Never>?
    @State private var eventTask: Task<Void, Never>?
    let router: Router

    init(viewModel: HomeViewModel, router: Router) {
        _viewModel = State(initialValue: viewModel)
        self.router = router
    }

    var body: some View {
        HomeScreen(
            state: viewModel.uiState,
            today: viewModel.currentDate,
            onEvent: send,
            onExplore: { router.select(.explore) },
            onRetry: retry
        )
            .task { await viewModel.retry() }
            .onDisappear {
                airportQueryTask?.cancel()
                viewModel.cancelAirportSearch()
                searchTask?.cancel()
                reloadTask?.cancel()
                eventTask?.cancel()
            }
    }

    private func retry() {
        reloadTask?.cancel()
        reloadTask = Task {
            await viewModel.retry()
            reloadTask = nil
        }
    }

    private func send(_ event: HomeUiEvent) {
        if event.usesAirportTask {
            airportQueryTask?.cancel()
            airportQueryTask = Task { await perform(event) }
        } else if event == .searchClicked || event.isSearchPrefill {
            guard searchTask == nil else { return }
            searchTask = Task {
                await perform(event)
                searchTask = nil
            }
        } else {
            eventTask?.cancel()
            eventTask = Task {
                await perform(event)
                eventTask = nil
            }
        }
    }

    private func perform(_ event: HomeUiEvent) async {
        await viewModel.onEvent(event)
        while let navigation = viewModel.consumeNavigationEvent() {
            switch navigation {
            case let .toSearchResults(searchId): router.push(.searchResults(SearchResultsRoute(searchId: searchId)))
            case .toPackages:
                router.select(.explore)
                router.push(.explore(ExploreRoute(filter: .packages)))
            }
        }
    }
}

struct HomeScreen: View {
    let state: HomeUiState
    let today: LocalDate
    let onEvent: (HomeUiEvent) -> Void
    let onExplore: () -> Void
    let onRetry: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geometry in
            let spacing = NexusAdaptiveSpacing(screenWidth: geometry.size.width, screenHeight: geometry.size.height)
            let metrics = HomeHeroMetrics(spacing: spacing)
            let screenMargin = spacing?.screenMargin ?? NexusLayout.screenMargin
            ZStack(alignment: .top) {
                NexusSemanticColors.backgroundPage.ignoresSafeArea()
                heroBackground(metrics).ignoresSafeArea(edges: .top)
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        header.padding(.top, metrics.headerTopPadding)
                        serviceLauncher
                            .padding(.top, metrics.greetingToLauncherGap)
                        if state.selectedService == .flight {
                            searchPanel(cardPadding: metrics.cardPadding)
                                .padding(.top, metrics.launcherToSearchGap)
                                .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                        }
                        stateSection.padding(.top, metrics.launcherToSearchGap)
                        if !state.recentSearches.isEmpty { recentSearches.padding(.top, NexusSpacing.space24) }
                    }
                    .padding(.horizontal, screenMargin)
                    .padding(.bottom, NexusSpacing.space32)
                    .frame(maxWidth: NexusLayout.contentMaxWidth)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .animation(
            reduceMotion ? NexusMotion.reducedHomeServiceTransition : NexusMotion.homeServiceTransition,
            value: state.selectedService
        )
        .sheet(item: Binding(get: { state.activeSheet }, set: { if $0 == nil { onEvent(.dismissSheet) } })) { sheet in
            HomeSheetView(sheet: sheet, state: state, today: today, onEvent: onEvent)
                .presentationDragIndicator(.visible)
                .presentationBackground(NexusSemanticColors.surfaceBase)
                .presentationCornerRadius(NexusRadius.xxxl)
        }
    }

    private func heroBackground(_ metrics: HomeHeroMetrics) -> some View {
        Group {
            if let path = Bundle.main.path(forResource: "home_hero_flight_wing", ofType: "png"),
               let image = UIImage(contentsOfFile: path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: metrics.heroHeight + metrics.imageLift, alignment: .topTrailing)
                    .offset(y: -metrics.imageLift)
            }
        }
        .frame(height: metrics.heroHeight, alignment: .top)
        .clipped()
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .black, location: 0),
                    .init(color: .black, location: 1 - metrics.bottomFadeHeight / metrics.heroHeight),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .accessibilityHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: NexusSpacing.space2) {
            (Text("Hi, ") + Text(state.userName).foregroundStyle(NexusSemanticColors.brandPrimary))
                .nexusTextStyle(NexusText.styles.displayHeroCompact)
                .lineLimit(2)
            Text("Where to next?").nexusTextStyle(NexusText.styles.screenTitle)
                .fontWeight(.regular)
                .foregroundStyle(NexusSemanticColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var serviceLauncher: some View {
        HStack(spacing: NexusSpacing.space8) {
            serviceButton("Flight", icon: .flight, selected: state.selectedService == .flight) { onEvent(.flightClicked) }
            serviceButton("Hotel", icon: .hotel) { onEvent(.hotelClicked) }
            serviceButton("Package", icon: .baggage) { onEvent(.packageClicked) }
        }
        .padding(NexusSpacing.space16)
        .background(NexusSemanticColors.surfaceBase)
        .clipShape(RoundedRectangle(cornerRadius: NexusRadius.xxl))
        .overlay { RoundedRectangle(cornerRadius: NexusRadius.xxl).stroke(NexusSemanticColors.borderSubtle) }
    }

    private func serviceButton(_ label: String, icon: NexusIconName, selected: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: NexusSpacing.space8) {
                NexusIcon(name: icon)
                Text(label).nexusTextStyle(NexusText.styles.label)
            }
            .padding(.horizontal, NexusSpacing.space8)
            .padding(.vertical, NexusSpacing.space12)
            .foregroundStyle(selected ? NexusSemanticColors.brandPrimary : NexusSemanticColors.textPrimary)
            .frame(
                maxWidth: .infinity,
                minHeight: NexusLayout.touchRecommended + NexusSpacing.space24,
                maxHeight: NexusLayout.touchRecommended + NexusSpacing.space24
            )
            .background(selected ? NexusSemanticColors.surfaceActive : NexusSemanticColors.surfaceBase)
            .clipShape(RoundedRectangle(cornerRadius: NexusRadius.md))
            .overlay {
                RoundedRectangle(cornerRadius: NexusRadius.md)
                    .stroke(selected ? NexusSemanticColors.borderFocus : NexusSemanticColors.borderSubtle,
                            lineWidth: NexusBorder.hairline)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func searchPanel(cardPadding: CGFloat) -> some View {
        VStack(spacing: NexusSpacing.space16) {
            tripTypeSelector
            if let error = state.validationError { message(error.message, error: true) }
            if let status = state.message, state.loadPhase != .error { message(status, error: false) }
            if state.tripType == .multiCity { multiCityFields } else { standardFields }
            HStack(spacing: NexusSpacing.space12) {
                field("Travelers", state.travelers.summary(), .profile, .travelersClicked, showsChevron: true)
                verticalDivider
                field("Cabin Class", state.cabinClass.label, .seat, .cabinClassClicked, showsChevron: true)
            }
            NexusPrimaryButton("Search Flights", isLoading: state.isSearching, fillsWidth: true) { onEvent(.searchClicked) }
        }
        .padding(cardPadding)
        .background(NexusSemanticColors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: NexusRadius.xxxl))
        .shadow(color: NexusSemanticColors.textPrimary.opacity(0.14), radius: NexusSpacing.space8, y: NexusSpacing.space4)
    }

    private var tripTypeSelector: some View {
        HStack(spacing: 0) {
            tripTypeButton("One Way", type: .oneWay)
            tripTypeButton("Round Trip", type: .roundTrip)
            tripTypeButton("Multi-city", type: .multiCity)
        }
        .padding(NexusSpacing.space4)
        .frame(height: NexusLayout.touchRecommended)
        .background(NexusSemanticColors.surfaceBase)
        .clipShape(RoundedRectangle(cornerRadius: NexusRadius.xl))
        .overlay { RoundedRectangle(cornerRadius: NexusRadius.xl).stroke(NexusSemanticColors.borderDefault) }
        .shadow(color: NexusSemanticColors.textPrimary.opacity(0.12), radius: NexusSpacing.space4, y: NexusSpacing.space2)
    }

    private func tripTypeButton(_ title: String, type: TripType) -> some View {
        Button { onEvent(.tripTypeChanged(type)) } label: {
            Text(title)
                .nexusTextStyle(NexusText.styles.label)
                .foregroundStyle(state.tripType == type ? NexusSemanticColors.actionPrimaryText : NexusSemanticColors.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    if state.tripType == type {
                        LinearGradient(
                            colors: [NexusColors.blue600, NexusColors.blue700],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: NexusRadius.lg))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(state.tripType == type ? .isSelected : [])
    }

    private var standardFields: some View {
        VStack(spacing: NexusSpacing.space16) {
            HStack {
                field("From", state.origin?.displayName ?? "Select origin", .flightDeparture, .originClicked)
                Button { onEvent(.swapAirportsClicked) } label: { NexusIcon(name: .arrowsExchange, accessibilityLabel: "Swap origin and destination") }
                    .frame(width: NexusLayout.touchRecommended, height: NexusLayout.touchRecommended)
                    .background(NexusSemanticColors.surfaceBase)
                    .clipShape(Circle())
                    .overlay { Circle().stroke(NexusSemanticColors.borderDefault) }
                    .shadow(color: NexusSemanticColors.textPrimary.opacity(0.12), radius: NexusSpacing.space4, y: NexusSpacing.space2)
                field("To", state.destination?.displayName ?? "Select destination", .flightArrival, .destinationClicked)
            }
            Divider().overlay(NexusSemanticColors.borderDefault)
            HStack(spacing: NexusSpacing.space12) {
                field("Departure", state.departureDate?.displayText ?? "Select date", .calendar, .departureDateClicked)
                if state.tripType == .roundTrip {
                    verticalDivider
                    field("Return", state.returnDate?.displayText ?? "Select date", .calendar, .returnDateClicked)
                }
            }
            Divider().overlay(NexusSemanticColors.borderDefault)
        }
    }

    private var verticalDivider: some View {
        Rectangle()
            .fill(NexusSemanticColors.borderDefault)
            .frame(width: NexusBorder.hairline, height: NexusLayout.touchRecommended)
    }

    private var multiCityFields: some View {
        VStack(spacing: NexusSpacing.space16) {
            ForEach(Array(state.multiCityLegs.enumerated()), id: \.offset) { index, leg in
                VStack(alignment: .leading, spacing: NexusSpacing.space8) {
                    HStack { Text("Flight \(index + 1)").nexusTextStyle(NexusText.styles.label); Spacer(); if state.multiCityLegs.count > 2 { Button("Remove") { onEvent(.removeMultiCityLeg(index: index)) }.foregroundStyle(NexusSemanticColors.errorText) } }
                    HStack { field("From", leg.origin?.displayName ?? "Select origin", .flightDeparture, .multiCityOriginClicked(index: index)); field("To", leg.destination?.displayName ?? "Select destination", .flightArrival, .multiCityDestinationClicked(index: index)) }
                    field("Departure", leg.departureDate?.displayText ?? "Select date", .calendar, .multiCityDateClicked(index: index))
                }
            }
            if state.multiCityLegs.count < 3 { Button("+ Add flight") { onEvent(.addMultiCityLeg) }.frame(minHeight: NexusLayout.touchRecommended) }
            if state.multiCityLegs.adjacentDatesContainSameDay {
                Text("Same-day flights may need extra connection time.")
                    .nexusTextStyle(NexusText.styles.bodySmall)
                    .foregroundStyle(NexusSemanticColors.textSecondary)
            }
        }
    }

    private func field(
        _ label: String,
        _ value: String,
        _ icon: NexusIconName,
        _ event: HomeUiEvent,
        showsChevron: Bool = false
    ) -> some View {
        Button { onEvent(event) } label: {
            VStack(alignment: .leading, spacing: NexusSpacing.space2) {
                HStack(spacing: NexusSpacing.space12) {
                    NexusIcon(name: icon)
                    Text(label).nexusTextStyle(NexusText.styles.label)
                        .foregroundStyle(NexusSemanticColors.textSecondary)
                    if showsChevron {
                        Spacer(minLength: 0)
                        NexusIcon(name: .chevronDown)
                    }
                }
                Text(value)
                    .nexusTextStyle(NexusText.styles.formInput)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
            }.frame(maxWidth: .infinity, minHeight: NexusLayout.inputHeight, alignment: .leading)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label), \(value)")
        .accessibilityHint(fieldError(for: label)?.message ?? "")
    }

    @ViewBuilder private var stateSection: some View {
        switch HomeScreenState(state: state).kind {
        case .loading:
            HStack { ProgressView(); Text("Loading travel ideas…") }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Loading travel ideas")
        case .error:
            VStack(alignment: .leading, spacing: NexusSpacing.space12) {
                message(state.message ?? "We could not load your home page. Please try again.", error: false)
                NexusSecondaryButton("Retry", fillsWidth: true, action: onRetry)
            }
        case .empty:
            ContentUnavailableView("No trending escapes yet", systemImage: NexusIconName.map.systemName,
                                   description: Text("Search for a flight or check again later."))
        case .content:
            trending
        }
    }

    private var trending: some View {
        VStack(alignment: .leading, spacing: NexusSpacing.space12) {
            HStack { Text("Trending Escapes").nexusTextStyle(NexusText.styles.screenTitle); Spacer(); Button("View all", action: onExplore) }
            ScrollView(.horizontal) {
                HStack(spacing: NexusSpacing.space16) {
                    ForEach(state.trendingEscapes, id: \.id) { escape in
                        Button { onEvent(.trendingEscapeClicked(escape)) } label: {
                            VStack(alignment: .leading, spacing: NexusSpacing.space8) {
                                AsyncImage(url: URL(string: escape.imageName)) { image in image.resizable().scaledToFill() } placeholder: { NexusSemanticColors.surfaceMuted }
                                    .frame(width: NexusLayout.contentMaxWidth / 3, height: NexusLayout.buttonHeight * 2).clipped()
                                    .accessibilityLabel(escape.airport.displayName)
                                Text(escape.airport.displayName).nexusTextStyle(NexusText.styles.listTitle)
                                Text(escape.tags.joined(separator: " · ")).nexusTextStyle(NexusText.styles.caption).foregroundStyle(NexusSemanticColors.textSecondary)
                            }.frame(width: NexusLayout.contentMaxWidth / 3)
                        }.buttonStyle(.plain)
                    }
                }
            }.scrollIndicators(.hidden)
        }
    }

    private var recentSearches: some View {
        VStack(alignment: .leading, spacing: NexusSpacing.space8) {
            Text("Recent Searches").nexusTextStyle(NexusText.styles.screenTitle)
            ScrollView(.horizontal) { HStack { ForEach(state.recentSearches, id: \.id) { search in Button("\(search.originCode) → \(search.destinationCode)\n\(search.dateRange)") { onEvent(.recentSearchClicked(search)) }.buttonStyle(.bordered) } } }.scrollIndicators(.hidden)
        }
    }

    private func message(_ text: String, error: Bool) -> some View {
        Label(text, systemImage: NexusIconName.info.systemName)
            .nexusTextStyle(error ? NexusText.styles.errorText : NexusText.styles.bodySmall)
            .foregroundStyle(error ? NexusSemanticColors.errorText : NexusSemanticColors.textPrimary)
            .padding(NexusSpacing.space12).frame(maxWidth: .infinity, alignment: .leading)
            .background(error ? NexusSemanticColors.errorBg : NexusSemanticColors.brandSoft)
            .clipShape(RoundedRectangle(cornerRadius: NexusRadius.md))
    }

    private func fieldError(for label: String) -> HomeValidationError? {
        switch (label, state.validationError) {
        case ("From", .missingOrigin), ("From", .sameOriginDestination): state.validationError
        case ("To", .missingDestination), ("To", .sameOriginDestination): state.validationError
        case ("Departure", .missingDepartureDate), ("Departure", .departureDateInPast): state.validationError
        case ("Return", .missingReturnDate), ("Return", .returnBeforeDeparture): state.validationError
        default: nil
        }
    }
}

private struct HomeSheetView: View {
    let sheet: HomeSheet
    let state: HomeUiState
    let today: LocalDate
    let onEvent: (HomeUiEvent) -> Void

    @ViewBuilder var body: some View {
        switch sheet {
        case .originAirport, .destinationAirport, .multiCityOrigin, .multiCityDestination:
            AirportSelectorSheet(state: state, onEvent: onEvent)
        case .departureDate: DateSelectorSheet(title: "Select departure", selected: state.departureDate, minimum: today) { onEvent(.departureDateSelected($0)) }
        case .returnDate: DateSelectorSheet(title: "Select return", selected: state.returnDate, minimum: state.departureDate?.addingDays(1)) { onEvent(.returnDateSelected($0)) }
        case let .multiCityDate(index): DateSelectorSheet(title: "Select date for Flight \(index + 1)", selected: state.multiCityLegs[safe: index]?.departureDate, minimum: state.multiCityLegs[safe: index - 1]?.departureDate ?? today) { onEvent(.multiCityDateSelected(index: index, date: $0)) }
        case .travelers: TravelerSelectorSheet(state: state, onEvent: onEvent)
        case .cabinClass:
            CabinClassSheet(selected: state.cabinClass, onEvent: onEvent)
        case .hotelComingSoon:
            VStack(alignment: .leading, spacing: NexusSpacing.space16) { Text("Hotels are coming soon").nexusTextStyle(NexusText.styles.sectionTitle); Text("We’re working on hotel booking. For now, you can search flights and explore travel packages."); NexusPrimaryButton("Got it", fillsWidth: true) { onEvent(.dismissSheet) } }.padding(NexusSpacing.space24)
        }
    }
}

private struct AirportSelectorSheet: View {
    let state: HomeUiState
    let onEvent: (HomeUiEvent) -> Void
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                if state.airports.isEmpty { ContentUnavailableView(state.airportQuery.isEmpty ? "No airports available." : "No airports found.", systemImage: NexusIconName.search.systemName, description: Text(state.airportQuery.isEmpty ? "Try again in a moment." : "Try city, country, or airport code.")) }
                ForEach(state.airports, id: \.code) { airport in
                    Button { onEvent(.airportSelected(airport)) } label: {
                        HStack(spacing: NexusSpacing.space20) {
                            Text(airport.code)
                                .nexusTextStyle(NexusText.styles.sectionTitle)
                                .foregroundStyle(NexusSemanticColors.brandPrimary)
                                .frame(width: NexusSpacing.space64, alignment: .leading)
                            VStack(alignment: .leading, spacing: NexusSpacing.space2) {
                                Text(airport.city).nexusTextStyle(NexusText.styles.listTitle)
                                Text("\(airport.name) · \(airport.country)").nexusTextStyle(NexusText.styles.bodySmall).foregroundStyle(NexusSemanticColors.textSecondary)
                            }
                            Spacer()
                            if selectedAirportCode == airport.code { NexusIcon(name: .check, accessibilityLabel: "Selected") }
                        }
                        .padding(.vertical, NexusSpacing.space16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
                }
                .padding(.horizontal, NexusSpacing.space24)
            }
            .navigationTitle("Select airport")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: Binding(get: { state.airportQuery }, set: { onEvent(.airportQueryChanged($0)) }), prompt: "Search city or airport")
        }
    }

    private var selectedAirportCode: String? {
        switch state.activeSheet {
        case .originAirport: state.origin?.code
        case .destinationAirport: state.destination?.code
        case let .multiCityOrigin(index): state.multiCityLegs[safe: index]?.origin?.code
        case let .multiCityDestination(index): state.multiCityLegs[safe: index]?.destination?.code
        default: nil
        }
    }
}

private struct DateSelectorSheet: View {
    let title: String
    let selected: LocalDate?
    let minimum: LocalDate?
    let onSelect: (LocalDate) -> Void
    @State private var draft: Date
    init(title: String, selected: LocalDate?, minimum: LocalDate?, onSelect: @escaping (LocalDate) -> Void) {
        self.title = title; self.selected = selected; self.minimum = minimum; self.onSelect = onSelect
        _draft = State(initialValue: (selected ?? minimum)?.foundationDate ?? Date())
    }
    var body: some View {
        let earliestDate = minimum?.foundationDate ?? Calendar(identifier: .gregorian).startOfDay(for: Date())
        VStack(spacing: NexusSpacing.space16) {
            Text(title).nexusTextStyle(NexusText.styles.sectionTitle).frame(maxWidth: .infinity, alignment: .leading)
            DatePicker(title, selection: $draft, in: earliestDate..., displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding(NexusSpacing.space12)
                .overlay { RoundedRectangle(cornerRadius: NexusRadius.xxl).stroke(NexusSemanticColors.borderSubtle) }
            NexusPrimaryButton("Select date", fillsWidth: true) { if let date = LocalDate(date: draft) { onSelect(date) } }
        }.padding(NexusSpacing.space24)
    }
}

private struct TravelerSelectorSheet: View {
    let onEvent: (HomeUiEvent) -> Void
    @State private var adults: Int
    @State private var children: Int
    @State private var infants: Int
    @State private var childAges: [Int]
    @State private var infantAges: [Int]
    init(state: HomeUiState, onEvent: @escaping (HomeUiEvent) -> Void) {
        self.onEvent = onEvent
        _adults = State(initialValue: state.travelers.adults)
        _children = State(initialValue: state.travelers.children)
        _infants = State(initialValue: state.travelers.infants)
        _childAges = State(initialValue: (0..<state.travelers.children).map { state.childAges[safe: $0] ?? 2 })
        _infantAges = State(initialValue: (0..<state.travelers.infants).map { state.infantAges[safe: $0] ?? 0 })
    }
    var body: some View {
        VStack(alignment: .leading, spacing: NexusSpacing.space24) {
            Text("Travelers").nexusTextStyle(NexusText.styles.sectionTitle)
            travelerRow("Adults", detail: "Age 12+", value: $adults, range: 1...TravelerCounts.maxTravelers)
            travelerRow("Children", detail: "Age 2–11", value: $children, range: 0...TravelerCounts.maxTravelers)
                .onChange(of: children) { _, count in childAges = (0..<count).map { childAges[safe: $0] ?? 2 } }
            travelerRow("Infants", detail: "Under 2", value: $infants, range: 0...TravelerCounts.maxTravelers)
                .onChange(of: infants) { _, count in infantAges = (0..<count).map { infantAges[safe: $0] ?? 0 } }
            ForEach(childAges.indices, id: \.self) { index in
                Stepper("Child \(index + 1) age: \(childAges[index])", value: $childAges[index], in: 2...11)
            }
            ForEach(infantAges.indices, id: \.self) { index in
                Stepper("Infant \(index + 1) age: \(infantAges[index])", value: $infantAges[index], in: 0...1)
            }
            NexusPrimaryButton("Apply", fillsWidth: true) {
                onEvent(.travelersChanged(
                    TravelerCounts(adults: adults, children: children, infants: infants),
                    childAges: childAges,
                    infantAges: infantAges
                ))
            }
        }
        .padding(NexusSpacing.space24)
    }

    private func travelerRow(
        _ title: String,
        detail: String,
        value: Binding<Int>,
        range: ClosedRange<Int>
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: NexusSpacing.space2) {
                Text(title).nexusTextStyle(NexusText.styles.listTitle)
                Text(detail).nexusTextStyle(NexusText.styles.bodySmall).foregroundStyle(NexusSemanticColors.textSecondary)
            }
            Spacer()
            Stepper(value: value, in: range) {
                Text(value.wrappedValue.formatted()).nexusTextStyle(NexusText.styles.formInput)
                    .frame(minWidth: NexusSpacing.space32)
            }
            .fixedSize()
        }
    }
}

private struct CabinClassSheet: View {
    let selected: CabinClass
    let onEvent: (HomeUiEvent) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: NexusSpacing.space12) {
            Text("Cabin class").nexusTextStyle(NexusText.styles.sectionTitle)
            ForEach(CabinClass.allCases, id: \.self) { cabin in
                Button { onEvent(.cabinClassChanged(cabin)) } label: {
                    HStack {
                        Text(cabin.label).nexusTextStyle(NexusText.styles.listTitle)
                        Spacer()
                        if cabin == selected { NexusIcon(name: .check, accessibilityLabel: "Selected") }
                    }
                    .padding(NexusSpacing.space16)
                    .frame(maxWidth: .infinity, minHeight: NexusLayout.buttonHeight)
                    .background(cabin == selected ? NexusSemanticColors.surfaceActive : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: NexusRadius.lg))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(NexusSpacing.space24)
    }
}

private extension HomeValidationError {
    var message: String { switch self { case .missingOrigin: "Select where you are flying from."; case .missingDestination: "Select where you are flying to."; case .sameOriginDestination: "Origin and destination must be different."; case .missingDepartureDate: "Select a departure date."; case .missingReturnDate: "Select a return date."; case .returnBeforeDeparture: "Return date must be after departure date."; case .departureDateInPast: "Departure date must be today or later."; case .invalidMultiCityLegs: "Complete each flight with different airports and dates in order." } }
}

private extension HomeUiEvent {
    var isSearchPrefill: Bool {
        switch self {
        case .trendingEscapeClicked, .recentSearchClicked: true
        default: false
        }
    }

    var usesAirportTask: Bool {
        switch self {
        case .airportQueryChanged, .originClicked, .destinationClicked,
             .multiCityOriginClicked, .multiCityDestinationClicked:
            true
        default:
            false
        }
    }
}

private extension Array where Element == MultiCityLegUiState {
    var adjacentDatesContainSameDay: Bool {
        zip(self, dropFirst()).contains { first, second in
            first.departureDate != nil && first.departureDate == second.departureDate
        }
    }
}

private extension TripType { static var allCases: [TripType] { [.oneWay, .roundTrip, .multiCity] } }
private extension CabinClass { static var allCases: [CabinClass] { [.economy, .premiumEconomy, .business, .first] } }
private extension LocalDate {
    var foundationDate: Date { Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast }
    init?(date: Date) { let parts = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: date); guard let year = parts.year, let month = parts.month, let day = parts.day else { return nil }; self.init(year: year, month: month, day: day) }
    var displayText: String { foundationDate.formatted(.dateTime.month(.abbreviated).day().year()) }
}
private extension Array { subscript(safe index: Int) -> Element? { indices.contains(index) ? self[index] : nil } }
