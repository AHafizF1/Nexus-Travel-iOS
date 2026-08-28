import Foundation

/// Split calendar-date input used by passenger forms.
struct PassengerDateInput: Equatable, Hashable, Sendable {
    let day: String
    let month: String
    let year: String

    /// Parsed Gregorian date within supported passenger-input years.
    var parsed: LocalDate? {
        guard let day = Int(day.trimmingCharacters(in: .whitespacesAndNewlines)),
              let month = Int(month.trimmingCharacters(in: .whitespacesAndNewlines)),
              let year = Int(year.trimmingCharacters(in: .whitespacesAndNewlines)),
              (1900...2100).contains(year) else { return nil }
        return LocalDate(year: year, month: month, day: day)
    }

    /// Whether every date part contains nonblank input.
    var complete: Bool {
        [day, month, year].allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    /// Returns input with day restricted to two numeric characters.
    func withDay(_ value: String) -> Self { Self(day: value.numericPrefix(2), month: month, year: year) }

    /// Returns input with month restricted to two numeric characters.
    func withMonth(_ value: String) -> Self { Self(day: day, month: value.numericPrefix(2), year: year) }

    /// Returns input with year restricted to four numeric characters.
    func withYear(_ value: String) -> Self { Self(day: day, month: month, year: value.numericPrefix(4)) }
}

extension PassengerDetailsFormState {
    /// Current split date-of-birth input.
    func dateOfBirthInput() -> PassengerDateInput {
        PassengerDateInput(day: dateOfBirthDay, month: dateOfBirthMonth, year: dateOfBirthYear)
    }

    /// Current split passport-expiry input.
    func passportExpiryInput() -> PassengerDateInput {
        PassengerDateInput(day: passportExpiryDay, month: passportExpiryMonth, year: passportExpiryYear)
    }

    /// Returns form synchronized with split date-of-birth input.
    func withDateOfBirth(_ input: PassengerDateInput) -> Self {
        var result = self
        result.dateOfBirthDay = input.day; result.dateOfBirthMonth = input.month
        result.dateOfBirthYear = input.year; result.dateOfBirth = input.parsed
        return result
    }

    /// Returns form synchronized with split passport-expiry input.
    func withPassportExpiry(_ input: PassengerDateInput) -> Self {
        var result = self
        result.passportExpiryDay = input.day; result.passportExpiryMonth = input.month
        result.passportExpiryYear = input.year; result.passportExpiryDate = input.parsed
        return result
    }
}

private extension String {
    func numericPrefix(_ maximumLength: Int) -> String {
        String(filter { $0.wholeNumberValue != nil }.prefix(maximumLength))
    }
}
