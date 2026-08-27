import SwiftUI

/// Debug gallery for Android-defined Nexus design-system primitives.
struct DesignSystemGalleryScreen: View {
    private let iconColumns = [
        GridItem(
            .adaptive(minimum: NexusSpacing.space64),
            spacing: NexusSpacing.space12
        )
    ]

    /// Creates the stateless design-system gallery.
    init() {}

    /// Scrollable gallery content.
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: NexusSpacing.space24) {
                header
                GallerySectionTitle("Icons")
                iconGrid
                GallerySectionTitle("Buttons")
                buttons
                GallerySectionTitle("Feedback")
                feedback
            }
            .padding(.horizontal, NexusSpacing.space24)
            .padding(.top, NexusSpacing.space24)
            .padding(.bottom, NexusSpacing.space32)
        }
        .background(NexusSemanticColors.backgroundPage.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: NexusSpacing.space8) {
            Text("Nexus design system")
                .foregroundStyle(NexusSemanticColors.textHeading)
                .nexusTextStyle(NexusText.styles.screenTitle)
            Text("Debug gallery")
                .foregroundStyle(NexusSemanticColors.textSecondary)
                .nexusTextStyle(NexusText.styles.body)
        }
    }

    private var iconGrid: some View {
        LazyVGrid(columns: iconColumns, spacing: NexusSpacing.space12) {
            ForEach(NexusIconName.allCases, id: \.self) { name in
                IconTile(name: name)
            }
        }
    }

    private var buttons: some View {
        VStack(spacing: NexusSpacing.space12) {
            NexusPrimaryButton("Continue booking", fillsWidth: true, action: {}) {
                NexusIcon(name: .flight)
                    .frame(width: NexusIconSize.sm, height: NexusIconSize.sm)
            }

            NexusSecondaryButton("Download ticket", fillsWidth: true, action: {}) {
                NexusIcon(name: .download)
                    .frame(width: NexusIconSize.sm, height: NexusIconSize.sm)
            }

            NexusTextButton("View fare rules", action: {})
        }
    }

    private var feedback: some View {
        VStack(alignment: .leading, spacing: NexusSpacing.space24) {
            ForEach(GalleryStatus.allCases, id: \.self) { item in
                NexusBanner(text: item.banner, status: item.status) {
                    NexusIcon(name: item.icon)
                        .frame(width: NexusIconSize.sm, height: NexusIconSize.sm)
                }
            }

            ScrollView(.horizontal) {
                HStack(spacing: NexusSpacing.space8) {
                    ForEach(GalleryStatus.allCases, id: \.self) { item in
                        NexusStatusChip(text: item.label, status: item.status) {
                            NexusIcon(name: item.icon)
                                .frame(width: NexusIconSize.xs, height: NexusIconSize.xs)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

private struct GallerySectionTitle: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .foregroundStyle(NexusSemanticColors.textHeading)
            .nexusTextStyle(NexusText.styles.sectionTitle)
            .accessibilityAddTraits(.isHeader)
    }
}

private struct IconTile: View {
    let name: NexusIconName

    var body: some View {
        VStack(spacing: NexusSpacing.space8) {
            NexusIcon(name: name, accessibilityLabel: name.displayName)
                .foregroundStyle(NexusSemanticColors.textPrimary)
                .frame(width: NexusIconSize.md, height: NexusIconSize.md)
            Text(name.displayName)
                .foregroundStyle(NexusSemanticColors.textSecondary)
                .nexusTextStyle(NexusText.styles.caption)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
        .padding(NexusSpacing.space12)
        .frame(maxWidth: .infinity)
        .background(NexusSemanticColors.surfaceBase)
        .clipShape(RoundedRectangle(cornerRadius: NexusRadius.md))
    }
}

private enum GalleryStatus: CaseIterable, Hashable {
    case success
    case info
    case warning
    case error

    var label: String {
        switch self {
        case .success: "Paid"
        case .info: "Review"
        case .warning: "Delayed"
        case .error: "Offline"
        }
    }

    var banner: String {
        switch self {
        case .success: "Payment confirmed for NX48271."
        case .info: "Ticketing is in manual review."
        case .warning: "ADD to DXB departure time changed."
        case .error: "Connection lost. Saved tickets still available."
        }
    }

    var status: NexusStatus {
        switch self {
        case .success: .success
        case .info: .info
        case .warning: .warning
        case .error: .error
        }
    }

    var icon: NexusIconName {
        switch self {
        case .success: .check
        case .info: .info
        case .warning: .warning
        case .error: .offline
        }
    }
}
