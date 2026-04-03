import Foundation
import Combine
import os

@MainActor
final class FavoritesService: ObservableObject {

    static let shared = FavoritesService()

    @Published private(set) var favorites: Set<UUID> = []

    private let storageKey = "trashtrove_favorites"
    private let logger = Logger(subsystem: "app.trashtrove", category: "Favorites")
    private let maxFavorites = 500

    init() {
        loadFavorites()
    }

    // MARK: - Public API

    /// Toggles the favorite state of a sale. Returns the new favorite state.
    @discardableResult
    func toggle(saleId: UUID) -> Bool {
        if favorites.contains(saleId) {
            favorites.remove(saleId)
            logger.debug("Unfavorited sale: \(saleId.uuidString)")
            saveFavorites()
            AnalyticsService.shared.trackFavoriteToggle(saleId: saleId, isFavorite: false)
            return false
        } else {
            if favorites.count >= maxFavorites {
                logger.warning("Favorites limit reached (\(self.maxFavorites)). Cannot add more.")
                return false
            }
            favorites.insert(saleId)
            logger.debug("Favorited sale: \(saleId.uuidString)")
            saveFavorites()
            AnalyticsService.shared.trackFavoriteToggle(saleId: saleId, isFavorite: true)
            return true
        }
    }

    /// Returns whether a sale is currently favorited.
    func isFavorite(saleId: UUID) -> Bool {
        favorites.contains(saleId)
    }

    /// Clears all favorites.
    func clear() {
        favorites.removeAll()
        saveFavorites()
        logger.info("All favorites cleared")
    }

    /// The number of favorited sales.
    var count: Int {
        favorites.count
    }

    /// Returns favorite IDs as an array (useful for batch fetching).
    var favoriteIDs: [UUID] {
        Array(favorites)
    }

    // MARK: - Persistence

    private func saveFavorites() {
        let strings = favorites.map { $0.uuidString }
        UserDefaults.standard.set(strings, forKey: storageKey)
    }

    private func loadFavorites() {
        guard let strings = UserDefaults.standard.stringArray(forKey: storageKey) else {
            logger.debug("No saved favorites found")
            return
        }

        let uuids = strings.compactMap { UUID(uuidString: $0) }
        favorites = Set(uuids)
        logger.info("Loaded \(self.favorites.count) favorites")
    }
}
