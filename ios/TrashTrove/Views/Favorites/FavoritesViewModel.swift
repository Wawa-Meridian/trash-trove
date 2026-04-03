import Foundation
import SwiftUI
import Combine

// MARK: - Favorites Service

final class FavoritesService: ObservableObject {
    static let shared = FavoritesService()

    private let favoritesKey = "savedFavoriteIDs"

    @Published var favoriteIDs: Set<UUID> = []

    private init() {
        loadFromStorage()
    }

    // MARK: - Public API

    func isFavorite(_ saleId: UUID) -> Bool {
        favoriteIDs.contains(saleId)
    }

    func toggleFavorite(_ saleId: UUID) {
        if favoriteIDs.contains(saleId) {
            favoriteIDs.remove(saleId)
        } else {
            favoriteIDs.insert(saleId)
        }
        saveToStorage()
    }

    func addFavorite(_ saleId: UUID) {
        favoriteIDs.insert(saleId)
        saveToStorage()
    }

    func removeFavorite(_ saleId: UUID) {
        favoriteIDs.remove(saleId)
        saveToStorage()
    }

    func clearAll() {
        favoriteIDs.removeAll()
        saveToStorage()
    }

    // MARK: - Persistence

    private func loadFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let ids = try? JSONDecoder().decode(Set<UUID>.self, from: data) else {
            return
        }
        favoriteIDs = ids
    }

    private func saveToStorage() {
        guard let data = try? JSONEncoder().encode(favoriteIDs) else { return }
        UserDefaults.standard.set(data, forKey: favoritesKey)
    }
}

// MARK: - Favorites View Model

@MainActor
final class FavoritesViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var sales: [GarageSale] = []
    @Published var isLoading = false

    // MARK: - Dependencies

    private let favoritesService = FavoritesService.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init() {
        observeFavoritesChanges()
    }

    // MARK: - Observation

    private func observeFavoritesChanges() {
        favoritesService.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task {
                    await self.loadFavorites()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Data Loading

    func loadFavorites() async {
        let ids = favoritesService.favoriteIDs
        guard !ids.isEmpty else {
            sales = []
            return
        }

        isLoading = sales.isEmpty // Only show loading on initial load
        var loadedSales: [GarageSale] = []

        await withTaskGroup(of: GarageSale?.self) { group in
            for id in ids {
                group.addTask {
                    try? await SupabaseService.shared.fetchSale(id: id)
                }
            }
            for await sale in group {
                if let sale {
                    loadedSales.append(sale)
                }
            }
        }

        // Sort by sale date ascending
        sales = loadedSales.sorted { ($0.saleDateAsDate ?? .distantPast) < ($1.saleDateAsDate ?? .distantPast) }
        isLoading = false
    }

    /// Whether there are any favorites saved
    var hasFavorites: Bool {
        !favoritesService.favoriteIDs.isEmpty
    }
}
