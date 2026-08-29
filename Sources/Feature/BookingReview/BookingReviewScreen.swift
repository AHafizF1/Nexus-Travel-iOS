import SwiftUI

struct BookingReviewScreenRoute: View {
    @State private var viewModel: BookingReviewViewModel
    @State private var eventTask: Task<Void, Never>?
    let flightDetails: FlightDetails?
    let router: Router
    init(viewModel: BookingReviewViewModel, flightDetails: FlightDetails?, router: Router) {
        _viewModel = State(initialValue: viewModel); self.flightDetails = flightDetails; self.router = router
    }
    var body: some View {
        BookingReviewScreen(viewModel: viewModel, flightDetails: flightDetails, send: send)
            .task { do { try await viewModel.load() } catch is CancellationError { return } catch { return } }
            .onDisappear { eventTask?.cancel() }
    }
    private func send(_ event: BookingReviewEvent) {
        guard eventTask == nil || event == .back else { return }
        eventTask = Task {
            do {
                switch event {
                case .back: viewModel.back()
                case .retry: try await viewModel.load()
                case .submit: try await viewModel.submit()
                case .home: viewModel.home()
                case .payment: viewModel.payment()
                case .trip: viewModel.trip()
                }
            } catch is CancellationError { eventTask = nil; return } catch { eventTask = nil; return }
            route(); eventTask = nil
        }
    }
    private func route() {
        while let event = viewModel.consumeNavigation() {
            switch event {
            case .back: router.pop()
            case .home: router.popToRoot()
            case let .payment(id): router.push(.paymentProof(.init(bookingId: id)))
            case let .trip(id): router.push(.tripDetail(.init(tripId: id)))
            }
        }
    }
}

enum BookingReviewEvent: Equatable, Sendable { case back, retry, submit, home, payment, trip }

struct BookingReviewScreen: View {
    @Bindable var viewModel: BookingReviewViewModel
    let flightDetails: FlightDetails?
    let send: (BookingReviewEvent) -> Void
    var body: some View {
        Group {
            switch viewModel.state.screenState {
            case .loading: ProgressView("Loading booking review").frame(maxWidth: .infinity, maxHeight: .infinity)
            case .error: ContentUnavailableView("Could not load booking review", systemImage: "exclamationmark.triangle", description: Text(viewModel.state.message ?? "Please retry."))
                    .overlay(alignment: .bottom) { NexusPrimaryButton("Retry", fillsWidth: true) { send(.retry) }.padding() }
            case .content: review
            case .submitted: submitted
            }
        }
        .navigationTitle("Review booking").navigationBarBackButtonHidden()
        .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Back", systemImage: "chevron.left") { send(.back) } } }
        .safeAreaInset(edge: .bottom) {
            if viewModel.state.screenState == .content, let details = viewModel.state.details {
                VStack(spacing: NexusSpacing.space8) {
                    HStack { Text("Total"); Spacer(); Text(details.fareTotal.formatted).fontWeight(.bold) }
                    Text("Held now, ticketed after verification").font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)
                    NexusPrimaryButton("Book flight", isLoading: viewModel.state.isSubmitting, fillsWidth: true) { send(.submit) }
                }.padding(NexusSpacing.space16).background(.regularMaterial)
            }
        }
    }

    private var review: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: NexusSpacing.space16) {
                if let flightDetails {
                    Text("\(flightDetails.originCode) → \(flightDetails.destinationCode)").font(.title2.bold())
                    Text("\(flightDetails.departureDate.reviewLabel) · \(flightDetails.travelers.summary()) · \(flightDetails.cabinLabel)").foregroundStyle(.secondary)
                }
                if let details = viewModel.state.details {
                    notice(details.status.label, statusMessage(details.status))
                    section("Passenger details", rows: details.passengers.enumerated().flatMap { index, passenger in
                        [(index == 0 ? "Passenger" : "Passenger \(index + 1)", "\(passenger.title) \(passenger.firstName) \(passenger.lastName)"),
                         ("Passport", passenger.passportNumber), ("Nationality", passenger.nationality)]
                    })
                    section("Contact details", rows: [("Email", details.contact.email), ("Mobile", details.contact.phone)])
                    section("Seats", rows: details.seats.isEmpty ? [("Seats", "Airline will assign seats")] : details.seats.map {
                        ("Passenger \($0.passengerIndex + 1)", "\($0.seatNumber) · Flight \($0.segmentId.replacingOccurrences(of: "segment-", with: ""))")
                    })
                    fareSection(details)
                    notice("Manual verification", "Your flight is held after booking. Upload payment receipt so our team can verify and issue the ticket.")
                }
                if let message = viewModel.state.message { Text(message).foregroundStyle(.red) }
            }.padding(NexusSpacing.space16)
        }
    }

    private var submitted: some View {
        VStack(spacing: NexusSpacing.space16) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 64)).foregroundStyle(.green).accessibilityHidden(true)
            Text("Flight booked").font(.title2.bold())
            Text("Your booking is held. Pay now and upload your receipt so we can verify payment and issue your ticket.")
                .foregroundStyle(.secondary)
            if let reference = viewModel.state.details?.bookingReference { notice("Booking ref", reference) }
            NexusPrimaryButton("Upload payment receipt", fillsWidth: true) { send(.payment) }
            NexusSecondaryButton("View trip", fillsWidth: true) { send(.trip) }
        }.multilineTextAlignment(.center).padding(NexusSpacing.space24)
    }

    private func section(_ title: String, rows: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: NexusSpacing.space12) {
            Text(title).font(.headline)
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(alignment: .firstTextBaseline) { Text(row.0).foregroundStyle(.secondary); Spacer(); Text(row.1).multilineTextAlignment(.trailing) }
            }
        }.padding(NexusSpacing.space16).background(.background, in: .rect(cornerRadius: NexusRadius.lg))
    }
    private func fareSection(_ details: BookingReviewDetails) -> some View {
        let seatAmount = details.seats.compactMap(\.price).reduce(0) { $0 + $1.amount }
        var rows: [(String, String)] = []
        if let flightDetails {
            rows.append(("Base fare", flightDetails.priceBreakdown.baseFare.formatted))
            rows.append(("Taxes and fees", flightDetails.priceBreakdown.taxesAndFees.formatted))
            if let fee = flightDetails.priceBreakdown.serviceFee { rows.append(("Service fee", fee.formatted)) }
        }
        if seatAmount > 0 { rows.append(("Seat fees", String(format: "%@ %.2f", details.fareTotal.currency, Double(seatAmount) / 100))) }
        rows.append(("Total", details.fareTotal.formatted))
        return section("Fare summary", rows: rows)
    }
    private func notice(_ title: String, _ message: String) -> some View {
        VStack(alignment: .leading, spacing: NexusSpacing.space4) { Text(title).font(.headline); Text(message).foregroundStyle(.secondary) }
            .frame(maxWidth: .infinity, alignment: .leading).padding(NexusSpacing.space16)
            .background(Color.accentColor.opacity(0.1), in: .rect(cornerRadius: NexusRadius.lg))
    }
    private func statusMessage(_ status: BookingRequestStatus) -> String {
        switch status {
        case .draftSaved: "Review details before booking this flight."
        case .submittedForManualReview: "Flight booked. Upload payment receipt so we can verify and issue your ticket."
        case .agentReviewing: "Our team is checking this booking."
        case .confirmed: "Booking confirmed."
        case .expired: "This fare expired. Choose another flight."
        case .unavailable: "This fare is no longer available."
        case .none: "No booking exists for this flight."
        }
    }
}

private extension LocalDate {
    var reviewLabel: String {
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        return "\(months[month - 1]) \(day), \(year)"
    }
}
