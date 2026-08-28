/// Validates home flight search state using Android precedence.
struct HomeSearchValidator: Sendable {
    /// Returns first search validation error, or nil when valid.
    func validateSearch(state: HomeUiState, today: LocalDate) -> HomeValidationError? {
        if state.tripType == .multiCity {
            return validateMultiCity(legs: state.multiCityLegs, today: today)
        }
        guard let origin = state.origin else {
            return .missingOrigin
        }
        guard let destination = state.destination else {
            return .missingDestination
        }
        guard origin.code != destination.code else {
            return .sameOriginDestination
        }
        return validateDates(
            tripType: state.tripType,
            departureDate: state.departureDate,
            returnDate: state.returnDate,
            today: today
        )
    }

    /// Returns first date validation error, or nil when dates are valid.
    func validateDates(
        tripType: TripType,
        departureDate: LocalDate?,
        returnDate: LocalDate?,
        today: LocalDate
    ) -> HomeValidationError? {
        guard let departureDate else {
            return .missingDepartureDate
        }
        guard departureDate >= today else {
            return .departureDateInPast
        }
        guard tripType == .roundTrip else {
            return nil
        }
        guard let returnDate else {
            return .missingReturnDate
        }
        return returnDate > departureDate ? nil : .returnBeforeDeparture
    }

    private func validateMultiCity(
        legs: [MultiCityLegUiState],
        today: LocalDate
    ) -> HomeValidationError? {
        guard (2...3).contains(legs.count) else {
            return .invalidMultiCityLegs
        }
        for (index, leg) in legs.enumerated() {
            guard let origin = leg.origin,
                  let destination = leg.destination,
                  let date = leg.departureDate,
                  origin.code != destination.code,
                  date >= today else {
                return .invalidMultiCityLegs
            }
            if index > 0 {
                guard let previousDate = legs[index - 1].departureDate,
                      date >= previousDate else {
                    return .invalidMultiCityLegs
                }
            }
        }
        return nil
    }
}
