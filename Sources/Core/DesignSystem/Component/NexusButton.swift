import SwiftUI

/// A filled primary action button with optional leading content and progress state.
struct NexusPrimaryButton<LeadingIcon: View>: View {
    private let title: String
    private let isEnabled: Bool
    private let isLoading: Bool
    private let minHeight: CGFloat
    private let action: () -> Void
    private let leadingIcon: () -> LeadingIcon

    /// Creates a primary button with leading content.
    init(
        _ title: String,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        minHeight: CGFloat = NexusLayout.buttonHeight,
        action: @escaping () -> Void,
        @ViewBuilder leadingIcon: @escaping () -> LeadingIcon
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.minHeight = minHeight
        self.action = action
        self.leadingIcon = leadingIcon
    }

    /// The styled primary button content.
    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(NexusSemanticColors.actionPrimaryText)
                        .frame(width: NexusIconSize.sm, height: NexusIconSize.sm)
                } else {
                    HStack(spacing: NexusSpacing.space8) {
                        leadingIcon()
                        Text(title)
                            .nexusTextStyle(NexusText.styles.button)
                    }
                }
            }
            .padding(.horizontal, NexusSpacing.space16)
            .padding(.vertical, NexusSpacing.space12)
            .frame(minHeight: minHeight)
        }
        .buttonStyle(NexusPrimaryButtonStyle())
        .disabled(!isEnabled || isLoading)
        .accessibilityLabel(Text(title))
        .accessibilityValue(isLoading ? Text("In progress") : Text(""))
    }
}

extension NexusPrimaryButton where LeadingIcon == EmptyView {
    /// Creates a text-only primary button.
    init(
        _ title: String,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        minHeight: CGFloat = NexusLayout.buttonHeight,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.minHeight = minHeight
        self.action = action
        leadingIcon = EmptyView.init
    }
}

/// An outlined secondary action button with optional leading content.
struct NexusSecondaryButton<LeadingIcon: View>: View {
    private let title: String
    private let isEnabled: Bool
    private let minHeight: CGFloat
    private let action: () -> Void
    private let leadingIcon: () -> LeadingIcon

    /// Creates a secondary button with leading content.
    init(
        _ title: String,
        isEnabled: Bool = true,
        minHeight: CGFloat = NexusLayout.buttonHeight,
        action: @escaping () -> Void,
        @ViewBuilder leadingIcon: @escaping () -> LeadingIcon
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.minHeight = minHeight
        self.action = action
        self.leadingIcon = leadingIcon
    }

    /// The styled secondary button content.
    var body: some View {
        Button(action: action) {
            HStack(spacing: NexusSpacing.space8) {
                leadingIcon()
                Text(title)
                    .nexusTextStyle(NexusText.styles.button)
            }
            .padding(.horizontal, NexusSpacing.space16)
            .padding(.vertical, NexusSpacing.space12)
            .frame(minHeight: minHeight)
        }
        .buttonStyle(NexusSecondaryButtonStyle())
        .disabled(!isEnabled)
        .accessibilityLabel(Text(title))
    }
}

extension NexusSecondaryButton where LeadingIcon == EmptyView {
    /// Creates a text-only secondary button.
    init(
        _ title: String,
        isEnabled: Bool = true,
        minHeight: CGFloat = NexusLayout.buttonHeight,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.minHeight = minHeight
        self.action = action
        leadingIcon = EmptyView.init
    }
}

private struct NexusPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(
                isEnabled
                    ? NexusSemanticColors.actionPrimaryText
                    : NexusSemanticColors.disabledText
            )
            .background(
                isEnabled
                    ? configuration.isPressed
                        ? NexusSemanticColors.actionPressed
                        : NexusSemanticColors.actionPrimary
                    : NexusSemanticColors.disabledBg
            )
            .clipShape(RoundedRectangle(cornerRadius: NexusRadius.md))
    }
}

private struct NexusSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(
                isEnabled
                    ? NexusSemanticColors.actionSecondaryText
                    : NexusSemanticColors.disabledText
            )
            .background(
                configuration.isPressed && isEnabled
                    ? NexusSemanticColors.surfaceActive
                    : NexusSemanticColors.actionSecondary
            )
            .clipShape(RoundedRectangle(cornerRadius: NexusRadius.md))
            .overlay {
                RoundedRectangle(cornerRadius: NexusRadius.md)
                    .stroke(NexusSemanticColors.borderDefault, lineWidth: NexusBorder.hairline)
            }
    }
}
