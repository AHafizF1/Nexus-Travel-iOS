import QuickLook
import SwiftUI

struct TripsScreenRoute: View {
    @State private var viewModel: TripsViewModel; let router: Router
    init(viewModel: TripsViewModel, router: Router) { _viewModel = State(initialValue: viewModel); self.router = router }
    var body: some View {
        TripsScreen(state: viewModel.state, onSelect: { group in Task { try? await viewModel.select(group) } }, onOpen: { router.push(.tripDetail(.init(tripId: $0))) }, onUpload: { router.push(.paymentProof(.init(bookingId: $0))) }, onSignIn: { router.beginMainAuth(returningTo: .trips) })
            .task { try? await viewModel.load() }.refreshable { try? await viewModel.load(forceRefresh: true) }
    }
}

private struct TripsScreen: View {
    let state: TripsUiState; let onSelect: (TripGroup) -> Void; let onOpen, onUpload: (String) -> Void; let onSignIn: () -> Void
    var body: some View {
        ScrollView { LazyVStack(alignment: .leading, spacing: NexusSpacing.space20) {
            Text("Trips").nexusTextStyle(NexusText.styles.screenTitle).accessibilityAddTraits(.isHeader)
            switch state.access {
            case .guest: ContentUnavailableView("Keep every trip in one place", systemImage: "suitcase.rolling", description: Text("Sign in to view bookings, payment progress, seats, and issued tickets.")); NexusPrimaryButton("Sign in", fillsWidth: true, action: onSignIn)
            case .loading: ProgressView().frame(maxWidth: .infinity).accessibilityLabel("Loading trips")
            case .authenticated:
                Picker("Trip section", selection: Binding(get: { state.selectedGroup }, set: onSelect)) { ForEach(TripGroup.allCases, id: \.self) { Text($0.label).tag($0) } }.pickerStyle(.segmented)
                if state.offline { NexusBanner(text: "Offline Mode: Showing saved tickets.", status: .offline) }
                if let error = state.error { NexusBanner(text: error, status: .error) }
                if state.loading { ProgressView().frame(maxWidth: .infinity).accessibilityLabel("Loading trips") }
                else if state.visibleTrips.isEmpty { ContentUnavailableView("No trips in this section.", systemImage: "airplane") }
                else { ForEach(state.visibleTrips, id: \.id) { trip in TripCard(trip: trip, onOpen: { onOpen(trip.id) }, onPrimary: { if trip.nextAction == "UPLOAD_PAYMENT_PROOF" { onUpload(trip.id) } else { onOpen(trip.id) } }) } }
            }
        }.padding(NexusSpacing.space24) }.background(NexusSemanticColors.backgroundPage).navigationBarHidden(true)
    }
}
private struct TripCard: View {
    let trip: CustomerTrip; let onOpen, onPrimary: () -> Void
    var body: some View { VStack(alignment: .leading, spacing: NexusSpacing.space12) {
        HStack { NexusStatusChip(text: trip.group.label, status: trip.group == .actionRequired ? .warning : .success); Spacer(); Text("Ref \(trip.id.prefix(8).uppercased())").nexusTextStyle(NexusText.styles.caption) }
        Text(trip.itineraryLabel).nexusTextStyle(NexusText.styles.flightTime)
        if !trip.seats.isEmpty { Text("Seat \(trip.seats.map(\.seatNumber).joined(separator: ", "))").nexusTextStyle(NexusText.styles.bodySmall) }
        HStack { Text(humanize(trip.status)); Spacer(); if let amount = trip.amountMinor { Text("\(trip.currency ?? "") \(amount / 100)").foregroundStyle(NexusSemanticColors.brandPrimary) } }
        .nexusTextStyle(NexusText.styles.label)
        ViewThatFits(in: .horizontal) {
            HStack { NexusSecondaryButton("View details", action: onOpen); Spacer(); NexusPrimaryButton(trip.nextAction == "UPLOAD_PAYMENT_PROOF" ? "Upload receipt" : "View action", action: onPrimary) }
            VStack { NexusSecondaryButton("View details", fillsWidth: true, action: onOpen); NexusPrimaryButton(trip.nextAction == "UPLOAD_PAYMENT_PROOF" ? "Upload receipt" : "View action", fillsWidth: true, action: onPrimary) }
        }
    }.padding(NexusSpacing.space20).background(NexusSemanticColors.surfaceBase).clipShape(RoundedRectangle(cornerRadius: NexusRadius.xl)).overlay(RoundedRectangle(cornerRadius: NexusRadius.xl).stroke(NexusSemanticColors.borderDefault)) }
}

struct TripDetailScreenRoute: View {
    @State private var viewModel: TripDetailViewModel; let router: Router; let onUploadPaymentProof: (String) -> Void
    @State private var previewURL: URL?
    init(viewModel: TripDetailViewModel, router: Router, onUploadPaymentProof: @escaping (String) -> Void) { _viewModel = State(initialValue: viewModel); self.router = router; self.onUploadPaymentProof = onUploadPaymentProof }
    var body: some View {
        TripDetailScreen(state: viewModel.state, onRefresh: { Task { try? await viewModel.load(forceRefresh: true) } }, onTicket: { Task { try? await viewModel.downloadTicket() } }, onUpload: { onUploadPaymentProof(viewModel.state.trip?.id ?? "") }, onSupport: {})
            .navigationTitle("Trip details").navigationBarTitleDisplayMode(.inline).task { try? await viewModel.load() }
            .onChange(of: viewModel.state.ticketToOpen) { _, value in previewURL = value; if value != nil { viewModel.ticketOpened() } }
            .quickLookPreview($previewURL)
    }
}
private struct TripDetailScreen: View {
    let state: TripDetailUiState; let onRefresh, onTicket, onUpload, onSupport: () -> Void
    var body: some View { Group {
        if state.loading { ProgressView().accessibilityLabel("Loading trip") }
        else if let trip = state.trip { ScrollView { VStack(alignment: .leading, spacing: NexusSpacing.space16) {
            Text(trip.itineraryLabel).nexusTextStyle(NexusText.styles.screenTitle); Text("Ref \(trip.id.prefix(8).uppercased())").nexusTextStyle(NexusText.styles.bodySmall)
            NexusBanner(text: state.notice, status: noticeStatus(trip))
            if let error = state.error { NexusBanner(text: error, status: .error) }
            detailCard("Status") { HStack { NexusStatusChip(text: humanize(trip.status), status: noticeStatus(trip)); Spacer(); Text(paymentLabel(trip)).nexusTextStyle(NexusText.styles.label) } }
            if !trip.segments.isEmpty { detailCard("Flights") { ForEach(Array(trip.segments.enumerated()), id: \.offset) { _, segment in VStack(alignment: .leading) { Text(segment.flightLabel).nexusTextStyle(NexusText.styles.label); Text([segment.origin, segment.destination].compactMap { $0 }.joined(separator: " to ")).nexusTextStyle(NexusText.styles.bodySmall) } } } }
            if !trip.seats.isEmpty { detailCard("Seats") { ForEach(Array(trip.seats.enumerated()), id: \.offset) { _, seat in Text("Seat \(seat.seatNumber)") } } }
            if !trip.tickets.isEmpty { detailCard("Tickets") { ForEach(Array(trip.tickets.enumerated()), id: \.offset) { _, ticket in Text(ticket.ticketNumber ?? "Ticket issued") } } }
            if let primary = state.primaryActionLabel { NexusPrimaryButton(primary, isLoading: state.downloadingTicket || state.refreshing, fillsWidth: true, action: action(primary)) }
            if let secondary = state.secondaryActionLabel { NexusSecondaryButton(secondary, fillsWidth: true, action: secondary == "Contact support" ? onSupport : onTicket) }
        }.padding(NexusSpacing.space24) } }
        else { ContentUnavailableView("Could not load trip.", systemImage: "exclamationmark.triangle", description: Text(state.error ?? "Retry to load this trip.")); NexusPrimaryButton("Retry", fillsWidth: true, action: onRefresh).padding() }
    }.background(NexusSemanticColors.backgroundPage) }
    private func action(_ label: String) -> () -> Void { switch label { case "View ticket", "Download again": onTicket; case "Upload payment receipt": onUpload; case "Contact support": onSupport; default: onRefresh } }
    private func detailCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View { VStack(alignment: .leading, spacing: NexusSpacing.space12) { Text(title).nexusTextStyle(NexusText.styles.sectionTitle); content() }.padding(NexusSpacing.space20).frame(maxWidth: .infinity, alignment: .leading).background(NexusSemanticColors.surfaceBase).clipShape(RoundedRectangle(cornerRadius: NexusRadius.xl)) }
}
private func humanize(_ value: String) -> String { value.replacingOccurrences(of: "_", with: " ").lowercased().capitalized }
private func paymentLabel(_ trip: CustomerTrip) -> String { if trip.paymentStatus == "PAID" { "Verified" } else if trip.paymentProofStatus == "UPLOADED" { "Receipt uploaded" } else if trip.nextAction == "UPLOAD_PAYMENT_PROOF" { "Receipt needed" } else { humanize(trip.paymentStatus) } }
private func noticeStatus(_ trip: CustomerTrip) -> NexusStatus { if trip.status == "TICKETED" && trip.ticketDocumentAvailable { .success } else if trip.status.contains("FAILED") || trip.ticketingStatus.contains("FAILED") { .error } else if trip.status.contains("DELAYED") || trip.ticketingStatus == "DELAYED" { .warning } else { .info } }
