import Foundation
import SwiftUI
import Combine

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
        let ids = favoritesService.favorites
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
        !favoritesService.favorites.isEmpty
    }
}
