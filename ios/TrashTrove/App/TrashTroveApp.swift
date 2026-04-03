import SwiftUI

@main
struct TrashTroveApp: App {
    @StateObject private var favoritesService = FavoritesService.shared
    @StateObject private var locationService = LocationService()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        configureAppearance()
        AnalyticsService.shared.track(.appOpened)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(favoritesService)
                .environmentObject(locationService)
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .active:
                        AnalyticsService.shared.track(.appOpened)
                    case .background:
                        AnalyticsService.shared.track(.appBackgrounded)
                        AnalyticsService.shared.flush()
                    default:
                        break
                    }
                }
        }
    }

    private func configureAppearance() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = .systemBackground
        navAppearance.titleTextAttributes = [
            .font: UIFont(name: "Georgia-Bold", size: 18) ?? .boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor(Color.treasureGold800)
        ]
        navAppearance.largeTitleTextAttributes = [
            .font: UIFont(name: "Georgia-Bold", size: 34) ?? .boldSystemFont(ofSize: 34),
            .foregroundColor: UIColor(Color.treasureGold900)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        UITabBar.appearance().tintColor = UIColor(Color.treasureGold600)
    }
}
