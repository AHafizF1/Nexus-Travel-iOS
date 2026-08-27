import SwiftUI

/// An outlined Nexus text field with persistent label and inline error text.
struct NexusTextField<LeadingIcon: View, TrailingContent: View>: View {
    @Binding private var text: String

    private let label: String
    private let placeholder: String?
    private let error: String?
    private let isEnabled: Bool
    private let isSecure: Bool
    private let hasLeadingIcon: Bool
    private let hasTrailingContent: Bool
    private let leadingIcon: () -> LeadingIcon
    private let trailingContent: () -> TrailingContent

    @Environment(\.isEnabled) private var isEnabledByEnvironment
    @FocusState private var isFocused: Bool

    /// Creates a standard field with leading and trailing content.
    init(
        text: Binding<String>,
        label: String,
        placeholder: String? = nil,
        error: String? = nil,
        isEnabled: Bool = true,
        isSecure: Bool = false,
        @ViewBuilder leadingIcon: @escaping () -> LeadingIcon,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent
    ) {
        _text = text
        self.label = label
        self.placeholder = placeholder
        self.error = error
        self.isEnabled = isEnabled
        self.isSecure = isSecure
        hasLeadingIcon = true
        hasTrailingContent = true
        self.leadingIcon = leadingIcon
        self.trailingContent = trailingContent
    }

    /// The outlined field, label, and optional error content.
    var body: some View {
        VStack(alignment: .leading, spacing: NexusSpacing.space4) {
            Text(label)
                .foregroundStyle(labelColor)
                .nexusTextStyle(NexusText.styles.bodySmall)

            HStack(spacing: NexusSpacing.space16) {
                if hasLeadingIcon {
                    leadingIcon()
                        .frame(width: NexusIconSize.md, height: NexusIconSize.md)
                }

                ZStack(alignment: .leading) {
                    if text.isEmpty, let placeholder {
                        Text(placeholder)
                            .foregroundStyle(NexusSemanticColors.textTertiary)
                            .nexusTextStyle(NexusText.styles.body)
                            .allowsHitTesting(false)
                    }
                    input
                        .foregroundStyle(inputColor)
                        .tint(NexusSemanticColors.actionPrimary)
                        .nexusTextStyle(NexusText.styles.formInput)
                        .focused($isFocused)
                        .accessibilityLabel(Text(label))
                        .accessibilityHint(error.map { Text($0) } ?? Text(""))
                }

                if hasTrailingContent {
                    trailingContent()
                        .frame(
                            minWidth: NexusLayout.touchRecommended,
                            minHeight: NexusLayout.touchRecommended
                        )
                }
            }
            .padding(.horizontal, NexusSpacing.space16)
            .frame(maxWidth: .infinity, minHeight: NexusLayout.inputHeight)
            .background(fieldBackground)
            .clipShape(fieldShape)
            .overlay {
                fieldShape.stroke(borderColor, lineWidth: borderWidth)
            }

            if let error {
                Text(error)
                    .foregroundStyle(NexusSemanticColors.errorText)
                    .nexusTextStyle(NexusText.styles.errorText)
            }
        }
        .disabled(!isEnabled)
    }

    @ViewBuilder
    private var input: some View {
        if isSecure {
            SecureField("", text: $text)
        } else {
            TextField("", text: $text)
        }
    }

    private var controlIsEnabled: Bool {
        isEnabled && isEnabledByEnvironment
    }

    private var fieldShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: NexusRadius.md)
    }

    private var borderColor: Color {
        if error != nil {
            return NexusSemanticColors.errorText
        }
        if isFocused && controlIsEnabled {
            return NexusSemanticColors.focus
        }
        return NexusSemanticColors.borderDefault
    }

    private var borderWidth: CGFloat {
        error != nil || (isFocused && controlIsEnabled)
            ? NexusBorder.focus
            : NexusBorder.hairline
    }

    private var labelColor: Color {
        if error != nil {
            return NexusSemanticColors.errorText
        }
        guard controlIsEnabled else { return NexusSemanticColors.disabledText }
        return isFocused
            ? NexusSemanticColors.actionPrimary
            : NexusSemanticColors.textTertiary
    }

    private var inputColor: Color {
        controlIsEnabled
            ? NexusSemanticColors.textPrimary
            : NexusSemanticColors.disabledText
    }

    private var fieldBackground: Color {
        controlIsEnabled
            ? NexusSemanticColors.surfaceBase
            : NexusSemanticColors.disabledBg
    }
}

extension NexusTextField where LeadingIcon == EmptyView, TrailingContent == EmptyView {
    /// Creates a standard field without accessory content.
    init(
        text: Binding<String>,
        label: String,
        placeholder: String? = nil,
        error: String? = nil,
        isEnabled: Bool = true,
        isSecure: Bool = false
    ) {
        _text = text
        self.label = label
        self.placeholder = placeholder
        self.error = error
        self.isEnabled = isEnabled
        self.isSecure = isSecure
        hasLeadingIcon = false
        hasTrailingContent = false
        leadingIcon = EmptyView.init
        trailingContent = EmptyView.init
    }
}

extension NexusTextField where TrailingContent == EmptyView {
    /// Creates a standard field with leading content.
    init(
        text: Binding<String>,
        label: String,
        placeholder: String? = nil,
        error: String? = nil,
        isEnabled: Bool = true,
        isSecure: Bool = false,
        @ViewBuilder leadingIcon: @escaping () -> LeadingIcon
    ) {
        _text = text
        self.label = label
        self.placeholder = placeholder
        self.error = error
        self.isEnabled = isEnabled
        self.isSecure = isSecure
        hasLeadingIcon = true
        hasTrailingContent = false
        self.leadingIcon = leadingIcon
        trailingContent = EmptyView.init
    }
}

/// An auth-sized Nexus text field with optional label and accessory content.
struct NexusAuthTextField<LeadingIcon: View, TrailingContent: View>: View {
    @Binding private var text: String

    private let placeholder: String
    private let label: String?
    private let error: String?
    private let isEnabled: Bool
    private let isSecure: Bool
    private let minHeight: CGFloat
    private let hasLeadingIcon: Bool
    private let hasTrailingContent: Bool
    private let leadingIcon: () -> LeadingIcon
    private let trailingContent: () -> TrailingContent

    @Environment(\.isEnabled) private var isEnabledByEnvironment
    @FocusState private var isFocused: Bool

    /// Creates an auth field with leading and trailing content.
    init(
        text: Binding<String>,
        placeholder: String,
        label: String? = nil,
        error: String? = nil,
        isEnabled: Bool = true,
        isSecure: Bool = false,
        minHeight: CGFloat = NexusLayout.authControlHeight,
        @ViewBuilder leadingIcon: @escaping () -> LeadingIcon,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent
    ) {
        _text = text
        self.placeholder = placeholder
        self.label = label
        self.error = error
        self.isEnabled = isEnabled
        self.isSecure = isSecure
        self.minHeight = minHeight
        hasLeadingIcon = true
        hasTrailingContent = true
        self.leadingIcon = leadingIcon
        self.trailingContent = trailingContent
    }

    /// The auth field, optional label, and optional error content.
    var body: some View {
        VStack(alignment: .leading, spacing: NexusSpacing.space0) {
            if let label {
                Text(label)
                    .foregroundStyle(
                        error == nil
                            ? NexusSemanticColors.textPrimary
                            : NexusSemanticColors.errorText
                    )
                    .nexusTextStyle(NexusText.styles.label)
                Spacer()
                    .frame(height: NexusSpacing.space8)
            }

            HStack(spacing: NexusSpacing.space16) {
                if hasLeadingIcon {
                    leadingIcon()
                        .frame(width: NexusIconSize.md, height: NexusIconSize.md)
                }

                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(NexusSemanticColors.textTertiary)
                            .nexusTextStyle(NexusText.styles.formInput)
                            .allowsHitTesting(false)
                    }
                    input
                        .foregroundStyle(NexusSemanticColors.textPrimary)
                        .tint(NexusSemanticColors.actionPrimary)
                        .nexusTextStyle(NexusText.styles.formInput)
                        .focused($isFocused)
                        .accessibilityLabel(Text(label ?? placeholder))
                        .accessibilityHint(error.map { Text($0) } ?? Text(""))
                }

                if hasTrailingContent {
                    trailingContent()
                        .frame(
                            minWidth: NexusLayout.touchRecommended,
                            minHeight: NexusLayout.touchRecommended
                        )
                }
            }
            .padding(.horizontal, NexusSpacing.space16)
            .frame(maxWidth: .infinity, minHeight: minHeight)
            .clipShape(fieldShape)
            .overlay {
                fieldShape.stroke(borderColor, lineWidth: NexusBorder.hairline)
            }

            if let error {
                Spacer()
                    .frame(height: NexusSpacing.space8)
                Text(error)
                    .foregroundStyle(NexusSemanticColors.errorText)
                    .nexusTextStyle(NexusText.styles.errorText)
            }
        }
        .disabled(!isEnabled)
    }

    @ViewBuilder
    private var input: some View {
        if isSecure {
            SecureField("", text: $text)
        } else {
            TextField("", text: $text)
        }
    }

    private var controlIsEnabled: Bool {
        isEnabled && isEnabledByEnvironment
    }

    private var fieldShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: NexusRadius.xl)
    }

    private var borderColor: Color {
        if error != nil {
            return NexusSemanticColors.errorText
        }
        if isFocused && controlIsEnabled {
            return NexusSemanticColors.focus
        }
        return NexusSemanticColors.borderDefault
    }
}

extension NexusAuthTextField where LeadingIcon == EmptyView, TrailingContent == EmptyView {
    /// Creates an auth field without accessory content.
    init(
        text: Binding<String>,
        placeholder: String,
        label: String? = nil,
        error: String? = nil,
        isEnabled: Bool = true,
        isSecure: Bool = false,
        minHeight: CGFloat = NexusLayout.authControlHeight
    ) {
        _text = text
        self.placeholder = placeholder
        self.label = label
        self.error = error
        self.isEnabled = isEnabled
        self.isSecure = isSecure
        self.minHeight = minHeight
        hasLeadingIcon = false
        hasTrailingContent = false
        leadingIcon = EmptyView.init
        trailingContent = EmptyView.init
    }
}

extension NexusAuthTextField where TrailingContent == EmptyView {
    /// Creates an auth field with leading content.
    init(
        text: Binding<String>,
        placeholder: String,
        label: String? = nil,
        error: String? = nil,
        isEnabled: Bool = true,
        isSecure: Bool = false,
        minHeight: CGFloat = NexusLayout.authControlHeight,
        @ViewBuilder leadingIcon: @escaping () -> LeadingIcon
    ) {
        _text = text
        self.placeholder = placeholder
        self.label = label
        self.error = error
        self.isEnabled = isEnabled
        self.isSecure = isSecure
        self.minHeight = minHeight
        hasLeadingIcon = true
        hasTrailingContent = false
        self.leadingIcon = leadingIcon
        trailingContent = EmptyView.init
    }
}
