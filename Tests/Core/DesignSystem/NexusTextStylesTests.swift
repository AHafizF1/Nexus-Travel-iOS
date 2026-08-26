import SwiftUI
import Testing
import UIKit
@testable import NexusTravel

struct NexusTextStylesTests {
    @Test func catalogMatchesAndroidTypographyContract() {
        let actual = [
            NamedStyle("displayHero", NexusText.styles.displayHero),
            NamedStyle("displayHeroCompact", NexusText.styles.displayHeroCompact),
            NamedStyle("screenTitle", NexusText.styles.screenTitle),
            NamedStyle("sectionTitle", NexusText.styles.sectionTitle),
            NamedStyle("sectionTitleSmall", NexusText.styles.sectionTitleSmall),
            NamedStyle("listTitle", NexusText.styles.listTitle),
            NamedStyle("listTitleLarge", NexusText.styles.listTitleLarge),
            NamedStyle("body", NexusText.styles.body),
            NamedStyle("bodyLarge", NexusText.styles.bodyLarge),
            NamedStyle("bodySmall", NexusText.styles.bodySmall),
            NamedStyle("caption", NexusText.styles.caption),
            NamedStyle("label", NexusText.styles.label),
            NamedStyle("formInput", NexusText.styles.formInput),
            NamedStyle("button", NexusText.styles.button),
            NamedStyle("link", NexusText.styles.link),
            NamedStyle("priceAmount", NexusText.styles.priceAmount),
            NamedStyle("priceAmountSmall", NexusText.styles.priceAmountSmall),
            NamedStyle("currencyLabel", NexusText.styles.currencyLabel),
            NamedStyle("flightTime", NexusText.styles.flightTime),
            NamedStyle("flightTimeCompact", NexusText.styles.flightTimeCompact),
            NamedStyle("airportCode", NexusText.styles.airportCode),
            NamedStyle("durationStop", NexusText.styles.durationStop),
            NamedStyle("bookingReference", NexusText.styles.bookingReference),
            NamedStyle("ticketNumber", NexusText.styles.ticketNumber),
            NamedStyle("statusBadge", NexusText.styles.statusBadge),
            NamedStyle("errorText", NexusText.styles.errorText)
        ]
        let expected = [
            ExpectedStyle("displayHero", .bold, 36, 44, .largeTitle),
            ExpectedStyle("displayHeroCompact", .bold, 32, 40, .largeTitle),
            ExpectedStyle("screenTitle", .bold, 24, 32, .title),
            ExpectedStyle("sectionTitle", .bold, 20, 28, .title2),
            ExpectedStyle("sectionTitleSmall", .semibold, 18, 24, .title3),
            ExpectedStyle("listTitle", .semibold, 16, 22, .headline),
            ExpectedStyle("listTitleLarge", .semibold, 18, 24, .title3),
            ExpectedStyle("body", .regular, 16, 24, .body),
            ExpectedStyle("bodyLarge", .regular, 18, 28, .body),
            ExpectedStyle("bodySmall", .regular, 14, 20, .subheadline),
            ExpectedStyle("caption", .medium, 12, 16, .caption),
            ExpectedStyle("label", .medium, 14, 18, .headline),
            ExpectedStyle("formInput", .regular, 17, 24, .body),
            ExpectedStyle("button", .semibold, 16, 20, .headline),
            ExpectedStyle("link", .semibold, 16, 22, .headline),
            ExpectedStyle("priceAmount", .extrabold, 28, 34, .title3, usesTabularNumbers: true),
            ExpectedStyle("priceAmountSmall", .extrabold, 23, 29, .title3, usesTabularNumbers: true),
            ExpectedStyle("currencyLabel", .medium, 12, 16, .caption),
            ExpectedStyle("flightTime", .bold, 22, 28, .title3, usesTabularNumbers: true),
            ExpectedStyle("flightTimeCompact", .bold, 21, 27, .title3, usesTabularNumbers: true),
            ExpectedStyle("airportCode", .bold, 18, 24, .title3),
            ExpectedStyle("durationStop", .medium, 14, 18, .subheadline, usesTabularNumbers: true),
            ExpectedStyle("bookingReference", .bold, 18, 24, .title3, usesTabularNumbers: true),
            ExpectedStyle("ticketNumber", .semibold, 16, 22, .headline, usesTabularNumbers: true),
            ExpectedStyle("statusBadge", .semibold, 12, 16, .caption),
            ExpectedStyle("errorText", .medium, 14, 20, .subheadline)
        ]

        #expect(actual.count == 26)
        #expect(actual.count == expected.count)
        for (actualStyle, expectedStyle) in zip(actual, expected) {
            #expect(actualStyle.name == expectedStyle.name)
            #expect(actualStyle.style.fontWeight == expectedStyle.fontWeight)
            #expect(actualStyle.style.baseSize == expectedStyle.baseSize)
            #expect(actualStyle.style.baseLineHeight == expectedStyle.baseLineHeight)
            #expect(actualStyle.style.relativeTo == expectedStyle.relativeTo)
            #expect(actualStyle.style.usesTabularNumbers == expectedStyle.usesTabularNumbers)
        }
    }

    @Test func onlyAndroidTabularRolesUseTabularNumbers() {
        let tabularRoles = [
            NamedStyle("priceAmount", NexusText.styles.priceAmount),
            NamedStyle("priceAmountSmall", NexusText.styles.priceAmountSmall),
            NamedStyle("flightTime", NexusText.styles.flightTime),
            NamedStyle("flightTimeCompact", NexusText.styles.flightTimeCompact),
            NamedStyle("durationStop", NexusText.styles.durationStop),
            NamedStyle("bookingReference", NexusText.styles.bookingReference),
            NamedStyle("ticketNumber", NexusText.styles.ticketNumber)
        ]

        #expect(tabularRoles.count == 7)
        #expect(tabularRoles.allSatisfy(\.style.usesTabularNumbers))
    }

    @Test
    @MainActor
    func embeddedFontFacesResolveByPostScriptName() {
        let expectedNames = [
            "PlusJakartaSans-Regular",
            "PlusJakartaSans-Medium",
            "PlusJakartaSans-SemiBold",
            "PlusJakartaSans-Bold",
            "PlusJakartaSans-ExtraBold"
        ]

        let fontWeights: [NexusFontWeight] = [.regular, .medium, .semibold, .bold, .extrabold]

        #expect(fontWeights.map(\.postScriptName) == expectedNames)
        for name in expectedNames {
            #expect(UIFont(name: name, size: 16) != nil)
        }
    }

    @Test
    @MainActor
    func customFontScalesAtAccessibilitySizes() throws {
        let font = try #require(UIFont(name: NexusFontWeight.regular.postScriptName, size: 16))
        let metrics = UIFontMetrics(forTextStyle: .body)
        let defaultTraits = UITraitCollection(preferredContentSizeCategory: .large)
        let accessibilityTraits = UITraitCollection(
            preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge
        )

        let defaultFont = metrics.scaledFont(for: font, compatibleWith: defaultTraits)
        let accessibilityFont = metrics.scaledFont(for: font, compatibleWith: accessibilityTraits)

        #expect(accessibilityFont.pointSize > defaultFont.pointSize)
    }
}

private struct NamedStyle {
    let name: String
    let style: NexusTextStyle

    init(_ name: String, _ style: NexusTextStyle) {
        self.name = name
        self.style = style
    }
}

private struct ExpectedStyle {
    let name: String
    let fontWeight: NexusFontWeight
    let baseSize: CGFloat
    let baseLineHeight: CGFloat
    let relativeTo: Font.TextStyle
    let usesTabularNumbers: Bool

    init(
        _ name: String,
        _ fontWeight: NexusFontWeight,
        _ baseSize: CGFloat,
        _ baseLineHeight: CGFloat,
        _ relativeTo: Font.TextStyle,
        usesTabularNumbers: Bool = false
    ) {
        self.name = name
        self.fontWeight = fontWeight
        self.baseSize = baseSize
        self.baseLineHeight = baseLineHeight
        self.relativeTo = relativeTo
        self.usesTabularNumbers = usesTabularNumbers
    }
}
