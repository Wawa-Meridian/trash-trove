import Foundation
import SwiftUI

@MainActor
final class StateSalesViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var sales: [GarageSale] = []
    @Published var filteredSales: [GarageSale] = []
    @Published var cities: [String] = []
    @Published var selectedCity: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Properties

    let stateCode: String

    // MARK: - Init

    init(stateCode: String) {
        self.stateCode = stateCode
    }

    // MARK: - Data Loading

    func loadSales() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedSales = try await SupabaseService.shared.fetchSalesByState(stateCode: stateCode)
            sales = fetchedSales
            cities = extractCities(from: fetchedSales)
            filterByCity(selectedCity)
        } catch {
            errorMessage = "Failed to load sales. Please try again."
        }

        isLoading = false
    }

    // MARK: - Filtering

    func filterByCity(_ city: String?) {
        selectedCity = city

        if let city {
            filteredSales = sales.filter { $0.city.lowercased() == city.lowercased() }
        } else {
            filteredSales = sales
        }
    }

    // MARK: - Helpers

    private func extractCities(from sales: [GarageSale]) -> [String] {
        let citySet = Set(sales.map { $0.city })
        return citySet.sorted()
    }
}
