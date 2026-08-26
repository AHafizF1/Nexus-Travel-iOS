import SwiftUI
import Testing
import UIKit
@testable import NexusTravel

struct NexusStatusTests {
    @Test func statusesMatchAndroidColorMappings() throws {
        let contracts: [(status: NexusStatus, container: Color, content: Color, border: Color, borderAlpha: CGFloat)] = [
            (.info, NexusSemanticColors.brandSoft, NexusSemanticColors.link, NexusSemanticColors.link, 0.28),
            (.success, NexusSemanticColors.successBg, NexusSemanticColors.successText, NexusSemanticColors.successText, 0.28),
            (.warning, NexusSemanticColors.warningBg, NexusSemanticColors.warningText, NexusSemanticColors.warningText, 0.28),
            (.error, NexusSemanticColors.errorBg, NexusSemanticColors.errorText, NexusSemanticColors.errorText, 0.28),
            (.empty, NexusSemanticColors.surfaceMuted, NexusSemanticColors.textSecondary, NexusSemanticColors.borderDefault, 1),
            (.offline, NexusColors.navy950, NexusSemanticColors.actionPrimaryText, NexusColors.navy950, 1),
            (.restored, NexusSemanticColors.successBg, NexusSemanticColors.successText, NexusSemanticColors.successText, 0.28),
            (.loading, NexusSemanticColors.brandSoft, NexusSemanticColors.actionPrimary, NexusSemanticColors.actionPrimary, 0.28)
        ]

        #expect(contracts.map(\.status) == NexusStatus.allCases)

        for contract in contracts {
            let colors = contract.status.colors
            #expect(try rgbMatches(colors.container, contract.container), "\(contract.status) container differs from Android")
            #expect(try rgbMatches(colors.content, contract.content), "\(contract.status) content differs from Android")
            #expect(try rgbMatches(colors.border, contract.border), "\(contract.status) border differs from Android")
            #expect(abs(try rgbaComponents(of: colors.border).alpha - contract.borderAlpha) < 0.000_001)
        }
    }
}

private struct RGBAComponents {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
}

private func rgbaComponents(of color: Color) throws -> RGBAComponents {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    let isRGB = UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    try #require(isRGB)
    return RGBAComponents(red: red, green: green, blue: blue, alpha: alpha)
}

private func rgbMatches(_ lhs: Color, _ rhs: Color) throws -> Bool {
    let left = try rgbaComponents(of: lhs)
    let right = try rgbaComponents(of: rhs)
    let tolerance: CGFloat = 0.000_001
    return abs(left.red - right.red) < tolerance
        && abs(left.green - right.green) < tolerance
        && abs(left.blue - right.blue) < tolerance
}
