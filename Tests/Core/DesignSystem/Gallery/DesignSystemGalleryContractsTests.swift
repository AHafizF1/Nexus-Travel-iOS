import Testing
@testable import NexusTravel

@Suite("Design-system gallery contracts")
struct DesignSystemGalleryContractsTests {
    @Test("Gallery screen constructs")
    @MainActor
    func galleryScreenConstructs() {
        _ = DesignSystemGalleryScreen()
    }

    @Test("Gallery buttons support explicit full-width layout")
    @MainActor
    func galleryButtonsSupportFullWidthLayout() {
        _ = NexusPrimaryButton("Continue booking", fillsWidth: true, action: {})
        _ = NexusSecondaryButton("Download ticket", fillsWidth: true, action: {})
    }
}
