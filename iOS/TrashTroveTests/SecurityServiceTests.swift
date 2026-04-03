import XCTest
@testable import TrashTrove

final class SecurityServiceTests: XCTestCase {
    private let security = SecurityService.shared

    // MARK: - Input Sanitization Tests

    func testSanitizeStripsHTMLTags() {
        let input = "<script>alert('xss')</script>Hello World"
        let result = security.stripHTML(input)
        XCTAssertFalse(result.contains("<script>"))
        XCTAssertFalse(result.contains("</script>"))
        XCTAssertTrue(result.contains("Hello World"))
    }

    func testSanitizeStringTrimsWhitespace() {
        let input = "  Hello World  "
        let result = security.sanitizeString(input, maxLength: 100)
        XCTAssertEqual(result, "Hello World")
    }

    func testSanitizeStringLimitsLength() {
        let longString = String(repeating: "a", count: 2000)
        let result = security.sanitizeString(longString, maxLength: 500)
        XCTAssertEqual(result.count, 500)
    }

    func testSanitizeStringStripsHTMLAndTrims() {
        let input = "  <b>Bold</b> text  "
        let result = security.sanitizeString(input, maxLength: 100)
        XCTAssertEqual(result, "Bold text")
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

    // MARK: - State Validation Tests

    func testValidStateCodes() {
        XCTAssertTrue(security.isValidStateCode("CA"))
        XCTAssertTrue(security.isValidStateCode("TX"))
        XCTAssertTrue(security.isValidStateCode("ny")) // case insensitive
    }

    func testInvalidStateCodes() {
        XCTAssertFalse(security.isValidStateCode(""))
        XCTAssertFalse(security.isValidStateCode("XX"))
        XCTAssertFalse(security.isValidStateCode("California"))
    }

    // MARK: - Rate Limiting Tests

    func testRateLimitAllowsInitialRequests() {
        security.resetRateLimits()
        let result = security.checkRateLimit(.createSale)
        XCTAssertTrue(result.allowed)
        XCTAssertGreaterThan(result.remaining, 0)
    }

    func testRateLimitBlocksExcessiveRequests() {
        security.resetRateLimits()
        // Use up all createSale requests (limit is 5)
        for _ in 0..<5 {
            _ = security.checkRateLimit(.createSale)
        }
        let result = security.checkRateLimit(.createSale)
        XCTAssertFalse(result.allowed)
        XCTAssertEqual(result.remaining, 0)
    }

    // MARK: - Profanity Detection Tests

    func testProfanityDetection() {
        XCTAssertTrue(security.containsProfanityPlaceholder("test1234 listing"))
        XCTAssertTrue(security.containsProfanityPlaceholder("asdfasdf"))
        XCTAssertFalse(security.containsProfanityPlaceholder("Beautiful antique furniture"))
    }
}
