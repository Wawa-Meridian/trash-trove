import SwiftUI

struct StateSalesView: View {
    let stateCode: String
    let stateName: String

    @StateObject private var viewModel: StateSalesViewModel

    init(stateCode: String, stateName: String) {
        self.stateCode = stateCode
        self.stateName = stateName
        _viewModel = StateObject(wrappedValue: StateSalesViewModel(stateCode: stateCode))
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                loadingState
            } else if let error = viewModel.errorMessage {
                errorState(error)
            } else if viewModel.sales.isEmpty {
                emptyState
            } else {
                salesContent
            }
        }
        .navigationTitle(stateName)
        .navigationBarTitleDisplayMode(.large)
        .task {
            if viewModel.sales.isEmpty {
                await viewModel.loadSales()
            }
        }
        .refreshable {
            await viewModel.loadSales()
        }
        .onAppear {
            AnalyticsService.shared.trackScreen("StateSales_\(stateCode)")
        }
    }

    // MARK: - City Filter Chips

    private var cityChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chipButton(label: "All", isSelected: viewModel.selectedCity == nil) {
                    viewModel.filterByCity(nil)
                }

                ForEach(viewModel.cities, id: \.self) { city in
                    chipButton(label: city, isSelected: viewModel.selectedCity == city) {
                        viewModel.filterByCity(city)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
    }

    private func chipButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.treasureGold600 : Color.gray.opacity(0.12))
                .clipShape(Capsule())
        }
        .accessibilityLabel("Filter by \(label)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Sales Content

    private var salesContent: some View {
        VStack(spacing: 0) {
            if viewModel.cities.count > 1 {
                cityChips
            }

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.filteredSales) { sale in
                        NavigationLink(destination: SaleDetailView(saleId: sale.id)) {
                            SaleCardRow(sale: sale)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
        }
    }

    // MARK: - States

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading sales...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading garage sales for \(stateName)")
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                Task {
                    await viewModel.loadSales()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.treasureGold600)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No Garage Sales in \(stateName)")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.bold)
            Text("Check back later or browse another state.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            NavigationLink("Browse Other States", destination: BrowseView())
                .buttonStyle(.borderedProminent)
                .tint(Color.treasureGold600)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Sale Card Row

struct SaleCardRow: View {
    let sale: GarageSale

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let photo = sale.primaryPhoto {
                AsyncImage(url: URL(string: photo.url)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.treasureGold600.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: "tag")
                            .foregroundStyle(Color.treasureGold600)
                    }
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(sale.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(sale.formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(sale.city), \(sale.state)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Category pills
                if !sale.categories.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(sale.categories.prefix(3), id: \.self) { category in
                            Text(category)
                                .font(.caption2)
                                .foregroundStyle(Color.treasureGold600)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.treasureGold600.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(sale.title), \(sale.formattedDate), \(sale.city), \(sale.state)")
    }
}

#Preview {
    NavigationStack {
        StateSalesView(stateCode: "TX", stateName: "Texas")
    }
}
