import Foundation
import SwiftUI
import UIKit

@main
@MainActor
struct NexusApp: App {
    private let launchDestination: AppLaunchDestination
    private let dependencies: AppDependencies?
    @State private var router: Router
    @State private var bookingFlowState: BookingFlowState

    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        for itemAppearance in [
            tabBarAppearance.stackedLayoutAppearance,
            tabBarAppearance.inlineLayoutAppearance,
            tabBarAppearance.compactInlineLayoutAppearance
        ] {
            itemAppearance.normal.iconColor = .clear
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            itemAppearance.selected.iconColor = .clear
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.clear]
        }
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().isUserInteractionEnabled = false

        let arguments = ProcessInfo.processInfo.arguments
        launchDestination = AppLaunchDestination(arguments: arguments)
        dependencies = launchDestination.gallerySection == nil
            ? AppDependencies(sessionStore: arguments.contains("--reset-auth-session")
                ? VolatileAuthSessionStore()
                : KeychainAuthSessionStore())
            : nil
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
                         tripsRepository: dependencies.tripsRepository,
                         exploreRepository: dependencies.exploreRepository,
                         profileRepository: dependencies.profileRepository,
                         securityRepository: dependencies.securityRepository,
                         airportRepository: dependencies.airportRepository,
                         profileViewModel: dependencies.profileViewModel,
                         preferencesViewModel: dependencies.preferencesViewModel,
                         authRepository: dependencies.authRepository,
                         bookingFlowState: bookingFlowState)
                    .preferredColorScheme(dependencies.appTheme.preference == .system ? nil : dependencies.appTheme.preference == .dark ? .dark : .light)
            }
        }
    }
}
