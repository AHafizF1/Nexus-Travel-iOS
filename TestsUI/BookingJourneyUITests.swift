import XCTest

final class BookingJourneyUITests: XCTestCase {
    @MainActor
    func testCustomBottomNavigationIsAvailable() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["main-tab-home"].waitForExistence(timeout: 30))
        XCTAssertTrue(app.buttons["main-tab-explore"].exists)
        XCTAssertTrue(app.buttons["main-tab-trips"].exists)
        XCTAssertTrue(app.buttons["main-tab-profile"].exists)
    }

    @MainActor
    func testNativeTabBarIsAbsent() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["main-tab-home"].waitForExistence(timeout: 30))
        XCTAssertEqual(app.tabBars.count, 0)
    }

    @MainActor
    func testCustomTabsExposeStableRootsAndOneSelection() {
        let app = XCUIApplication()
        app.launchArguments.append("--reset-auth-session")
        app.launch()

        let expectations = [
            ("main-tab-home", "root-home"),
            ("main-tab-explore", "root-explore"),
            ("main-tab-trips", "root-trips"),
            ("main-tab-profile", "root-profile")
        ]

        for (tabIdentifier, rootIdentifier) in expectations {
            let tab = app.buttons[tabIdentifier]
            XCTAssertTrue(tab.waitForExistence(timeout: 30))
            tab.tap()
            let root = app.descendants(matching: .any).matching(identifier: rootIdentifier).firstMatch
            XCTAssertTrue(root.waitForExistence(timeout: 10))
            let selectedCount = expectations.filter { app.buttons[$0.0].isSelected }.count
            XCTAssertEqual(selectedCount, 1)
            XCTAssertTrue(tab.isSelected)
        }
    }

    @MainActor
    func testHomeFormStateSurvivesTabSwitch() {
        let app = XCUIApplication()
        app.launch()

        let roundTrip = app.buttons["Round Trip"]
        XCTAssertTrue(roundTrip.waitForExistence(timeout: 30))
        roundTrip.tap()
        app.buttons["main-tab-explore"].tap()
        app.buttons["main-tab-home"].tap()

        XCTAssertTrue(app.buttons["Round Trip"].isSelected)
    }

    @MainActor
    func testExploreFilterSurvivesTabSwitch() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["main-tab-explore"].tap()
        let packages = app.buttons["Packages"]
        guard packages.waitForExistence(timeout: 15) else {
            if app.buttons["Try again"].exists {
                throw XCTSkip("Explore is unavailable; Router filter retention has a unit test.")
            }
            XCTFail("Explore Packages filter did not appear.")
            return
        }
        packages.tap()
        app.buttons["main-tab-home"].tap()
        app.buttons["main-tab-explore"].tap()

        XCTAssertTrue(app.buttons["Packages"].isSelected)
    }

    @MainActor
    func testRootScrollTargetSurvivesTabSwitch() {
        let app = XCUIApplication()
        app.launch()

        let services = app.descendants(matching: .any).matching(identifier: "home-section-services").firstMatch
        XCTAssertTrue(app.buttons["Search Flights"].waitForExistence(timeout: 30))
        app.scrollViews.firstMatch.swipeUp()
        XCTAssertTrue(services.isHittable)
        app.buttons["main-tab-explore"].tap()
        app.buttons["main-tab-home"].tap()

        XCTAssertTrue(services.waitForExistence(timeout: 10))
        XCTAssertTrue(services.isHittable)
    }

    @MainActor
    func testHomeOmitsRecentSearchesAndShowsFeaturedCards() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Search Flights"].waitForExistence(timeout: 30))
        app.scrollViews["root-home"].swipeUp()

        let destination = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH %@", "home-featured-destination-")
        ).firstMatch
        XCTAssertTrue(destination.waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["home-featured-packages"].exists)
        XCTAssertFalse(app.buttons["View all"].exists)
        XCTAssertEqual(
            app.descendants(matching: .any).matching(identifier: "home-section-recent-searches").count,
            0
        )
    }

    @MainActor
    func testFeaturedDestinationOpensDestinationDetail() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Search Flights"].waitForExistence(timeout: 30))
        app.scrollViews["root-home"].swipeUp()
        let destination = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH %@", "home-featured-destination-")
        ).firstMatch
        guard destination.waitForExistence(timeout: 10) else {
            throw XCTSkip("Live destination data unavailable.")
        }

        destination.tap()

        let detail = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH %@", "destination-detail-")
        ).firstMatch
        XCTAssertTrue(detail.waitForExistence(timeout: 15))
        XCTAssertFalse(app.buttons["main-tab-home"].exists)
    }

    @MainActor
    func testDestinationDetailShowsAndroidFlightPlanWithoutShareOrSave() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["Search Flights"].waitForExistence(timeout: 30))
        app.scrollViews["root-home"].swipeUp()
        let destination = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH %@", "home-featured-destination-")
        ).firstMatch
        guard destination.waitForExistence(timeout: 10) else {
            throw XCTSkip("Live destination data unavailable.")
        }
        destination.tap()

        XCTAssertTrue(app.staticTexts["From Addis Ababa • Round trip • Economy"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.staticTexts["Select travel dates"].exists)
        XCTAssertTrue(app.buttons["destination-depart-date"].exists)
        XCTAssertTrue(app.buttons["destination-return-date"].exists)
        XCTAssertTrue(app.buttons["destination-travelers"].exists)
        XCTAssertFalse(app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Share")).firstMatch.exists)
        XCTAssertFalse(app.buttons["Save"].exists)
        XCTAssertTrue(app.buttons["Choose dates"].exists)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    @MainActor
    func testHomeDestinationSearchOpensRealSearchResults() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["Search Flights"].waitForExistence(timeout: 30))
        app.scrollViews["root-home"].swipeUp()
        let destination = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH %@", "home-featured-destination-")
        ).firstMatch
        guard destination.waitForExistence(timeout: 10) else {
            throw XCTSkip("Live destination data unavailable.")
        }
        destination.tap()

        app.buttons["destination-travelers"].tap()
        let adults = app.steppers["destination-adults"]
        XCTAssertTrue(adults.waitForExistence(timeout: 15))
        adults.buttons["destination-adults-Increment"].tap()
        adults.buttons["destination-adults-Increment"].tap()
        app.buttons["Apply"].tap()
        XCTAssertEqual(app.buttons["destination-travelers"].label, "Travelers, 3 Adults")
        app.buttons["Choose dates"].tap()
        XCTAssertTrue(app.staticTexts["Select departure"].waitForExistence(timeout: 5))
        app.buttons["Select date"].tap()
        XCTAssertTrue(app.staticTexts["Select return"].waitForExistence(timeout: 5))
        app.buttons["Select date"].tap()
        let search = app.buttons["Search flights"]
        XCTAssertTrue(search.waitForExistence(timeout: 15))
        let selectedDates = XCTAttachment(screenshot: app.screenshot())
        selectedDates.lifetime = .keepAlways
        add(selectedDates)
        search.tap()

        XCTAssertTrue(app.staticTexts["Search Results"].waitForExistence(timeout: 30))
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "3 Adults")).firstMatch.waitForExistence(timeout: 15))
        XCTAssertFalse(app.buttons["main-tab-home"].exists)
    }

    @MainActor
    func testHomeSearchFieldsStayInsideScreenBounds() {
        let app = XCUIApplication()
        app.launch()
        let searchFlights = app.buttons["Search Flights"]
        let cabinClass = app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH %@", "Cabin Class")
        ).firstMatch

        XCTAssertTrue(searchFlights.waitForExistence(timeout: 30))
        XCTAssertTrue(cabinClass.waitForExistence(timeout: 5))
        let rootScrollView = app.scrollViews["root-home"]
        let leadingMargin = searchFlights.frame.minX - app.frame.minX
        let trailingMargin = app.frame.maxX - searchFlights.frame.maxX

        let layout = "window=\(app.frame), rootScroll=\(rootScrollView.frame), search=\(searchFlights.frame)"
        XCTAssertGreaterThanOrEqual(leadingMargin, 0, layout)
        XCTAssertGreaterThanOrEqual(trailingMargin, 0, layout)
        XCTAssertEqual(leadingMargin, trailingMargin, accuracy: 1, layout)
        XCTAssertLessThanOrEqual(cabinClass.frame.maxX, app.frame.maxX, layout)
    }

    @MainActor
    func testHomeAndCustomTabsFitIPadLandscape() throws {
        let model = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
        guard model.hasPrefix("iPad") else { throw XCTSkip("Landscape acceptance runs on iPad.") }

        let app = XCUIApplication()
        app.launchArguments.append("--reset-auth-session")
        app.launch()
        XCTAssertTrue(app.buttons["main-tab-home"].waitForExistence(timeout: 30))
        app.buttons["main-tab-explore"].tap()
        XCTAssertTrue(app.scrollViews["root-explore"].waitForExistence(timeout: 10))

        let device = XCUIDevice.shared
        device.orientation = .landscapeLeft
        defer { device.orientation = .portrait }
        let landscape = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in app.frame.width > app.frame.height },
            object: app
        )
        XCTAssertEqual(XCTWaiter.wait(for: [landscape], timeout: 10), .completed)
        let homeTab = app.buttons["main-tab-home"]
        XCTAssertTrue(homeTab.isHittable)
        homeTab.tap()
        XCTAssertTrue(homeTab.isSelected)

        let searchFlights = app.buttons["Search Flights"]
        XCTAssertTrue(searchFlights.waitForExistence(timeout: 30))
        XCTAssertGreaterThan(app.frame.width, app.frame.height, "Expected app window to rotate to landscape.")
        XCTAssertGreaterThanOrEqual(searchFlights.frame.minX, app.frame.minX)
        XCTAssertLessThanOrEqual(searchFlights.frame.maxX, app.frame.maxX)

        let tabs = ["home", "explore", "trips", "profile"].map { app.buttons["main-tab-\($0)"] }
        let tabFrames = tabs.map { "\($0.identifier): \($0.frame)" }.joined(separator: "\n")
        let root = app.scrollViews["root-home"]
        let layout = "app=\(app.frame)\nroot=\(root.frame)\nsearch=\(searchFlights.frame)\ntabs:\n\(tabFrames)"
        let diagnostics = XCTAttachment(string: layout)
        diagnostics.name = "iPad landscape layout metrics"
        diagnostics.lifetime = .keepAlways
        add(diagnostics)

        XCTAssertEqual(searchFlights.frame.midX, app.frame.midX, accuracy: 1, layout)
        for tab in tabs {
            XCTAssertTrue(tab.waitForExistence(timeout: 5))
            XCTAssertTrue(tab.isHittable)
            XCTAssertGreaterThanOrEqual(tab.frame.minX, app.frame.minX)
            XCTAssertLessThanOrEqual(tab.frame.maxX, app.frame.maxX)
        }
        XCTAssertEqual(tabs.filter(\.isSelected).count, 1)
        XCTAssertEqual(app.tabBars.count, 0)

        tabs[3].tap()
        let profileRoot = app.descendants(matching: .any).matching(identifier: "root-profile").firstMatch
        XCTAssertTrue(profileRoot.waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertTrue(tabs[3].isSelected)
        tabs[0].tap()
        let homeRoot = app.descendants(matching: .any).matching(identifier: "root-home").firstMatch
        XCTAssertTrue(homeRoot.waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertTrue(tabs[0].isSelected)

        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = "iPad landscape custom tab container"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    @MainActor
    func testSignupThenProfileSignIn() throws {
        let email = try requiredEnvironmentValue("NEXUS_TEST_EMAIL")
        let password = try requiredEnvironmentValue("NEXUS_TEST_PASSWORD")
        let app = XCUIApplication()
        app.launch()

        app.buttons["main-tab-profile"].tap()
        XCTAssertTrue(app.buttons["Sign in"].waitForExistence(timeout: 15))
        app.buttons["Sign in"].tap()
        XCTAssertTrue(app.staticTexts["Welcome back"].waitForExistence(timeout: 15))
        app.buttons["Sign up"].tap()
        XCTAssertTrue(app.staticTexts["Create your account"].waitForExistence(timeout: 10))

        app.textFields["Full name"].tap()
        app.textFields["Full name"].typeText("Nexus QA Traveler")
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(email)
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(password)
        app.secureTextFields["Confirm password"].tap()
        app.secureTextFields["Confirm password"].typeText(password)
        app.switches["I agree to the terms and privacy policy."].tap()
        app.buttons["Create account"].tap()

        XCTAssertTrue(app.staticTexts["Profile"].waitForExistence(timeout: 30))
        XCTAssertTrue(app.staticTexts["Nexus QA Traveler"].waitForExistence(timeout: 30))
        app.buttons["Log out"].tap()
        XCTAssertTrue(app.sheets.buttons["Log out"].waitForExistence(timeout: 10))
        app.sheets.buttons["Log out"].tap()
        XCTAssertTrue(app.staticTexts["Your travel account"].waitForExistence(timeout: 20))

        app.buttons["Sign in"].tap()
        XCTAssertTrue(app.staticTexts["Welcome back"].waitForExistence(timeout: 15))
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(email)
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(password)
        app.buttons["Sign in"].tap()

        XCTAssertTrue(app.staticTexts["Nexus QA Traveler"].waitForExistence(timeout: 30))
        XCTAssertFalse(app.staticTexts["Welcome back"].exists)
    }

    @MainActor
    func testGuestTabsExposeSignInActions() {
        let app = XCUIApplication()
        app.launchArguments.append("--reset-auth-session")
        app.launch()

        XCTAssertTrue(app.buttons["Search Flights"].waitForExistence(timeout: 30))
        let tripsTab = app.buttons["main-tab-trips"]
        XCTAssertTrue(tripsTab.waitForExistence(timeout: 15))
        tripsTab.tap()
        XCTAssertTrue(app.staticTexts["Keep every trip in one place"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.buttons["Sign in"].exists)

        app.buttons["main-tab-profile"].tap()
        XCTAssertTrue(app.staticTexts["Your travel account"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.buttons["Sign in"].exists)
    }

    @MainActor
    func testSuppliedCredentialsReturnActionableError() throws {
        let email = try requiredEnvironmentValue("NEXUS_TEST_EMAIL")
        let password = try requiredEnvironmentValue("NEXUS_TEST_INVALID_PASSWORD")
        let app = XCUIApplication()
        app.launch()

        app.buttons["main-tab-profile"].tap()
        let profileSignIn = app.buttons["Sign in"]
        XCTAssertTrue(profileSignIn.waitForExistence(timeout: 15))
        profileSignIn.tap()
        XCTAssertTrue(app.staticTexts["Welcome back"].waitForExistence(timeout: 15))

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(email)
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(password)
        app.buttons["Sign in"].tap()

        XCTAssertTrue(app.staticTexts["Email or password is incorrect."].waitForExistence(timeout: 20))
        XCTAssertFalse(app.buttons["Signing in…"].exists)
    }

    @MainActor
    func testValidUnverifiedAccountSignsIn() throws {
        let email = try requiredEnvironmentValue("NEXUS_TEST_EMAIL")
        let password = try requiredEnvironmentValue("NEXUS_TEST_PASSWORD")
        let app = XCUIApplication()
        app.launch()

        app.buttons["main-tab-profile"].tap()
        let profileSignIn = app.buttons["Sign in"]
        XCTAssertTrue(profileSignIn.waitForExistence(timeout: 15))
        profileSignIn.tap()
        XCTAssertTrue(app.staticTexts["Welcome back"].waitForExistence(timeout: 15))
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(email)
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(password)
        app.buttons["Sign in"].tap()

        XCTAssertTrue(app.staticTexts["Profile"].waitForExistence(timeout: 20))
        XCTAssertFalse(app.staticTexts["Welcome back"].exists)
    }

    @MainActor
    func testSearchOpensFlightDetailsAndStartsBooking() {
        let app = XCUIApplication()
        app.launch()

        let search = app.buttons["Search Flights"]
        let scrollView = app.scrollViews.firstMatch
        for _ in 0..<3 where !search.isHittable {
            scrollView.swipeUp()
        }
        XCTAssertTrue(search.waitForExistence(timeout: 30))
        search.tap()

        XCTAssertTrue(app.staticTexts["Search Results"].waitForExistence(timeout: 120))
        let offer = app.buttons.matching(NSPredicate(format: "label CONTAINS 'ETB'")).firstMatch
        XCTAssertTrue(offer.waitForExistence(timeout: 10))
        offer.tap()

        XCTAssertTrue(app.navigationBars["Flight Details"].waitForExistence(timeout: 90))
        XCTAssertFalse(app.staticTexts["Could not load flight details"].exists)
        let continueButton = app.buttons["Continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 10))
        continueButton.tap()

        let fareChanged = app.alerts["Fare changed"]
        if fareChanged.waitForExistence(timeout: 30) {
            fareChanged.buttons["Continue"].tap()
        }
        XCTAssertTrue(app.navigationBars["Passenger Details"].waitForExistence(timeout: 60))
        XCTAssertTrue(app.textFields["First name"].waitForExistence(timeout: 10))
    }

    private func requiredEnvironmentValue(_ name: String) throws -> String {
        guard let value = ProcessInfo.processInfo.environment[name],
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw XCTSkip("Missing " + name + "; credential UI test skipped.")
        }
        return value
    }
}
