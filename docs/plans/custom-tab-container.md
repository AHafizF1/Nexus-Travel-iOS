# Custom tab container fallback plan

Use this plan only if the native `TabView` solution cannot pass every gate below.

## Goal

Keep Nexus floating bottom navigation on iPhone and iPad without rendering or reserving space for Apple tab chrome. Preserve current `Router` selection behavior and one independent `NavigationStack` path per tab.

## Current evidence

- Applying `toolbarVisibility(.hidden, for: .tabBar)` inside each tab removes the elevated iPadOS 26 tab bar.
- Custom navigation and Home alignment UI checks pass on iPadOS 26.
- Custom navigation passes on iPhone 11/iOS 17, but the strict Home horizontal-alignment check still fails on that 414-point device. Diagnose that failure separately before attributing it to `TabView`.

## Minimal implementation

1. Add a private `MainTabContainer` beside `AppShell`; do not add a new routing or DI layer.
2. Reuse `Router.selectedTab`, `Router.select(_:)`, and all four existing path bindings.
3. Keep all four `NavigationStack` roots structurally stable so switching tabs does not reset local state or navigation history.
4. Show only the selected stack. Inactive stacks must disable hit testing and accessibility exposure.
5. Put `MainBottomBar` in one outer `safeAreaInset`; remove all `TabView`, `.tabItem`, `UITabBarAppearance`, and native-tab hiding code together.
6. Prevent inactive roots from starting duplicate `.task` work or presenting sheets. If existing roots cannot be made inactive without broad changes, stop and retain native `TabView`.

## Test-first gates

- Router unit tests continue proving selection, reselection-to-root, and independent path history.
- Add one UI test: push Home detail, switch tab, return Home, verify detail remains.
- Add one UI test: inactive tab controls are neither hittable nor exposed to accessibility queries.
- Existing custom-bottom-navigation and Home bounds tests pass.
- Manual screenshots: iPhone 11/iOS 17; current iPhone/iOS 26; iPad portrait and landscape/iPadOS 26; default and accessibility-XXXL Dynamic Type.
- Verify hero remains visible, card remains centered, content clears floating bar, keyboard dismissal works, and VoiceOver announces one selected tab.

## Decision gate

Adopt custom container only when all gates pass without device-specific offsets or duplicated navigation state. Otherwise retain `TabView` and fix the isolated Home width bug.
