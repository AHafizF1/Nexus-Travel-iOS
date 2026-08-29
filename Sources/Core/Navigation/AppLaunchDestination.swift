struct AppLaunchDestination {
    let gallerySection: DesignSystemGallerySection?

    init(arguments: [String]) {
        let prefix = "--gallery-section="
        guard let argument = arguments.first(where: { $0.hasPrefix(prefix) }) else {
            gallerySection = nil
            return
        }
        gallerySection = DesignSystemGallerySection(
            rawValue: String(argument.dropFirst(prefix.count))
        ) ?? .top
    }
}
