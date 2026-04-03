import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isSearching && viewModel.results.isEmpty {
                loadingState
            } else if viewModel.hasSearched && viewModel.results.isEmpty {
                emptyState
            } else if viewModel.results.isEmpty && !viewModel.hasSearched {
                promptState
            } else {
                resultsGrid
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search garage sales..."
        )
        .onChange(of: viewModel.searchText) { _, newValue in
            viewModel.onSearchTextChanged(newValue)
        }
        .onAppear {
            AnalyticsService.shared.trackScreen("Search")
        }
    }

    // MARK: - Results Grid

    private var resultsGrid: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(viewModel.totalResults) result\(viewModel.totalResults == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.results) { sale in
                        NavigationLink(destination: SaleDetailView(saleId: sale.id)) {
                            SaleCardView(sale: sale)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            if sale.id == viewModel.results.last?.id {
                                Task {
                                    await viewModel.loadMore()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)

                if viewModel.isSearching {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .accessibilityLabel("Loading more results")
                }
            }
            .padding(.vertical, 16)
        }
    }

    // MARK: - States

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Searching...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Searching for garage sales")
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No Results Found")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.bold)
            Text("Try a different search term or browse by state.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            NavigationLink("Browse by State", destination: BrowseView())
                .buttonStyle(.borderedProminent)
                .tint(.treasureGold600)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var promptState: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.treasureGold600.opacity(0.5))
            Text("Search for Garage Sales")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.bold)
            Text("Search by title, description, city, or category.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
