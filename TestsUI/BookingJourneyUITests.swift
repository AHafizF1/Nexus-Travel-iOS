import XCTest

final class BookingJourneyUITests: XCTestCase {
    @MainActor
    func testSignupThenProfileSignIn() throws {
        let email = try requiredEnvironmentValue("NEXUS_TEST_EMAIL")
        let password = try requiredEnvironmentValue("NEXUS_TEST_PASSWORD")
        let app = XCUIApplication()
        app.launch()

        app.buttons["Profile"].tap()
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

        XCTAssertTrue(app.buttons["Flight"].waitForExistence(timeout: 30))
        let tripsTab = app.buttons["Trips"]
        XCTAssertTrue(tripsTab.waitForExistence(timeout: 15))
        tripsTab.tap()
        XCTAssertTrue(app.staticTexts["Keep every trip in one place"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.buttons["Sign in"].exists)

        app.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Your travel account"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.buttons["Sign in"].exists)
    }

    @MainActor
    func testSuppliedCredentialsReturnActionableError() throws {
        let email = try requiredEnvironmentValue("NEXUS_TEST_EMAIL")
        let password = try requiredEnvironmentValue("NEXUS_TEST_INVALID_PASSWORD")
        let app = XCUIApplication()
        app.launch()

        app.buttons["Profile"].tap()
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

        app.buttons["Profile"].tap()
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

        let flight = app.buttons["Flight"]
        XCTAssertTrue(flight.waitForExistence(timeout: 30))
        flight.tap()

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
