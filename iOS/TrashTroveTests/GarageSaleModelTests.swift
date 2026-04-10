import XCTest
@testable import TrashTrove

final class GarageSaleModelTests: XCTestCase {

    // MARK: - Test Data

    private let sampleJSON = """
    {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "title": "Big Moving Sale",
        "description": "Furniture, electronics, and more",
        "categories": ["Furniture", "Electronics"],
        "address": "123 Main St",
        "city": "Springfield",
        "state": "IL",
        "zip": "62701",
        "latitude": 39.7817,
        "longitude": -89.6501,
        "sale_date": "2026-04-05",
        "start_time": "08:00",
        "end_time": "14:00",
        "photos": [
            {
                "id": "660e8400-e29b-41d4-a716-446655440001",
                "sale_id": "550e8400-e29b-41d4-a716-446655440000",
                "url": "https://example.com/photo1.jpg",
                "caption": "Living room set",
                "display_order": 0
            }
        ],
        "seller_name": "Jane Smith",
        "seller_email": "jane@example.com",
        "created_at": "2026-04-01T10:00:00Z",
        "is_active": true,
        "manage_token": null,
        "distance_miles": null
    }
    """.data(using: .utf8)!

    private let minimalJSON = """
    {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "title": "Yard Sale",
        "description": "Misc items",
        "categories": [],
        "address": "456 Oak Ave",
        "city": "Dallas",
        "state": "TX",
        "zip": "75201",
        "latitude": null,
        "longitude": null,
        "sale_date": "2026-04-12",
        "start_time": "09:00",
        "end_time": "15:00",
        "photos": [],
        "seller_name": "John",
        "seller_email": "john@example.com",
        "created_at": "2026-04-01T10:00:00Z",
        "is_active": true,
        "manage_token": null,
        "distance_miles": null
    }
    """.data(using: .utf8)!

    // MARK: - Decoding Tests

    func testDecodeFullSale() throws {
        let decoder = JSONDecoder()
        let sale = try decoder.decode(GarageSale.self, from: sampleJSON)

        XCTAssertEqual(sale.id, UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000"))
        XCTAssertEqual(sale.title, "Big Moving Sale")
        XCTAssertEqual(sale.description, "Furniture, electronics, and more")
        XCTAssertEqual(sale.categories, ["Furniture", "Electronics"])
        XCTAssertEqual(sale.address, "123 Main St")
        XCTAssertEqual(sale.city, "Springfield")
        XCTAssertEqual(sale.state, "IL")
        XCTAssertEqual(sale.zip, "62701")
        XCTAssertEqual(sale.latitude, 39.7817)
        XCTAssertEqual(sale.longitude, -89.6501)
        XCTAssertEqual(sale.saleDate, "2026-04-05")
        XCTAssertEqual(sale.startTime, "08:00")
        XCTAssertEqual(sale.endTime, "14:00")
        XCTAssertEqual(sale.sellerName, "Jane Smith")
        XCTAssertEqual(sale.sellerEmail, "jane@example.com")
        XCTAssertTrue(sale.isActive)
        XCTAssertNil(sale.manageToken)
        XCTAssertNil(sale.distanceMiles)
    }

    func testDecodePhotos() throws {
        let decoder = JSONDecoder()
        let sale = try decoder.decode(GarageSale.self, from: sampleJSON)

        XCTAssertEqual(sale.photos.count, 1)
        XCTAssertEqual(sale.photos[0].url, "https://example.com/photo1.jpg")
        XCTAssertEqual(sale.photos[0].caption, "Living room set")
        XCTAssertEqual(sale.photos[0].displayOrder, 0)
    }

    func testDecodeMinimalSale() throws {
        let decoder = JSONDecoder()
        let sale = try decoder.decode(GarageSale.self, from: minimalJSON)

        XCTAssertEqual(sale.title, "Yard Sale")
        XCTAssertNil(sale.latitude)
        XCTAssertNil(sale.longitude)
        XCTAssertTrue(sale.photos.isEmpty)
        XCTAssertTrue(sale.categories.isEmpty)
    }

    // MARK: - Computed Property Tests

    func testHasLocation() throws {
        let decoder = JSONDecoder()
        let saleWithLocation = try decoder.decode(GarageSale.self, from: sampleJSON)
        let saleWithoutLocation = try decoder.decode(GarageSale.self, from: minimalJSON)

        XCTAssertTrue(saleWithLocation.hasLocation)
        XCTAssertFalse(saleWithoutLocation.hasLocation)
    }

    func testFullAddress() throws {
        let decoder = JSONDecoder()
        let sale = try decoder.decode(GarageSale.self, from: sampleJSON)

        XCTAssertEqual(sale.fullAddress, "123 Main St, Springfield, IL 62701")
    }

    func testFormattedTimeRange() throws {
        let decoder = JSONDecoder()
        let sale = try decoder.decode(GarageSale.self, from: sampleJSON)

        XCTAssertTrue(sale.formattedTimeRange.contains("8:00 AM"))
        XCTAssertTrue(sale.formattedTimeRange.contains("2:00 PM"))
    }

    func testFormattedDate() throws {
        let decoder = JSONDecoder()
        let sale = try decoder.decode(GarageSale.self, from: sampleJSON)

        XCTAssertTrue(sale.formattedDate.contains("April"))
        XCTAssertTrue(sale.formattedDate.contains("2026"))
    }

    func testFormattedDistanceNearby() throws {
        let decoder = JSONDecoder()
        var sale = try decoder.decode(GarageSale.self, from: sampleJSON)
        // distanceMiles is nil, so formattedDistance should be nil
        XCTAssertNil(sale.formattedDistance)
    }

    func testPrimaryPhoto() throws {
        let decoder = JSONDecoder()
        let sale = try decoder.decode(GarageSale.self, from: sampleJSON)

        XCTAssertNotNil(sale.primaryPhoto)
        XCTAssertEqual(sale.primaryPhoto?.url, "https://example.com/photo1.jpg")

        let saleNoPhotos = try decoder.decode(GarageSale.self, from: minimalJSON)
        XCTAssertNil(saleNoPhotos.primaryPhoto)
    }

    // MARK: - Equatable Tests

    func testEquality() throws {
        let decoder = JSONDecoder()
        let sale1 = try decoder.decode(GarageSale.self, from: sampleJSON)
        let sale2 = try decoder.decode(GarageSale.self, from: sampleJSON)

        XCTAssertEqual(sale1, sale2)
    }

    // MARK: - Encoding Tests

    func testEncodeAndDecode() throws {
        let decoder = JSONDecoder()
        let sale = try decoder.decode(GarageSale.self, from: sampleJSON)

        let encoder = JSONEncoder()
        let encoded = try encoder.encode(sale)
        let decoded = try decoder.decode(GarageSale.self, from: encoded)

        XCTAssertEqual(sale.id, decoded.id)
        XCTAssertEqual(sale.title, decoded.title)
        XCTAssertEqual(sale.city, decoded.city)
    }
}
