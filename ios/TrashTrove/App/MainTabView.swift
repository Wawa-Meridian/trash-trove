import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var favoritesService: FavoritesService

    enum Tab: String {
        case home, browse, nearby, favorites, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
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
    }
}

#Preview {
    MainTabView()
        .environmentObject(FavoritesService.shared)
        .environmentObject(LocationService())
}
