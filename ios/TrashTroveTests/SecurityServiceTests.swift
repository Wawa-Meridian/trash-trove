import XCTest
@testable import TrashTrove

final class SecurityServiceTests: XCTestCase {
    private let security = SecurityService.shared

    // MARK: - Input Sanitization Tests

    func testSanitizeStripsHTMLTags() {
        let input = "<script>alert('xss')</script>Hello World"
        let result = security.sanitize(input)
        XCTAssertFalse(result.contains("<script>"))
        XCTAssertFalse(result.contains("</script>"))
        XCTAssertTrue(result.contains("Hello World"))
    }

    func testSanitizeTrimsWhitespace() {
        let input = "  Hello World  "
        let result = security.sanitize(input)
        XCTAssertEqual(result, "Hello World")
    }

    func testSanitizeLimitsLength() {
        let longString = String(repeating: "a", count: 2000)
        let result = security.sanitize(longString, maxLength: 500)
        XCTAssertEqual(result.count, 500)
    }

    func testSanitizeDefaultMaxLength() {
        let longString = String(repeating: "b", count: 5000)
        let result = security.sanitize(longString)
        XCTAssertLessThanOrEqual(result.count, 1000)
    }

    // MARK: - Email Validation Tests

    func testValidEmails() {
        XCTAssertTrue(security.isValidEmail("user@example.com"))
        XCTAssertTrue(security.isValidEmail("test.name@domain.co.uk"))
        XCTAssertTrue(security.isValidEmail("user+tag@gmail.com"))
    }

    func testInvalidEmails() {
        XCTAssertFalse(security.isValidEmail(""))
        XCTAssertFalse(security.isValidEmail("notanemail"))
        XCTAssertFalse(security.isValidEmail("@domain.com"))
        XCTAssertFalse(security.isValidEmail("user@"))
        XCTAssertFalse(security.isValidEmail("user@.com"))
    }

    // MARK: - ZIP Code Validation Tests

    func testValidZIPCodes() {
        XCTAssertTrue(security.isValidZIP("12345"))
        XCTAssertTrue(security.isValidZIP("12345-6789"))
    }

    func testInvalidZIPCodes() {
        XCTAssertFalse(security.isValidZIP(""))
        XCTAssertFalse(security.isValidZIP("1234"))
        XCTAssertFalse(security.isValidZIP("123456"))
        XCTAssertFalse(security.isValidZIP("abcde"))
        XCTAssertFalse(security.isValidZIP("12345-"))
    }

    // MARK: - Rate Limiting Tests

    func testRateLimitAllowsInitialRequests() {
        let key = "test_rate_\(UUID().uuidString)"
        XCTAssertTrue(security.checkRateLimit(key: key, limit: 5, windowSeconds: 60))
    }

    func testRateLimitBlocksExcessiveRequests() {
        let key = "test_rate_block_\(UUID().uuidString)"
        // Use up all the requests
        for _ in 0..<5 {
            _ = security.checkRateLimit(key: key, limit: 5, windowSeconds: 60)
        }
        // Should be blocked now
        XCTAssertFalse(security.checkRateLimit(key: key, limit: 5, windowSeconds: 60))
    }
}
