import XCTest
@testable import TrashTrove

final class ConstantsTests: XCTestCase {

    // MARK: - Sale Categories Tests

    func testSaleCategoriesCount() {
        XCTAssertEqual(SALE_CATEGORIES.count, 18)
    }

    func testSaleCategoriesContainsExpectedValues() {
        XCTAssertTrue(SALE_CATEGORIES.contains("Furniture"))
        XCTAssertTrue(SALE_CATEGORIES.contains("Electronics"))
        XCTAssertTrue(SALE_CATEGORIES.contains("Everything Must Go"))
        XCTAssertTrue(SALE_CATEGORIES.contains("Other"))
    }

    func testSaleCategoriesNoDuplicates() {
        let uniqueCategories = Set(SALE_CATEGORIES)
        XCTAssertEqual(uniqueCategories.count, SALE_CATEGORIES.count)
    }

    // MARK: - US States Tests

    func testUSStatesCount() {
        XCTAssertEqual(US_STATES.count, 51) // 50 states + DC
    }

    func testUSStatesContainsAllStates() {
        XCTAssertEqual(US_STATES["CA"], "California")
        XCTAssertEqual(US_STATES["TX"], "Texas")
        XCTAssertEqual(US_STATES["NY"], "New York")
        XCTAssertEqual(US_STATES["FL"], "Florida")
        XCTAssertEqual(US_STATES["DC"], "District of Columbia")
    }

    func testUSStatesKeyFormat() {
        for key in US_STATES.keys {
            XCTAssertEqual(key.count, 2, "State code \(key) should be 2 characters")
            XCTAssertEqual(key, key.uppercased(), "State code \(key) should be uppercase")
        }
    }

    func testUSStatesValueNotEmpty() {
        for (code, name) in US_STATES {
            XCTAssertFalse(name.isEmpty, "State name for \(code) should not be empty")
        }
    }

    // MARK: - API Configuration Tests

    func testAPIEndpointsNotEmpty() {
        XCTAssertFalse(API.baseURL.isEmpty)
        XCTAssertFalse(API.salesEndpoint.isEmpty)
        XCTAssertFalse(API.nearbySalesEndpoint.isEmpty)
    }

    func testAPISaleEndpointContainsId() {
        let id = UUID()
        let endpoint = API.saleEndpoint(id: id)
        XCTAssertTrue(endpoint.contains(id.uuidString))
    }

    // MARK: - Rate Limit Constants Tests

    func testRateLimitsAreReasonable() {
        XCTAssertGreaterThan(RateLimit.maxCreateSalesPerHour, 0)
        XCTAssertGreaterThan(RateLimit.maxContactMessagesPerHour, 0)
        XCTAssertGreaterThan(RateLimit.maxReportsPerHour, 0)
        XCTAssertLessThanOrEqual(RateLimit.maxCreateSalesPerHour, 20)
    }
}
