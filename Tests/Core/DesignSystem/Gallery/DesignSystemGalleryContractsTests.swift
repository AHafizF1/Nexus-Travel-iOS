import Testing
@testable import NexusTravel

@Suite("Design-system gallery contracts")
struct DesignSystemGalleryContractsTests {
    @Test("Gallery screen constructs")
    @MainActor
    func galleryScreenConstructs() {
        _ = DesignSystemGalleryScreen()
    }
}
