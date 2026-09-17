import SwiftUI

struct ExploreScreenRoute: View {
    @State private var viewModel: ExploreViewModel
    @Binding var rootScrollTarget: String?
    @Bindable var router: Router

    init(viewModel: ExploreViewModel, router: Router, rootScrollTarget: Binding<String?>) {
        _viewModel = State(initialValue: viewModel)
        _rootScrollTarget = rootScrollTarget
        self.router = router
    }

    var body: some View {
        ExploreScreen(
            state: viewModel.state,
            filter: $router.exploreFilter,
            rootScrollTarget: $rootScrollTarget,
            onDestination: { router.push(.destinationDetail(.init(destinationId: $0))) },
            onPackage: { router.push(.packageDetail(.init(packageId: $0))) },
            onRetry: { Task { try? await viewModel.load(forceRefresh: true) } }
        )
        .task { try? await viewModel.loadIfNeeded() }
        .refreshable { try? await viewModel.load(forceRefresh: true) }
    }
}

private struct ExploreScreen: View {
    let state: ExploreUiState
    @Binding var filter: ExploreFilter
    @Binding var rootScrollTarget: String?
    let onDestination, onPackage: (String) -> Void
    let onRetry: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: NexusSpacing.space16) {
                Text("Explore")
                    .nexusTextStyle(NexusText.styles.screenTitle)
                    .accessibilityAddTraits(.isHeader)
                    .id("explore.header")

                if state.loading && state.content == nil {
                    ProgressView().frame(maxWidth: .infinity).accessibilityLabel("Loading Explore")
                } else if let content = state.content {
                    if state.refreshing {
                        Label("Refreshing deals…", systemImage: NexusIconName.loading.systemName)
                            .accessibilityAddTraits(.updatesFrequently)
                    }
                    if state.error != nil {
                        Label("Could not update. Showing last available deals.", systemImage: NexusPlatformIconName.unavailableNetwork.rawValue)
                    }
                    Picker("Explore filter", selection: $filter) {
                        Text("All").tag(ExploreFilter.all)
                        Text("Packages").tag(ExploreFilter.packages)
                        Text("Destinations").tag(ExploreFilter.destinations)
                    }
                    .pickerStyle(.segmented)
                    .id("explore.filter")
                    exploreContent(content)
                } else {
                    ContentUnavailableView(
                        "We couldn’t load Explore.",
                        systemImage: NexusPlatformIconName.unavailableNetwork.rawValue,
                        description: Text(state.error ?? "Try again.")
                    )
                    Button("Try again", action: onRetry)
                }
            }
            .padding(NexusSpacing.space16)
            .scrollTargetLayout()
        }
        .scrollPosition(id: $rootScrollTarget, anchor: .top)
        .accessibilityIdentifier("root-explore")
        .background(NexusSemanticColors.backgroundPage)
    }

    @ViewBuilder
    private func exploreContent(_ content: ExploreContent) -> some View {
        let packages = filter.showsPackages ? content.packages : []
        let destinations = filter.showsDestinations ? content.destinations : []

        if packages.isEmpty && destinations.isEmpty {
            ContentUnavailableView(
                "No travel deals available right now.",
                systemImage: NexusIconName.map.systemName,
                description: Text("Check again later or refresh.")
            )
        }
        if !packages.isEmpty {
            Text("Popular from Addis Ababa")
                .nexusTextStyle(NexusText.styles.sectionTitle)
                .id("explore.packages")
            ForEach(packages, id: \.id) { item in
                ExploreCard(title: item.title, summary: item.summary, imageURL: item.imageUrl) {
                    onPackage(item.id)
                }
                .id("explore.package.\(item.id)")
            }
        }
        if !destinations.isEmpty {
            Text("Browse destinations")
                .nexusTextStyle(NexusText.styles.sectionTitle)
                .id("explore.destinations")
            ForEach(destinations, id: \.id) { item in
                ExploreCard(title: item.title, summary: item.summary, imageURL: item.imageUrl) {
                    onDestination(item.id)
                }
                .id("explore.destination.\(item.id)")
            }
        }
    }
}
private struct ExploreCard: View { let title, summary: String; let imageURL: String?; let action: () -> Void; var body: some View { Button(action: action) { VStack(alignment: .leading, spacing: NexusSpacing.space8) { if let imageURL, let url = URL(string: imageURL) { AsyncImage(url: url) { image in image.resizable().scaledToFill() } placeholder: { Rectangle().fill(NexusSemanticColors.surfaceMuted) }.frame(maxWidth: .infinity, minHeight: NexusSpacing.space64 * 2).clipped().accessibilityHidden(true) }; Text(title).nexusTextStyle(NexusText.styles.sectionTitleSmall); Text(summary).nexusTextStyle(NexusText.styles.bodySmall).foregroundStyle(.secondary); Text("View details").foregroundStyle(NexusSemanticColors.brandPrimary) }.frame(maxWidth: .infinity, alignment: .leading) }.buttonStyle(.plain).accessibilityElement(children: .combine).accessibilityAddTraits(.isButton) } }

struct ExploreDetailScreenRoute: View {
    @State private var viewModel: ExploreDetailViewModel; let mode: Mode; let onSearchFlights: (String) -> Void
    enum Mode { case destination(String), package(String) }
    init(viewModel: ExploreDetailViewModel, mode: Mode, onSearchFlights: @escaping (String) -> Void) { _viewModel = State(initialValue: viewModel); self.mode = mode; self.onSearchFlights = onSearchFlights }
    var body: some View { Group { switch viewModel.state { case .loading: ProgressView().accessibilityLabel("Loading details"); case let .destination(destination, packages): detail(destination, eyebrow: nil, packages: packages); case let .package(package, destination): detail(destination, eyebrow: package.title, packages: [package]); case .unavailable: ContentUnavailableView("This destination is unavailable.", systemImage: NexusIconName.map.systemName); case .error: ContentUnavailableView("Could not load details.", systemImage: NexusPlatformIconName.unavailableNetwork.rawValue) } }.task { switch mode { case let .destination(id): try? await viewModel.loadDestination(id: id); case let .package(id): try? await viewModel.loadPackage(id: id) } } }
    private func detail(_ destination: ExploreDestination, eyebrow: String?, packages: [ExplorePackage]) -> some View { ScrollView { VStack(alignment: .leading, spacing: NexusSpacing.space16) { if let image = destination.gallery.first ?? destination.imageUrl, let url = URL(string: image) { AsyncImage(url: url) { $0.resizable().scaledToFill() } placeholder: { Rectangle().fill(NexusSemanticColors.surfaceMuted) }.frame(maxWidth: .infinity, minHeight: NexusSpacing.space64 * 3).clipped().accessibilityLabel("\(destination.title) destination image") }; if let eyebrow { Text(eyebrow).foregroundStyle(NexusSemanticColors.brandPrimary) }; Text(destination.title).nexusTextStyle(NexusText.styles.screenTitle); Text(destination.country).foregroundStyle(.secondary); Text("About \(destination.title)").nexusTextStyle(NexusText.styles.sectionTitle); Text(destination.summary); if !destination.highlights.isEmpty { Text("Highlights").nexusTextStyle(NexusText.styles.sectionTitle); ForEach(destination.highlights, id: \.self) { Label($0, systemImage: NexusIconName.location.systemName) } }; if !packages.isEmpty { Text("Related deals").nexusTextStyle(NexusText.styles.sectionTitle); ForEach(packages, id: \.id) { Text($0.title) } }; Button("Search flights") { if let code = destination.airportCode { onSearchFlights(code) } }.buttonStyle(.borderedProminent).disabled(destination.airportCode == nil) }.padding(NexusSpacing.space16) }.navigationTitle(destination.title).navigationBarTitleDisplayMode(.inline) }
}
