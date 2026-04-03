import Foundation
import SwiftUI

// MARK: - Favorites View Model

@MainActor
final class FavoritesViewModel: ObservableObject {

    @Published var sales: [GarageSale] = []
    @Published var isLoading = false

    func loadFavorites() async {
        let ids = FavoritesService.shared.favorites
        guard !ids.isEmpty else {
            sales = []
            return
        }

        isLoading = sales.isEmpty
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

        sales = loadedSales.sorted { ($0.saleDateAsDate ?? .distantPast) < ($1.saleDateAsDate ?? .distantPast) }
        isLoading = false
    }

    var hasFavorites: Bool {
        !FavoritesService.shared.favorites.isEmpty
    }
}
