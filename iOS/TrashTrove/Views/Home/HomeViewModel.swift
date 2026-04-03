import Foundation
import Combine
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var upcomingSales: [GarageSale] = []
    @Published var stateCounts: [String: Int] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let salesTask = SupabaseService.shared.fetchUpcomingSales(limit: 10)
            async let countsTask = SupabaseService.shared.fetchStateCounts()

            let (sales, counts) = try await (salesTask, countsTask)
            upcomingSales = sales
            stateCounts = counts
        } catch {
            errorMessage = "Failed to load data. Pull to refresh."
        }

        isLoading = false
    }
}
