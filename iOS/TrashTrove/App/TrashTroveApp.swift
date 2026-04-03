import SwiftUI

@main
struct TrashTroveApp: App {
    @StateObject private var favoritesService = FavoritesService.shared
    @StateObject private var locationService = LocationService()
    @Environment(\.scenePhase) private var scenePhase
    @State private var deepLinkSaleId: UUID?

    init() {
        configureAppearance()
        configureURLCache()
        AnalyticsService.shared.track(.appOpened)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(deepLinkSaleId: $deepLinkSaleId)
                .environmentObject(favoritesService)
                .environmentObject(locationService)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
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

    // MARK: - Deep Linking

    private func handleDeepLink(_ url: URL) {
        // Handle URLs like: trashtrove://sale/{id} or https://trashtrove.app/sale/{id}
        let pathComponents = url.pathComponents
        if let saleIndex = pathComponents.firstIndex(of: "sale"),
           saleIndex + 1 < pathComponents.count,
           let saleId = UUID(uuidString: pathComponents[saleIndex + 1]) {
            deepLinkSaleId = saleId
        }
    }

    // MARK: - URL Cache for Image Caching

    private func configureURLCache() {
        // 50MB memory, 200MB disk cache for images
        let cache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024,
            directory: nil
        )
        URLCache.shared = cache
    }

    // MARK: - Appearance

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
