import XCTest
@testable import TrashTrove

final class AnalyticsServiceTests: XCTestCase {
    private let analytics = AnalyticsService.shared

    override func setUp() {
        super.setUp()
        analytics.flush()
    }

    func testTrackEvent() {
        analytics.track(.saleViewed, properties: ["sale_id": "test-123"])
        // Should not crash and event should be recorded
        XCTAssertGreaterThan(analytics.pendingEventCount, 0)
    }

    func testTrackScreenView() {
        analytics.trackScreen("HomeView")
        XCTAssertGreaterThan(analytics.pendingEventCount, 0)
    }

    func testFlushClearsEvents() {
        analytics.track(.appOpened)
        analytics.track(.saleViewed, properties: ["sale_id": "abc"])
        analytics.flush()
        XCTAssertEqual(analytics.pendingEventCount, 0)
    }

    func testSessionIdExists() {
        XCTAssertFalse(analytics.sessionId.isEmpty)
    }

    func testMultipleEventsAccumulate() {
        analytics.flush()
        analytics.track(.appOpened)
        analytics.track(.saleSearched, properties: ["query": "furniture"])
        analytics.track(.saleFavorited, properties: ["sale_id": "123"])
        XCTAssertEqual(analytics.pendingEventCount, 3)
    }
}
