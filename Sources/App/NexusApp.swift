import Foundation
import SwiftUI

@main
@MainActor
struct NexusApp: App {
    private let launchDestination: AppLaunchDestination
    @State private var router: Router

    init() {
        launchDestination = AppLaunchDestination(arguments: ProcessInfo.processInfo.arguments)
        _router = State(initialValue: Router())
    }

    var body: some Scene {
        WindowGroup {
            if let gallerySection = launchDestination.gallerySection {
                DesignSystemGalleryScreen(initialSection: gallerySection)
            } else {
                AppShell(router: router)
            }
        }
    }
}
