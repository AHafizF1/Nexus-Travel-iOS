import SwiftUI

/// A compact status label with optional leading content.
struct NexusStatusChip<LeadingContent: View>: View {
    private let text: String
    private let status: NexusStatus
    private let leadingContent: () -> LeadingContent

    /// Creates a status chip with leading content.
    init(
        text: String,
        status: NexusStatus,
        @ViewBuilder leadingContent: @escaping () -> LeadingContent
    ) {
        self.text = text
        self.status = status
        self.leadingContent = leadingContent
    }

    /// The status-chip content.
    var body: some View {
        HStack(spacing: NexusSpacing.space8) {
            leadingContent()
            Text(text)
                .nexusTextStyle(NexusText.styles.statusBadge)
        }
        .foregroundStyle(status.colors.content)
        .padding(.horizontal, NexusSpacing.space12)
        .padding(.vertical, NexusSpacing.space8)
        .background(status.colors.container)
        .clipShape(RoundedRectangle(cornerRadius: NexusRadius.xl))
        .overlay {
            RoundedRectangle(cornerRadius: NexusRadius.xl)
                .stroke(status.colors.border, lineWidth: NexusBorder.hairline)
        }
    }
}

extension NexusStatusChip where LeadingContent == EmptyView {
    /// Creates a status chip without leading content.
    init(text: String, status: NexusStatus) {
        self.text = text
        self.status = status
        leadingContent = EmptyView.init
    }
}

/// A full-width status banner with optional leading and trailing content.
struct NexusBanner<LeadingContent: View, TrailingAction: View>: View {
    private let text: String
    private let status: NexusStatus
    private let leadingContent: () -> LeadingContent
    private let trailingAction: () -> TrailingAction

    /// Creates a banner with leading and trailing content.
    init(
        text: String,
        status: NexusStatus,
        @ViewBuilder leadingContent: @escaping () -> LeadingContent,
        @ViewBuilder trailingAction: @escaping () -> TrailingAction
    ) {
        self.text = text
        self.status = status
        self.leadingContent = leadingContent
        self.trailingAction = trailingAction
    }

    /// The status-banner content.
    var body: some View {
        HStack(spacing: NexusSpacing.space12) {
            leadingContent()
            Text(text)
                .foregroundStyle(status.colors.content)
                .nexusTextStyle(NexusText.styles.body)
                .frame(maxWidth: .infinity, alignment: .leading)
            trailingAction()
        }
        .foregroundStyle(status.colors.content)
        .padding(NexusSpacing.space16)
        .frame(maxWidth: .infinity)
        .background(status.colors.container)
        .clipShape(RoundedRectangle(cornerRadius: NexusRadius.md))
        .overlay {
            RoundedRectangle(cornerRadius: NexusRadius.md)
                .stroke(status.colors.border, lineWidth: NexusBorder.hairline)
        }
    }
}

extension NexusBanner where LeadingContent == EmptyView, TrailingAction == EmptyView {
    /// Creates a text-only banner.
    init(text: String, status: NexusStatus) {
        self.text = text
        self.status = status
        leadingContent = EmptyView.init
        trailingAction = EmptyView.init
    }
}

extension NexusBanner where TrailingAction == EmptyView {
    /// Creates a banner with leading content.
    init(
        text: String,
        status: NexusStatus,
        @ViewBuilder leadingContent: @escaping () -> LeadingContent
    ) {
        self.text = text
        self.status = status
        self.leadingContent = leadingContent
        trailingAction = EmptyView.init
    }
}

extension NexusBanner where LeadingContent == EmptyView {
    /// Creates a banner with trailing action content.
    init(
        text: String,
        status: NexusStatus,
        @ViewBuilder trailingAction: @escaping () -> TrailingAction
    ) {
        self.text = text
        self.status = status
        leadingContent = EmptyView.init
        self.trailingAction = trailingAction
    }
}
