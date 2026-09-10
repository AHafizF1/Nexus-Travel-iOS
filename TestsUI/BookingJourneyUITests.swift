import XCTest

final class BookingJourneyUITests: XCTestCase {
    @MainActor
    func testGuestTabsExposeSignInActions() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Trips"].tap()
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
