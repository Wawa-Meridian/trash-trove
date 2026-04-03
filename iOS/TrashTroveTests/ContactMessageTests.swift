import XCTest
@testable import TrashTrove

final class ContactMessageTests: XCTestCase {

    func testContactMessageEncoding() throws {
        let message = ContactMessage(
            saleId: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!,
            senderName: "Alice",
            senderEmail: "alice@example.com",
            message: "Is the couch still available?"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        XCTAssertNotNil(json)
        XCTAssertEqual(json?["message"] as? String, "Is the couch still available?")
    }

    func testContactMessageDecodingRoundTrip() throws {
        let message = ContactMessage(
            saleId: UUID(),
            senderName: "Bob",
            senderEmail: "bob@test.com",
            message: "What time does it start?"
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(message)
        let decoded = try decoder.decode(ContactMessage.self, from: data)

        XCTAssertEqual(decoded.senderName, "Bob")
        XCTAssertEqual(decoded.senderEmail, "bob@test.com")
        XCTAssertEqual(decoded.message, "What time does it start?")
    }
}
