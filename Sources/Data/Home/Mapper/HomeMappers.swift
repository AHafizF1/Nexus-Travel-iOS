enum AirportMapper {
    static func map(_ dto: AirportDTO) -> Airport {
        Airport(code: dto.iataCode, city: dto.city, name: dto.name, country: dto.country)
    }
}

enum HomeContentMapper {
    static func map(_ dto: ExploreHomeDTO, origin: Airport, destination fallbackDestination: Airport) -> HomeContent {
        let escapes = dto.packages.enumerated().map { index, package in
            let destination = dto.destinations.indices.contains(index) ? dto.destinations[index] : nil
            return TrendingEscape(
                id: package.id,
                airport: Airport(
                    code: destination?.airportCode ?? fallbackDestination.code,
                    city: destination?.city ?? fallbackDestination.city,
                    name: destination?.title ?? package.title,
                    country: destination?.country ?? fallbackDestination.country
                ),
                tags: [package.summary],
                startingPrice: Money(amount: 0, currency: package.currency, formatted: ""),
                imageName: destination?.imageUrl ?? ""
            )
        }
        let recents = dto.destinations.prefix(3).map {
            RecentSearch(
                id: $0.id,
                originCode: origin.code,
                destinationCode: $0.airportCode ?? fallbackDestination.code,
                dateRange: $0.summary
            )
        }
        return HomeContent(
            origin: origin,
            destination: fallbackDestination,
            departureDate: "Aug 1",
            returnDate: "Add return",
            travelersLabel: "1 Adult",
            cabinClass: "Economy",
            trendingEscapes: escapes,
            recentSearches: recents
        )
    }
}
