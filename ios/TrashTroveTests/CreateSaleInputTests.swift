import XCTest
@testable import TrashTrove

final class CreateSaleInputTests: XCTestCase {

    func testCreateSaleInputEncoding() throws {
        let input = CreateSaleInput(
            title: "Weekend Garage Sale",
            description: "Lots of furniture and toys",
            categories: ["Furniture", "Toys & Games"],
            address: "789 Elm St",
            city: "Portland",
            state: "OR",
            zip: "97201",
            saleDate: "2026-04-12",
            startTime: "09:00",
            endTime: "15:00",
            sellerName: "Bob Johnson",
            sellerEmail: "bob@example.com"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(input)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        XCTAssertEqual(json?["title"] as? String, "Weekend Garage Sale")
        XCTAssertEqual(json?["city"] as? String, "Portland")
        XCTAssertEqual(json?["state"] as? String, "OR")
        XCTAssertEqual(json?["zip"] as? String, "97201")

        let categories = json?["categories"] as? [String]
        XCTAssertEqual(categories?.count, 2)
        XCTAssertTrue(categories?.contains("Furniture") ?? false)
    }

    func testCreateSaleInputDecodingRoundTrip() throws {
        let input = CreateSaleInput(
            title: "Estate Sale",
            description: "Full estate liquidation",
            categories: ["Everything Must Go"],
            address: "100 Pine Ave",
            city: "Seattle",
            state: "WA",
            zip: "98101",
            saleDate: "2026-04-19",
            startTime: "07:00",
            endTime: "16:00",
            sellerName: "Sarah",
            sellerEmail: "sarah@example.com"
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(input)
        let decoded = try decoder.decode(CreateSaleInput.self, from: data)

        XCTAssertEqual(decoded.title, input.title)
        XCTAssertEqual(decoded.description, input.description)
        XCTAssertEqual(decoded.categories, input.categories)
        XCTAssertEqual(decoded.sellerEmail, input.sellerEmail)
    }
}
