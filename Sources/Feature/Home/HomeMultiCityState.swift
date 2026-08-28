/// Creates Android-equivalent initial two-leg multi-city state.
func initialMultiCityLegs(origin: Airport?, destination: Airport?, date: LocalDate?) -> [MultiCityLegUiState] {
    [
        MultiCityLegUiState(origin: origin, destination: destination, departureDate: date),
        MultiCityLegUiState(
            origin: destination,
            departureDate: date?.addingDays(7),
            originAutoLinked: destination != nil
        )
    ]
}

extension Array where Element == MultiCityLegUiState {
    /// Replaces selected origin and marks it manually selected.
    func selectMultiCityOrigin(index: Int, airport: Airport) -> Self {
        enumerated().map { itemIndex, leg in
            guard itemIndex == index else {
                return leg
            }
            return MultiCityLegUiState(
                origin: airport,
                destination: leg.destination,
                departureDate: leg.departureDate,
                originAutoLinked: false
            )
        }
    }

    /// Replaces destination and auto-links eligible next origin.
    func selectMultiCityDestination(index: Int, airport: Airport) -> Self {
        guard indices.contains(index) else {
            return self
        }
        var updated = self
        let leg = updated[index]
        updated[index] = MultiCityLegUiState(
            origin: leg.origin,
            destination: airport,
            departureDate: leg.departureDate,
            originAutoLinked: leg.originAutoLinked
        )
        let nextIndex = index + 1
        if indices.contains(nextIndex) {
            let next = updated[nextIndex]
            if next.origin == nil || next.originAutoLinked {
                updated[nextIndex] = MultiCityLegUiState(
                    origin: airport,
                    destination: next.destination,
                    departureDate: next.departureDate,
                    originAutoLinked: true
                )
            }
        }
        return updated
    }

    /// Replaces selected date and prevents later dates from decreasing.
    func selectMultiCityDate(index: Int, date: LocalDate) -> Self {
        guard indices.contains(index) else {
            return self
        }
        var updated = self
        let selected = updated[index]
        updated[index] = MultiCityLegUiState(
            origin: selected.origin,
            destination: selected.destination,
            departureDate: date,
            originAutoLinked: selected.originAutoLinked
        )
        for nextIndex in (index + 1)..<updated.count {
            guard let previousDate = updated[nextIndex - 1].departureDate else {
                continue
            }
            let next = updated[nextIndex]
            if next.departureDate.map({ $0 < previousDate }) ?? true {
                updated[nextIndex] = MultiCityLegUiState(
                    origin: next.origin,
                    destination: next.destination,
                    departureDate: previousDate,
                    originAutoLinked: next.originAutoLinked
                )
            }
        }
        return updated
    }

    /// Appends linked third leg while preserving safe 2...3-leg bounds.
    func addMultiCityLeg() -> Self {
        guard count < 3, let previous = last else {
            return self
        }
        return self + [MultiCityLegUiState(
            origin: previous.destination,
            departureDate: previous.departureDate,
            originAutoLinked: previous.destination != nil
        )]
    }

    /// Removes selected leg only when at least two legs remain.
    func removeMultiCityLeg(index: Int) -> Self {
        guard count > 2, indices.contains(index) else {
            return self
        }
        return enumerated().compactMap { itemIndex, leg in
            itemIndex == index ? nil : leg
        }
    }
}
