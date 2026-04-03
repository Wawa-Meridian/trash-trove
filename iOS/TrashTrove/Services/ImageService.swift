import UIKit
import os

// MARK: - ImageService

final class ImageService: @unchecked Sendable {

    static let shared = ImageService()

    private let logger = Logger(subsystem: "app.trashtrove", category: "ImageService")

    /// Maximum dimension (width or height) for the compressed image.
    let maxDimension: CGFloat = 1200

    /// Maximum dimension for thumbnails.
    let thumbnailDimension: CGFloat = 300

    /// JPEG compression quality (0.0 - 1.0).
    let compressionQuality: CGFloat = 0.8

    /// Thumbnail compression quality.
    let thumbnailQuality: CGFloat = 0.6

    /// Maximum allowed file size in bytes (5 MB).
    let maxFileSize = 5 * 1024 * 1024

    private init() {}

    // MARK: - Error Types

    enum ImageError: LocalizedError {
        case fileTooLarge(Int)
        case compressionFailed
        case invalidImage
        case dimensionTooSmall

        var errorDescription: String? {
            switch self {
            case .fileTooLarge(let bytes):
                let mb = Double(bytes) / 1_048_576.0
                return String(format: "Image is too large (%.1f MB). Maximum size is 5 MB.", mb)
            case .compressionFailed:
                return "Failed to compress the image. Please try a different photo."
            case .invalidImage:
                return "The selected file is not a valid image."
            case .dimensionTooSmall:
                return "Image is too small. Please use a higher resolution photo."
            }
        }
    }

    // MARK: - Public API

    /// Compresses a UIImage to JPEG data suitable for upload.
    /// Resizes to fit within `maxDimension` and compresses to `compressionQuality`.
    /// Validates the result is under `maxFileSize`.
    func compressForUpload(_ image: UIImage) throws -> Data {
        guard image.size.width > 0, image.size.height > 0 else {
            throw ImageError.invalidImage
        }

        // Resize if needed
        let resized = resizeImage(image, maxDimension: maxDimension)

        // Compress to JPEG
        guard var data = resized.jpegData(compressionQuality: compressionQuality) else {
            throw ImageError.compressionFailed
        }

        // If still too large, progressively reduce quality
        var quality = compressionQuality
        while data.count > maxFileSize && quality > 0.1 {
            quality -= 0.1
            guard let reduced = resized.jpegData(compressionQuality: quality) else {
                throw ImageError.compressionFailed
            }
            data = reduced
        }

        if data.count > maxFileSize {
            throw ImageError.fileTooLarge(data.count)
        }

        logger.debug("Compressed image: \(data.count) bytes, quality: \(quality)")
        return data
    }

    /// Generates a thumbnail from a UIImage.
    func generateThumbnail(_ image: UIImage) throws -> Data {
        guard image.size.width > 0, image.size.height > 0 else {
            throw ImageError.invalidImage
        }

        let thumbnail = resizeImage(image, maxDimension: thumbnailDimension)

        guard let data = thumbnail.jpegData(compressionQuality: thumbnailQuality) else {
            throw ImageError.compressionFailed
        }

        logger.debug("Generated thumbnail: \(data.count) bytes")
        return data
    }

    /// Validates that image data is within acceptable limits before processing.
    func validateImageData(_ data: Data) throws {
        if data.count > maxFileSize {
            throw ImageError.fileTooLarge(data.count)
        }

        guard UIImage(data: data) != nil else {
            throw ImageError.invalidImage
        }
    }

    /// Processes raw image data from a picker: validates, compresses, and returns upload-ready Data.
    func processForUpload(_ data: Data) throws -> Data {
        try validateImageData(data)

        guard let image = UIImage(data: data) else {
            throw ImageError.invalidImage
        }

        return try compressForUpload(image)
    }

    /// Processes a UIImage and returns both the upload data and a thumbnail.
    func processWithThumbnail(_ image: UIImage) throws -> (uploadData: Data, thumbnailData: Data) {
        let upload = try compressForUpload(image)
        let thumbnail = try generateThumbnail(image)
        return (uploadData: upload, thumbnailData: thumbnail)
    }

    /// Returns a human-readable string for a byte count.
    func formattedSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }

    // MARK: - Private Helpers

    /// Resizes an image to fit within maxDimension while preserving aspect ratio.
    /// Returns the original image if it already fits.
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size

        // Already within bounds
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }

        let widthRatio = maxDimension / size.width
        let heightRatio = maxDimension / size.height
        let ratio = min(widthRatio, heightRatio)

        let newSize = CGSize(
            width: floor(size.width * ratio),
            height: floor(size.height * ratio)
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        logger.debug("Resized image from \(Int(size.width))x\(Int(size.height)) to \(Int(newSize.width))x\(Int(newSize.height))")
        return resized
    }
}
