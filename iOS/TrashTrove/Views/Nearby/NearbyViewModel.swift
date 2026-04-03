import Foundation
import SwiftUI
import CoreLocation
import Combine

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

    // MARK: - Published Properties

    @Published var sales: [GarageSale] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var radius: Int = 25
    @Published var locationState: LocationState = .loading

    // MARK: - Dependencies

    let locationService: LocationService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    @MainActor
    init(locationService: LocationService = LocationService()) {
        self.locationService = locationService
        observeLocation()
    }

    // MARK: - Location Observation

    private func observeLocation() {
        // React to authorization changes
        locationService.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .denied, .restricted:
                    self.locationState = .denied
                case .notDetermined:
                    self.locationState = .loading
                    self.locationService.requestPermission()
                case .authorizedWhenInUse, .authorizedAlways:
                    if let location = self.locationService.userLocation {
                        self.locationState = .ready(location.coordinate)
                    }
                @unknown default:
                    self.locationState = .loading
                }
            }
            .store(in: &cancellables)

        // React to location updates
        locationService.$userLocation
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let self else { return }
                self.locationState = .ready(location.coordinate)
                Task {
                    await self.loadNearbySales()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Data Loading

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

    // MARK: - Radius Update

    func updateRadius(_ newRadius: Int) {
        radius = newRadius
        Task {
            await loadNearbySales()
        }
    }

    /// Returns the next larger radius option for the "expand" prompt, or nil if already at max.
    var nextLargerRadius: Int? {
        let options = [10, 25, 50, 100]
        guard let currentIndex = options.firstIndex(of: radius),
              currentIndex + 1 < options.count else { return nil }
        return options[currentIndex + 1]
    }
}
