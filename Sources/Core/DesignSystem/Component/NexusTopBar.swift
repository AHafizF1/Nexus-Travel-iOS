import SwiftUI

/// Supported title placements for native Nexus toolbar content.
enum NexusTopBarTitleAlignment: CaseIterable, Equatable {
    case center
    case start
}

/// Native toolbar content that preserves system navigation behavior.
struct NexusTopBar<Trailing: View>: ToolbarContent {
    private let title: String
    private let titleAlignment: NexusTopBarTitleAlignment
    private let hasTrailingContent: Bool
    private let trailing: () -> Trailing

    /// Creates toolbar content with a trailing view.
    init(
        _ title: String,
        titleAlignment: NexusTopBarTitleAlignment = .center,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.title = title
        self.titleAlignment = titleAlignment
        hasTrailingContent = true
        self.trailing = trailing
    }

    /// Toolbar items for the title and trailing content.
    @ToolbarContentBuilder
    var body: some ToolbarContent {
        if titleAlignment == .center {
            ToolbarItem(placement: .principal) {
                titleView
            }
        } else {
            ToolbarItem(placement: .topBarLeading) {
                titleView
            }
        }
        if hasTrailingContent {
            ToolbarItem(placement: .topBarTrailing) {
                trailing()
            }
        }
    }

    private var titleView: some View {
        Text(title)
            .foregroundStyle(NexusSemanticColors.textHeading)
            .nexusTextStyle(NexusText.styles.screenTitle)
            .lineLimit(1)
            .truncationMode(.tail)
            .accessibilityAddTraits(.isHeader)
    }
}

extension NexusTopBar where Trailing == EmptyView {
    /// Creates toolbar content without a trailing view.
    init(
        _ title: String,
        titleAlignment: NexusTopBarTitleAlignment = .center
    ) {
        self.title = title
        self.titleAlignment = titleAlignment
        hasTrailingContent = false
        trailing = EmptyView.init
    }
}
