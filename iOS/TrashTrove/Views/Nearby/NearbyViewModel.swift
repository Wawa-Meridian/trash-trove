import Foundation
import SwiftUI
import CoreLocation

// MARK: - Location State

enum LocationState: Equatable {
    case loading
    case denied
    case ready(CLLocationCoordinate2D)

    static func == (lhs: LocationState, rhs: LocationState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.denied, .denied):
            return true
        case (.ready(let a), .ready(let b)):
            return a.latitude == b.latitude && a.longitude == b.longitude
        default:
            return false
        }
    }
}

// MARK: - Nearby View Model

@MainActor
final class NearbyViewModel: ObservableObject {

    @Published var sales: [GarageSale] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var radius: Int = 25
    @Published var locationState: LocationState = .loading

    let locationService: LocationService

    nonisolated init() {
        self.locationService = LocationService()
    }

    func checkLocationAndLoad() {
        let status = locationService.authorizationStatus

        switch status {
        case .denied, .restricted:
            locationState = .denied
        case .notDetermined:
            locationState = .loading
            locationService.requestPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            if let location = locationService.userLocation {
                locationState = .ready(location.coordinate)
            } else {
                locationState = .loading
            }
        @unknown default:
            locationState = .loading
        }
    }

    func onLocationUpdate() {
        if let location = locationService.userLocation {
            locationState = .ready(location.coordinate)
            Task {
                await loadNearbySales()
            }
        }
    }

    func loadNearbySales() async {
        guard case .ready(let coordinate) = locationState else { return }

        isLoading = true
        error = nil

        do {
            let fetchedSales = try await SupabaseService.shared.fetchNearbySales(
                lat: coordinate.latitude,
                lng: coordinate.longitude,
                radiusMiles: radius
            )
            sales = fetchedSales

            AnalyticsService.shared.trackNearbySearch(
                lat: coordinate.latitude,
                lng: coordinate.longitude,
                radiusMiles: radius
            )
        } catch {
            self.error = "Failed to load nearby sales. Please try again."
        }

        isLoading = false
    }

    func updateRadius(_ newRadius: Int) {
        radius = newRadius
        Task {
            await loadNearbySales()
        }
    }

    var nextLargerRadius: Int? {
        let options = [10, 25, 50, 100]
        guard let currentIndex = options.firstIndex(of: radius),
              currentIndex + 1 < options.count else { return nil }
        return options[currentIndex + 1]
    }
}
