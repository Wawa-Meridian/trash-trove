import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection

                    if viewModel.isLoading {
                        skeletonCards
                    } else if viewModel.sales.isEmpty {
                        emptyState
                    } else {
                        salesGrid
                    }
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadFavorites()
            }
            .onAppear {
                AnalyticsService.shared.trackScreen("Favorites")
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .foregroundStyle(Color.treasureGold600)
                .accessibilityHidden(true)

            Text("Your Favorites")
                .font(.custom("Georgia", size: 28))
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Skeleton Loading

    private var skeletonCards: some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
        ]

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                skeletonCard
            }
        }
        .padding(.horizontal, 16)
        .accessibilityLabel("Loading favorites")
    }

    private var skeletonCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.15))
                .frame(height: 120)
                .shimmer()

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.15))
                .frame(height: 14)
                .shimmer()

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.15))
                .frame(width: 100, height: 12)
                .shimmer()
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }

    // MARK: - Sales Grid

    private var salesGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
        ]

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.sales) { sale in
                NavigationLink(destination: SaleDetailView(saleId: sale.id)) {
                    SaleCardView(sale: sale)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(sale.title), \(sale.formattedDate)")
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 64))
                .foregroundStyle(.secondary.opacity(0.5))
                .accessibilityHidden(true)

            Text("No favorites yet")
                .font(.custom("Georgia", size: 24))
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)

            Text("Browse sales and tap the heart to save them.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            NavigationLink(destination: BrowseView()) {
                Label("Browse Sales", systemImage: "map")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.treasureGold600)
                    .clipShape(Capsule())
            }
            .accessibilityLabel("Browse garage sales")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.4),
                            .clear,
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.6)
                    .offset(x: -geometry.size.width * 0.3 + phase * geometry.size.width * 1.6)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

#Preview {
    FavoritesView()
}
