import XCTest
@testable import TrashTrove

final class ImageServiceTests: XCTestCase {
    private let imageService = ImageService.shared

    func testMaxDimensionIs1200() {
        XCTAssertEqual(imageService.maxDimension, 1200)
    }

    func testThumbnailDimensionIs300() {
        XCTAssertEqual(imageService.thumbnailDimension, 300)
    }

    func testCompressionQualityIs08() {
        XCTAssertEqual(imageService.compressionQuality, 0.8, accuracy: 0.01)
    }

    func testMaxFileSizeIs5MB() {
        XCTAssertEqual(imageService.maxFileSize, 5 * 1024 * 1024)
    }

    func testValidateImageDataRejectsLargeData() {
        let largeData = Data(count: 6 * 1024 * 1024) // 6MB
        XCTAssertThrowsError(try imageService.validateImageData(largeData)) { error in
            XCTAssertTrue(error is ImageService.ImageError)
        }
    }

    func testValidateImageDataRejectsInvalidData() {
        let invalidData = "not an image".data(using: .utf8)!
        XCTAssertThrowsError(try imageService.validateImageData(invalidData)) { error in
            XCTAssertTrue(error is ImageService.ImageError)
        }
    }

    func testFormattedSizeOutput() {
        let result = imageService.formattedSize(1024 * 1024)
        XCTAssertFalse(result.isEmpty)
    }
}
