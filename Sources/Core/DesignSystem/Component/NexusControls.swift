import SwiftUI

/// A low-emphasis text action with optional leading content.
struct NexusTextButton<LeadingIcon: View>: View {
    private let title: String
    private let isEnabled: Bool
    private let action: () -> Void
    private let leadingIcon: () -> LeadingIcon

    /// Creates a text button with leading content.
    init(
        _ title: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void,
        @ViewBuilder leadingIcon: @escaping () -> LeadingIcon
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
        self.leadingIcon = leadingIcon
    }

    /// The styled text-button content.
    var body: some View {
        Button(action: action) {
            HStack(spacing: NexusSpacing.space0) {
                leadingIcon()
                Text(title)
                    .nexusTextStyle(NexusText.styles.link)
            }
            .padding(NexusSpacing.space8)
            .frame(minHeight: NexusLayout.touchMin)
        }
        .buttonStyle(NexusTextButtonStyle())
        .disabled(!isEnabled)
        .accessibilityLabel(Text(title))
    }
}

extension NexusTextButton where LeadingIcon == EmptyView {
    /// Creates a text-only text button.
    init(
        _ title: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
        leadingIcon = EmptyView.init
    }
}

/// An accessible selected-or-outlined icon button.
struct NexusIconButton<Icon: View>: View {
    private let accessibilityLabel: String
    private let isEnabled: Bool
    private let isSelected: Bool
    private let action: () -> Void
    private let icon: () -> Icon

    /// Creates an icon button whose text argument is its VoiceOver label.
    init(
        _ accessibilityLabel: String,
        isEnabled: Bool = true,
        isSelected: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder icon: @escaping () -> Icon
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.isEnabled = isEnabled
        self.isSelected = isSelected
        self.action = action
        self.icon = icon
    }

    /// The styled icon-button content.
    var body: some View {
        Button(action: action) {
            icon()
                .frame(width: NexusIconSize.md, height: NexusIconSize.md)
                .frame(width: NexusLayout.touchRecommended, height: NexusLayout.touchRecommended)
        }
        .buttonStyle(NexusIconButtonStyle(isSelected: isSelected))
        .disabled(!isEnabled)
        .accessibilityLabel(Text(accessibilityLabel))
    }
}

private struct NexusTextButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(
                isEnabled
                    ? configuration.isPressed
                        ? NexusSemanticColors.brandPressed
                        : NexusSemanticColors.brandPrimary
                    : NexusSemanticColors.disabledText
            )
            .contentShape(RoundedRectangle(cornerRadius: NexusRadius.md))
    }
}

private struct NexusIconButtonStyle: ButtonStyle {
    let isSelected: Bool

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foregroundColor)
            .background(backgroundColor(configuration: configuration))
            .clipShape(RoundedRectangle(cornerRadius: NexusRadius.md))
            .overlay {
                if !isSelected {
                    RoundedRectangle(cornerRadius: NexusRadius.md)
                        .stroke(NexusSemanticColors.borderDefault, lineWidth: NexusBorder.hairline)
                }
            }
    }

    private var foregroundColor: Color {
        guard isEnabled else { return NexusSemanticColors.disabledText }
        return isSelected
            ? NexusSemanticColors.actionPrimaryText
            : NexusSemanticColors.textPrimary
    }

    private func backgroundColor(configuration: Configuration) -> Color {
        guard isEnabled else {
            return isSelected ? NexusSemanticColors.disabledBg : .clear
        }
        if isSelected {
            return configuration.isPressed
                ? NexusSemanticColors.actionPressed
                : NexusSemanticColors.brandPrimary
        }
        return configuration.isPressed ? NexusSemanticColors.surfaceHover : .clear
    }
}
