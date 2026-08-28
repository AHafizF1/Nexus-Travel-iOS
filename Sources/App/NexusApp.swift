import Foundation
import SwiftUI

@main
struct NexusApp: App {
    private let initialGallerySection: DesignSystemGallerySection

    init() {
        let prefix = "--gallery-section="
        initialGallerySection = ProcessInfo.processInfo.arguments
            .first { $0.hasPrefix(prefix) }
            .flatMap { DesignSystemGallerySection(rawValue: String($0.dropFirst(prefix.count))) }
            ?? .top
    }

    var body: some Scene {
        WindowGroup {
            // Phase 4 app shell replaces this temporary gallery root.
            DesignSystemGalleryScreen(initialSection: initialGallerySection)
        }
    }
}
