import XCTest
@testable import TrashTrove

final class ImageServiceTests: XCTestCase {
    private let imageService = ImageService.shared

    func testValidateImageSizeAcceptsSmallImages() {
        let smallData = Data(count: 1024 * 1024) // 1MB
        XCTAssertTrue(imageService.isValidImageSize(smallData))
    }

    func testValidateImageSizeRejectsLargeImages() {
        let largeData = Data(count: 6 * 1024 * 1024) // 6MB
        XCTAssertFalse(imageService.isValidImageSize(largeData))
    }

    func testMaxImageSizeIs5MB() {
        XCTAssertEqual(imageService.maxImageSizeBytes, 5 * 1024 * 1024)
    }

    func testMaxPhotosPerListing() {
        XCTAssertEqual(imageService.maxPhotosPerListing, 10)
    }
}
