import XCTest
@testable import TrashTrove

final class SupabaseServiceTests: XCTestCase {

    func testErrorDescriptions() {
        let errors: [SupabaseError] = [
            .invalidURL,
            .invalidResponse,
            .httpError(statusCode: 400, message: "Bad Request"),
            .rateLimited(retryAfter: 60),
            .notFound,
            .unauthorized,
            .serverError,
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription, "Error \(error) should have a description")
            XCTAssertFalse(error.errorDescription!.isEmpty, "Error description should not be empty")
        }
    }

    func testHTTPErrorIncludesStatusCode() {
        let error = SupabaseError.httpError(statusCode: 429, message: "Rate limited")
        XCTAssertTrue(error.errorDescription?.contains("429") ?? false)
    }

    func testRateLimitedError() {
        let error = SupabaseError.rateLimited(retryAfter: 30)
        XCTAssertTrue(error.errorDescription?.lowercased().contains("too many") ?? false)
    }

    func testAPIConfigEndpoints() {
        XCTAssertTrue(APIConfig.apiBaseURL.hasPrefix("https://"))
        XCTAssertTrue(APIConfig.apiBaseURL.contains("trashtrove"))
    }
}
