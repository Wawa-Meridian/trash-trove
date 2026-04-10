import XCTest

final class TrashTroveUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Tab Bar Tests

    func testTabBarExists() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
    }

    func testAllTabsPresent() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.buttons["Home"].exists)
        XCTAssertTrue(tabBar.buttons["Browse"].exists)
        XCTAssertTrue(tabBar.buttons["Nearby"].exists)
        XCTAssertTrue(tabBar.buttons["Favorites"].exists)
        XCTAssertTrue(tabBar.buttons["Settings"].exists)
    }

    func testCanSwitchTabs() {
        let tabBar = app.tabBars.firstMatch

        tabBar.buttons["Browse"].tap()
        XCTAssertTrue(app.navigationBars.staticTexts["Browse Garage Sales"].waitForExistence(timeout: 3))

        tabBar.buttons["Favorites"].tap()
        // Should show favorites screen (empty state or content)
        XCTAssertTrue(tabBar.buttons["Favorites"].isSelected)

        tabBar.buttons["Settings"].tap()
        XCTAssertTrue(tabBar.buttons["Settings"].isSelected)
    }

    // MARK: - Home Screen Tests

    func testHomeScreenElements() {
        // Hero section should have the main title
        let heroTitle = app.staticTexts["Find Weekend Garage Sales"]
        XCTAssertTrue(heroTitle.waitForExistence(timeout: 5))

        // Browse Sales button should exist
        let browseButton = app.buttons["Browse Sales"]
        XCTAssertTrue(browseButton.exists)

        // List Your Sale button should exist
        let listButton = app.buttons["List Your Sale"]
        XCTAssertTrue(listButton.exists)
    }

    // MARK: - Browse Screen Tests

    func testBrowseScreenShowsStates() {
        app.tabBars.firstMatch.buttons["Browse"].tap()

        // Should show at least some states
        let stateGrid = app.scrollViews.firstMatch
        XCTAssertTrue(stateGrid.waitForExistence(timeout: 3))
    }

    // MARK: - Favorites Empty State Tests

    func testFavoritesEmptyState() {
        app.tabBars.firstMatch.buttons["Favorites"].tap()

        let emptyMessage = app.staticTexts["No favorites yet"]
        XCTAssertTrue(emptyMessage.waitForExistence(timeout: 3))

        let browseButton = app.buttons["Browse Sales"]
        XCTAssertTrue(browseButton.exists)
    }

    // MARK: - Settings Screen Tests

    func testSettingsScreenElements() {
        app.tabBars.firstMatch.buttons["Settings"].tap()

        // Should show legal links
        let privacyLink = app.buttons["Privacy Policy"]
        let termsLink = app.buttons["Terms of Service"]

        XCTAssertTrue(privacyLink.waitForExistence(timeout: 3))
        XCTAssertTrue(termsLink.exists)
    }

    func testNavigateToPrivacyPolicy() {
        app.tabBars.firstMatch.buttons["Settings"].tap()
        app.buttons["Privacy Policy"].tap()

        let title = app.navigationBars.staticTexts["Privacy Policy"]
        XCTAssertTrue(title.waitForExistence(timeout: 3))
    }

    func testNavigateToTermsOfService() {
        app.tabBars.firstMatch.buttons["Settings"].tap()
        app.buttons["Terms of Service"].tap()

        let title = app.navigationBars.staticTexts["Terms of Service"]
        XCTAssertTrue(title.waitForExistence(timeout: 3))
    }
}
