import XCTest
@testable import TrashTrove

final class SaleReportModelTests: XCTestCase {

    func testReportReasonCases() {
        let cases = ReportReason.allCases
        XCTAssertEqual(cases.count, 5)
        XCTAssertTrue(cases.contains(.spam))
        XCTAssertTrue(cases.contains(.scam))
        XCTAssertTrue(cases.contains(.inappropriate))
        XCTAssertTrue(cases.contains(.duplicate))
        XCTAssertTrue(cases.contains(.other))
    }

    func testReportReasonDisplayNames() {
        XCTAssertEqual(ReportReason.spam.displayName, "Spam")
        XCTAssertEqual(ReportReason.scam.displayName, "Scam / Fraud")
        XCTAssertEqual(ReportReason.inappropriate.displayName, "Inappropriate Content")
        XCTAssertEqual(ReportReason.duplicate.displayName, "Duplicate Listing")
        XCTAssertEqual(ReportReason.other.displayName, "Other")
    }

    func testReportReasonRawValues() {
        XCTAssertEqual(ReportReason.spam.rawValue, "spam")
        XCTAssertEqual(ReportReason.scam.rawValue, "scam")
        XCTAssertEqual(ReportReason.inappropriate.rawValue, "inappropriate")
        XCTAssertEqual(ReportReason.duplicate.rawValue, "duplicate")
        XCTAssertEqual(ReportReason.other.rawValue, "other")
    }

    func testSaleReportEncoding() throws {
        let report = SaleReport(
            saleId: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!,
            reason: "spam",
            details: "This is not a real sale"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(report)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        XCTAssertEqual(json?["reason"] as? String, "spam")
        XCTAssertEqual(json?["details"] as? String, "This is not a real sale")
    }

    func testSaleReportNilDetails() throws {
        let report = SaleReport(
            saleId: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!,
            reason: "duplicate",
            details: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(report)
        XCTAssertNotNil(data)
    }
}
