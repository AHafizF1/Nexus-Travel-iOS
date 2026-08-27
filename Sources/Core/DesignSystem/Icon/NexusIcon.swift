import SwiftUI

/// Product icon names mirrored from Android.
enum NexusIconName: String, CaseIterable, Equatable, Hashable {
    case home
    case search
    case trips
    case profile
    case more
    case back
    case close
    case chevronDown
    case chevronRight
    case share
    case download
    case wallet
    case calendar
    case filter
    case sort
    case flight
    case flightDeparture
    case flightArrival
    case hotel
    case car
    case map
    case location
    case seat
    case seatAlt
    case seatSide
    case armchair
    case baggage
    case boardingPass
    case ticket
    case qr
    case gate
    case payment
    case shield
    case headset
    case chat
    case phone
    case email
    case help
    case check
    case info
    case warning
    case error
    case clock
    case offline
    case loading
    case bell
    case tag
    case refund
    case `continue`
    case arrowsExchange

    /// Closest native SF Symbol preserving this icon's product meaning.
    var systemName: String {
        switch self {
        case .home: "house"
        case .search: "magnifyingglass"
        case .trips: "calendar"
        case .profile: "person"
        case .more: "ellipsis"
        case .back: "chevron.left"
        case .close: "xmark"
        case .chevronDown: "chevron.down"
        case .chevronRight: "chevron.right"
        case .share: "square.and.arrow.up"
        case .download: "arrow.down.to.line"
        case .wallet: "wallet.bifold"
        case .calendar: "calendar"
        case .filter: "line.3.horizontal.decrease"
        case .sort: "arrow.up.arrow.down"
        case .flight: "airplane"
        case .flightDeparture: "airplane.departure"
        case .flightArrival: "airplane.arrival"
        case .hotel: "building.2"
        case .car: "car"
        case .map: "map"
        case .location: "mappin"
        case .seat: "chair"
        case .seatAlt: "chair.lounge"
        case .seatSide: "figure.roll"
        case .armchair: "chair.lounge"
        case .baggage: "suitcase"
        case .boardingPass: "rectangle"
        case .ticket: "ticket"
        case .qr: "qrcode"
        case .gate: "building.columns"
        case .payment: "creditcard"
        case .shield: "shield"
        case .headset: "headphones"
        case .chat: "message"
        case .phone: "phone"
        case .email: "envelope"
        case .help: "questionmark.circle"
        case .check: "checkmark"
        case .info: "info.circle"
        case .warning: "exclamationmark.triangle"
        case .error: "xmark.circle"
        case .clock: "clock"
        case .offline: "wifi.slash"
        case .loading: "arrow.clockwise"
        case .bell: "bell"
        case .tag: "tag"
        case .refund: "arrow.uturn.left.circle"
        case .continue: "arrow.right"
        case .arrowsExchange: "arrow.left.arrow.right"
        }
    }

    /// Android enum name used by gallery labels.
    var displayName: String {
        rawValue.prefix(1).uppercased() + String(rawValue.dropFirst())
    }
}

/// A native SF Symbol with optional VoiceOver labeling.
struct NexusIcon: View {
    private let name: NexusIconName
    private let accessibilityLabel: String?

    /// Creates a decorative or explicitly labeled product icon.
    init(name: NexusIconName, accessibilityLabel: String? = nil) {
        self.name = name
        self.accessibilityLabel = accessibilityLabel
    }

    /// Native symbol content.
    @ViewBuilder
    var body: some View {
        if let accessibilityLabel {
            Image(systemName: name.systemName)
                .accessibilityLabel(Text(accessibilityLabel))
        } else {
            Image(systemName: name.systemName)
                .accessibilityHidden(true)
        }
    }
}
