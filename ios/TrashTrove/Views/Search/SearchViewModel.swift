import Foundation
import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var searchText = ""
    @Published var results: [GarageSale] = []
    @Published var isSearching = false
    @Published var totalResults = 0
    @Published var errorMessage: String?
    @Published var hasSearched = false

    // MARK: - Pagination

    private var currentPage = 0
    private let pageSize = 20
    private var canLoadMore: Bool {
        results.count < totalResults
    }

    // MARK: - Search Task

    private var searchTask: Task<Void, Never>?

    // MARK: - Debounced Search

    func onSearchTextChanged(_ text: String) {
        searchTask?.cancel()

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            results = []
            totalResults = 0
            hasSearched = false
            isSearching = false
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 500ms debounce

            guard !Task.isCancelled else { return }
            await search()
        }
    }

    // MARK: - Search

    func search() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }

        isSearching = true
        errorMessage = nil
        currentPage = 0

        do {
            let response = try await SupabaseService.shared.searchSales(
                query: query,
                offset: 0,
                limit: pageSize
            )
            results = response.sales
            totalResults = response.totalCount
            hasSearched = true
        } catch {
            if !Task.isCancelled {
                errorMessage = "Search failed. Please try again."
            }
        }

        isSearching = false
    }

    // MARK: - Load More

    func loadMore() async {
        guard canLoadMore, !isSearching else { return }

        isSearching = true
        currentPage += 1

        do {
            let response = try await SupabaseService.shared.searchSales(
                query: searchText,
                offset: currentPage * pageSize,
                limit: pageSize
            )
            results.append(contentsOf: response.sales)
            totalResults = response.totalCount
        } catch {
            currentPage -= 1
            if !Task.isCancelled {
                errorMessage = "Failed to load more results."
            }
        }

        isSearching = false
    }
}
