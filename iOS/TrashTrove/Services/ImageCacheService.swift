import SwiftUI
import os

/// A persistent image cache that wraps URLCache with an in-memory NSCache layer.
/// Use `CachedAsyncImage` instead of `AsyncImage` for photos that should be cached.
final class ImageCacheService: @unchecked Sendable {

    static let shared = ImageCacheService()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let session: URLSession
    private let logger = Logger(subsystem: "app.trashtrove", category: "ImageCache")

    private init() {
        // Use shared URLCache (configured in TrashTroveApp) for disk persistence
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache.shared
        config.requestCachePolicy = .returnCacheDataElseLoad
        session = URLSession(configuration: config)

        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }

    func image(for url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString

        // Check memory cache first
        if let cached = memoryCache.object(forKey: key) {
            return cached
        }

        // Fetch from network/disk cache
        do {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            memoryCache.setObject(image, forKey: key, cost: data.count)
            return image
        } catch {
            logger.error("Failed to load image: \(error.localizedDescription)")
            return nil
        }
    }

    func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
}

/// A drop-in replacement for AsyncImage that uses the image cache.
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var uiImage: UIImage?
    @State private var isLoading = false

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let uiImage {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .task(id: url) {
                        await loadImage()
                    }
            }
        }
    }

    private func loadImage() async {
        guard let url, !isLoading else { return }
        isLoading = true
        uiImage = await ImageCacheService.shared.image(for: url)
        isLoading = false
    }
}

/// Convenience initializer matching common AsyncImage pattern.
extension CachedAsyncImage where Placeholder == ProgressView<EmptyView, EmptyView> {
    init(url: URL?, @ViewBuilder content: @escaping (Image) -> Content) {
        self.init(url: url, content: content) {
            ProgressView()
        }
    }
}
