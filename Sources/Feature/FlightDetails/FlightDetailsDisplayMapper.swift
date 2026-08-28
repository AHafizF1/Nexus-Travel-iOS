import Foundation

extension FlightDetails {
    /// Maps flight details into exact Android-equivalent display copy.
    func toDisplayModel(warningMessage: String? = nil) -> FlightDetailsDisplayModel {
        FlightDetailsDisplayModel(
            title: "\(originCode) -> \(destinationCode)",
            airlineName: airline.name,
            airlineLogo: airline.visual,
            flightMeta: "\(flightNumber) · \(cabinLabel)",
            dateTravelerMeta: "\(dateRangeLabel) · \(travelers.summary())",
            totalPrice: PriceDisplay(
                currency: price.currency,
                amount: price.formatted.removingPrefix("\(price.currency) "),
                formatted: price.formatted
            ),
            legs: legs.map(\.display),
            warning: warningMessage.map(FlightDetailsWarningDisplay.init(message:))
        )
    }

    private var dateRangeLabel: String {
        guard let returnDate else { return departureDate.monthDay }
        return "\(departureDate.monthDay) - \(returnDate.monthDay)"
    }
}

private extension FlightDetailsLeg {
    var display: FlightLegDisplay {
        FlightLegDisplay(
            label: label,
            date: date.weekdayMonthDay,
            departureAirportCode: departureAirportCode,
            departureAirportName: departureAirportName,
            arrivalAirportCode: arrivalAirportCode,
            arrivalAirportName: arrivalAirportName,
            departureTime: departureTime.twelveHour,
            arrivalTime: arrivalTime.twelveHour,
            duration: "\(durationMinutes / 60)h \(durationMinutes % 60)m",
            stopLabel: stopLabel
        )
    }
}

private extension AirlineBrand {
    var visual: AirlineVisual {
        let assets = [
            "ET": "ic_airline_ethiopian_mark", "EK": "airline_emirates_logo",
            "FZ": "airline_flydubai_logo", "G9": "airline_air_arabia_logo",
            "EY": "airline_etihad_logo", "QR": "airline_qatar_logo",
            "SV": "airline_saudia_logo", "XY": "airline_flynas_logo",
            "MS": "airline_egyptair_logo", "TK": "airline_turkish_mark",
            "KQ": "airline_kenya_airways_mark", "AH": "airline_air_algerie_mark",
            "J4": "airline_badr_icon", "IY": "airline_yemenia_mark"
        ]
        return assets[code].map { .asset(name: $0) } ?? .fallback
    }
}

private extension LocalDate {
    static let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    static let weekdayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var monthDay: String { "\(Self.monthNames[month - 1]) \(day)" }

    var weekdayMonthDay: String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        let components = DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day)
        let weekday = components.date.map { calendar.component(.weekday, from: $0) } ?? 1
        return "\(Self.weekdayNames[weekday - 1]), \(monthDay)"
    }
}

private extension LocalTime {
    var twelveHour: String {
        let period = hour < 12 ? "am" : "pm"
        let displayedHour = hour % 12 == 0 ? 12 : hour % 12
        return String(format: "%d:%02d %@", displayedHour, minute, period)
    }
}

private extension String {
    func removingPrefix(_ prefix: String) -> String {
        hasPrefix(prefix) ? String(dropFirst(prefix.count)) : self
    }
}
