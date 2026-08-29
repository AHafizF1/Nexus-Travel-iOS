import Testing
@testable import NexusTravel

struct AppLaunchDestinationTests {
    @Test
    func defaultLaunchEntersAppShell() {
        #expect(AppLaunchDestination(arguments: []).gallerySection == nil)
    }

    @Test
    func galleryArgumentKeepsGalleryReachable() {
        let destination = AppLaunchDestination(arguments: ["--gallery-section=buttons"])

        #expect(destination.gallerySection == .buttons)
    }
}
