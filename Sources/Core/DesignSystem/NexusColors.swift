import SwiftUI

/// Android-mirrored primitive and compatibility color tokens.
enum NexusColors {
    static let blue50 = Color(argb: 0xFFEAF2FF)
    static let blue100 = Color(argb: 0xFFD8E7FF)
    static let blue500 = Color(argb: 0xFF0B63F6)
    static let blue600 = Color(argb: 0xFF0052CC)
    static let blue700 = Color(argb: 0xFF0046B8)

    static let navy950 = Color(argb: 0xFF07162F)

    static let neutral900 = Color(argb: 0xFF111827)
    static let neutral700 = Color(argb: 0xFF4B5B73)
    static let neutral500 = Color(argb: 0xFF6B7280)
    static let neutral300 = Color(argb: 0xFFDDE6F2)
    static let neutral200 = Color(argb: 0xFFE6EDF7)
    static let neutral100 = Color(argb: 0xFFF3F6FA)

    static let white = Color(argb: 0xFFFFFFFF)
    static let background = Color(argb: 0xFFF8FAFC)
    static let surface = white

    static let success50 = Color(argb: 0xFFECFDF3)
    static let successText = Color(argb: 0xFF15803D)

    static let warning50 = Color(argb: 0xFFFFF7ED)
    static let warningText = Color(argb: 0xFFB45309)

    static let error50 = Color(argb: 0xFFFEF2F2)
    static let errorText = Color(argb: 0xFFDC2626)
    static let errorStrong = Color(argb: 0xFFB91C1C)

    static let disabledText = Color(argb: 0xFF9AA7B8)
    static let disabledBg = Color(argb: 0xFFEEF2F7)
    static let overlayScrim = Color(argb: 0x9907162F)
    static let etAirlineGreen = Color(argb: 0xFF2E7D32)
    static let etAirlineYellow = Color(argb: 0xFFFBC02D)
    static let etAirlineRed = Color(argb: 0xFFD32F2F)

    static let brand900 = navy950
    static let brand600 = blue500
    static let brand500 = blue600
    static let brand300 = blue100
    static let brand100 = blue50
    static let blue200 = blue100
    static let blue300 = blue100
    static let blue400 = blue500
    static let blue800 = navy950
    static let navy900 = navy950
    static let ink900 = neutral900
    static let slate700 = neutral700
    static let slate500 = neutral500
    static let slate400 = disabledText
    static let slate300 = neutral300
    static let slate200 = neutral200
    static let slate100 = neutral100
    static let slate50 = neutral100
    static let offWhite = background
    static let lightGray = neutral100
    static let pageBackground = background
    static let success500 = successText
    static let warning500 = warningText
    static let error500 = errorText
    static let info500 = blue500
    static let info50 = blue50
    static let infoText = blue600
    static let neutral600 = neutral500
    static let neutral400 = disabledText
}

/// Android-mirrored semantic color roles.
enum NexusSemanticColors {
    static let brandPrimary = NexusColors.blue500
    static let brandPressed = NexusColors.blue700
    static let brandSoft = NexusColors.blue50
    static let textHeading = NexusColors.navy950
    static let textPrimary = NexusColors.navy950
    static let textSecondary = NexusColors.neutral700
    static let textTertiary = NexusColors.neutral500
    static let textDisabled = NexusColors.disabledText
    static let surfaceBase = NexusColors.white
    static let surfaceElevated = NexusColors.white
    static let surfaceMuted = NexusColors.neutral100
    static let surfaceSubtle = surfaceMuted
    static let surfaceHover = NexusColors.neutral100
    static let surfaceActive = NexusColors.blue50
    static let backgroundPage = NexusColors.background
    static let borderDefault = NexusColors.neutral300
    static let borderSubtle = NexusColors.neutral200
    static let borderStrong = NexusColors.neutral300
    static let borderFocus = NexusColors.blue600
    static let focus = NexusColors.blue600
    static let actionPrimary = NexusColors.blue500
    static let actionPressed = NexusColors.blue700
    static let actionPrimaryText = NexusColors.white
    static let actionSecondary = NexusColors.white
    static let actionSecondaryText = NexusColors.navy950
    static let link = NexusColors.blue600
    static let success = NexusColors.successText
    static let successBg = NexusColors.success50
    static let successText = NexusColors.successText
    static let warning = NexusColors.warningText
    static let warningBg = NexusColors.warning50
    static let warningText = NexusColors.warningText
    static let error = NexusColors.errorText
    static let errorBg = NexusColors.error50
    static let errorText = NexusColors.errorText
    static let info = NexusColors.blue500
    static let disabledText = NexusColors.disabledText
    static let disabledBg = NexusColors.disabledBg
    static let overlayScrim = NexusColors.overlayScrim
}

private extension Color {
    init(argb: UInt32) {
        self.init(
            .sRGB,
            red: Double((argb >> 16) & 0xFF) / 255,
            green: Double((argb >> 8) & 0xFF) / 255,
            blue: Double(argb & 0xFF) / 255,
            opacity: Double((argb >> 24) & 0xFF) / 255
        )
    }
}
