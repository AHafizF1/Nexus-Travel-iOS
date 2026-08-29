import Foundation
import SwiftUI

@main
@MainActor
struct NexusApp: App {
    private let launchDestination: AppLaunchDestination
    private let dependencies: AppDependencies?
    @State private var router: Router
    @State private var bookingFlowState: BookingFlowState

    init() {
        launchDestination = AppLaunchDestination(arguments: ProcessInfo.processInfo.arguments)
        dependencies = launchDestination.gallerySection == nil ? AppDependencies() : nil
        _router = State(initialValue: Router())
        _bookingFlowState = State(initialValue: BookingFlowState())
    }

    var body: some Scene {
        WindowGroup {
            if let gallerySection = launchDestination.gallerySection {
                DesignSystemGalleryScreen(initialSection: gallerySection)
            } else if let dependencies {
                AppShell(router: router, homeViewModel: dependencies.homeViewModel,
                         searchResultsRepository: dependencies.searchResultsRepository,
                         flightDetailsRepository: dependencies.flightDetailsRepository,
                         passengerDetailsRepository: dependencies.passengerDetailsRepository,
                         flightSeatsRepository: dependencies.flightSeatsRepository,
                         bookingRequestRepository: dependencies.bookingRequestRepository,
                         paymentProofRepository: dependencies.paymentProofRepository,
                         authRepository: dependencies.authRepository,
                         bookingFlowState: bookingFlowState)
            }
        }
    }
}
