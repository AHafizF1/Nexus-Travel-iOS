import Foundation

/// Selectable country, nationality, and phone-code values.
struct CountryOption: Equatable, Hashable, Sendable {
    let isoCode: String
    let countryName: String
    let nationalityLabel: String
    let dialCode: String

    /// Country-only search label.
    var countrySearchLabel: String { countryName }

    /// Country and dial-code search label.
    var dialSearchLabel: String { "\(countryName) \(dialCode)" }
}

/// Country options used by passenger intake.
enum CountryCatalog {
    static let defaultIsoCode = "ET"
    static let defaultCountryName = "Ethiopia"
    static let defaultNationalityLabel = "Ethiopian"
    static let defaultDialCode = "+251"

    static let countries: [CountryOption] = {
        let locale = Locale.current
        return Locale.Region.isoRegions.compactMap { region -> CountryOption? in
            let code = region.identifier
            guard let name = locale.localizedString(forRegionCode: code), !name.isEmpty else { return nil }
            return CountryOption(isoCode: code, countryName: name,
                                 nationalityLabel: code == defaultIsoCode ? defaultNationalityLabel : name,
                                 dialCode: dialCode(for: code))
        }.sorted {
            if $0.isoCode == defaultIsoCode { return true }
            if $1.isoCode == defaultIsoCode { return false }
            return $0.countryName.localizedStandardCompare($1.countryName) == .orderedAscending
        }
    }()

    static let defaultCountry = countries.first { $0.isoCode == defaultIsoCode } ??
        CountryOption(isoCode: defaultIsoCode, countryName: defaultCountryName,
                      nationalityLabel: defaultNationalityLabel, dialCode: defaultDialCode)

    static func byIsoCode(_ code: String) -> CountryOption {
        countries.first { $0.isoCode.caseInsensitiveCompare(code) == .orderedSame } ?? defaultCountry
    }

    static func byCountryName(_ name: String) -> CountryOption {
        let target = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return countries.first {
            $0.countryName.caseInsensitiveCompare(target) == .orderedSame ||
                $0.nationalityLabel.caseInsensitiveCompare(target) == .orderedSame
        } ?? defaultCountry
    }

    static func selectedIndex(options: [CountryOption], selectedIsoCode: String) -> Int {
        let selected = selectedIsoCode.isEmpty ? defaultIsoCode : selectedIsoCode
        if let index = options.firstIndex(where: { $0.isoCode.caseInsensitiveCompare(selected) == .orderedSame }) {
            return index
        }
        return options.firstIndex { $0.isoCode == defaultIsoCode } ?? 0
    }

    private static func dialCode(for code: String) -> String {
        switch code {
        case "ET": "+251"
        case "US", "CA": "+1"
        case "GB": "+44"
        case "KE": "+254"
        case "UG": "+256"
        case "TZ": "+255"
        case "AE": "+971"
        case "SA": "+966"
        case "ZA": "+27"
        case "NG": "+234"
        case "IN": "+91"
        case "CN": "+86"
        case "DE": "+49"
        case "FR": "+33"
        case "IT": "+39"
        case "ES": "+34"
        case "TR": "+90"
        case "EG": "+20"
        default: ""
        }
    }
}
