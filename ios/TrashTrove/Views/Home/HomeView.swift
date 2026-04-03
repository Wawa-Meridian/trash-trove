import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    heroSection
                    howItWorksSection
                    upcomingSalesSection
                    browseByStateSection
                }
            }
            .refreshable {
                await viewModel.loadData()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("TrashTrove")
                        .font(.custom("Georgia", size: 20))
                        .fontWeight(.bold)
                        .foregroundStyle(.treasureGold600)
                }
            }
            .task {
                if viewModel.upcomingSales.isEmpty {
                    await viewModel.loadData()
                }
            }
            .onAppear {
                AnalyticsService.shared.trackScreen("Home")
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack {
            LinearGradient(
                colors: [.treasureGold50, .forestGreen50],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 16) {
                Text("Find Weekend\nGarage Sales Near You")
                    .font(.custom("Georgia", size: 32))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .accessibilityAddTraits(.isHeader)

                Text("Discover local treasures at garage sales, yard sales, and estate sales in your neighborhood.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                NavigationLink(destination: SearchView()) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search garage sales...")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(12)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                }
                .padding(.horizontal, 24)
                .accessibilityLabel("Search for garage sales")

                HStack(spacing: 12) {
                    NavigationLink(destination: BrowseView()) {
                        Label("Browse Sales", systemImage: "map")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(.treasureGold600)
                            .clipShape(Capsule())
                    }
                    .accessibilityLabel("Browse garage sales by state")

                    NavigationLink(destination: CreateSaleView()) {
                        Label("List Your Sale", systemImage: "plus.circle")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.treasureGold600)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(.treasureGold600.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .accessibilityLabel("Create a new garage sale listing")
                }
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - How It Works

    private var howItWorksSection: some View {
        VStack(spacing: 20) {
            Text("How It Works")
                .font(.custom("Georgia", size: 24))
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 16) {
                howItWorksCard(
                    icon: "tag",
                    title: "List Your Sale",
                    description: "Create a free listing with photos, dates, and categories."
                )
                howItWorksCard(
                    icon: "mappin.and.ellipse",
                    title: "Shoppers Find You",
                    description: "Buyers discover your sale through search and browsing."
                )
                howItWorksCard(
                    icon: "dollarsign.circle",
                    title: "Sell Your Stuff",
                    description: "Turn your unused items into cash on sale day."
                )
            }
        }
        .padding(24)
    }

    private func howItWorksCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.treasureGold600)
                .frame(width: 48, height: 48)
                .background(.treasureGold600.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Upcoming Sales

    private var upcomingSalesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming Sales")
                    .font(.custom("Georgia", size: 24))
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                NavigationLink("See All", destination: BrowseView())
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.treasureGold600)
            }
            .padding(.horizontal, 24)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .accessibilityLabel("Loading upcoming sales")
            } else if viewModel.upcomingSales.isEmpty {
                emptyUpcomingSales
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(viewModel.upcomingSales) { sale in
                            NavigationLink(destination: SaleDetailView(saleId: sale.id)) {
                                SaleCardView(sale: sale)
                                    .frame(width: 280)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .padding(.vertical, 24)
    }

    private var emptyUpcomingSales: some View {
        VStack(spacing: 8) {
            Image(systemName: "tag.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No upcoming sales found")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Browse by State

    private var browseByStateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Browse by State")
                .font(.custom("Georgia", size: 24))
                .fontWeight(.bold)
                .padding(.horizontal, 24)
                .accessibilityAddTraits(.isHeader)

            StateGridView(stateCounts: viewModel.stateCounts)
                .padding(.horizontal, 24)
        }
        .padding(.vertical, 24)
    }
}

#Preview {
    HomeView()
}
