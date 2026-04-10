import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @State private var homePath = NavigationPath()
    @EnvironmentObject var favoritesService: FavoritesService
    @Binding var deepLinkSaleId: UUID?

    init(deepLinkSaleId: Binding<UUID?> = .constant(nil)) {
        _deepLinkSaleId = deepLinkSaleId
    }

    enum Tab: String {
        case home, browse, nearby, favorites, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                HomeView()
                    .navigationDestination(for: UUID.self) { saleId in
                        SaleDetailView(saleId: saleId)
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(Tab.home)

            NavigationStack {
                BrowseView()
            }
            .tabItem {
                Label("Browse", systemImage: "mappin.and.ellipse")
            }
            .tag(Tab.browse)

            NavigationStack {
                NearbyView()
            }
            .tabItem {
                Label("Nearby", systemImage: "location.fill")
            }
            .tag(Tab.nearby)

            NavigationStack {
                FavoritesView()
            }
            .tabItem {
                Label {
                    Text("Favorites")
                } icon: {
                    Image(systemName: favoritesService.favorites.isEmpty ? "heart" : "heart.fill")
                }
            }
            .tag(Tab.favorites)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(Tab.settings)
        }
        .tint(Color.treasureGold600)
        .onChange(of: deepLinkSaleId) { _, saleId in
            if let saleId {
                selectedTab = .home
                homePath.append(saleId)
                deepLinkSaleId = nil
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(FavoritesService.shared)
        .environmentObject(LocationService())
}
