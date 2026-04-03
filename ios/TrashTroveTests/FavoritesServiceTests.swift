import XCTest
@testable import TrashTrove

final class FavoritesServiceTests: XCTestCase {
    private var service: FavoritesService!
    private let testKey = "trashtrove_favorites_test"

    override func setUp() {
        super.setUp()
        // Clear test defaults
        UserDefaults.standard.removeObject(forKey: "trashtrove_favorites")
        service = FavoritesService.shared
        service.clear()
    }

    override func tearDown() {
        service.clear()
        super.tearDown()
    }

    func testInitiallyEmpty() {
        XCTAssertTrue(service.favorites.isEmpty)
    }

    func testToggleAddsFavorite() {
        let id = UUID()
        service.toggle(saleId: id)
        XCTAssertTrue(service.isFavorite(saleId: id))
        XCTAssertEqual(service.favorites.count, 1)
    }

    func testToggleRemovesFavorite() {
        let id = UUID()
        service.toggle(saleId: id) // Add
        service.toggle(saleId: id) // Remove
        XCTAssertFalse(service.isFavorite(saleId: id))
        XCTAssertTrue(service.favorites.isEmpty)
    }

    func testMultipleFavorites() {
        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()

        service.toggle(saleId: id1)
        service.toggle(saleId: id2)
        service.toggle(saleId: id3)

        XCTAssertEqual(service.favorites.count, 3)
        XCTAssertTrue(service.isFavorite(saleId: id1))
        XCTAssertTrue(service.isFavorite(saleId: id2))
        XCTAssertTrue(service.isFavorite(saleId: id3))
    }

    func testClearRemovesAll() {
        let id1 = UUID()
        let id2 = UUID()

        service.toggle(saleId: id1)
        service.toggle(saleId: id2)
        service.clear()

        XCTAssertTrue(service.favorites.isEmpty)
        XCTAssertFalse(service.isFavorite(saleId: id1))
        XCTAssertFalse(service.isFavorite(saleId: id2))
    }

    func testIsFavoriteReturnsFalseForUnknownId() {
        XCTAssertFalse(service.isFavorite(saleId: UUID()))
    }
}
