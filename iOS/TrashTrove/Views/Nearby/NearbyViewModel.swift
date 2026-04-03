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

// MARK: - Location Service

final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastLocation: CLLocation?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        manager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Location errors are non-fatal; the view model handles the absence of location
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

    init(locationService: LocationService = .shared) {
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
                    if let location = self.locationService.lastLocation {
                        self.locationState = .ready(location.coordinate)
                    }
                @unknown default:
                    self.locationState = .loading
                }
            }
            .store(in: &cancellables)

        // React to location updates
        locationService.$lastLocation
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
