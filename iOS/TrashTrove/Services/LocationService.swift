import CoreLocation
import Combine
import Foundation
import os

@MainActor
final class LocationService: NSObject, ObservableObject {

    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var isLoading: Bool = false
    @Published var locationError: LocationError?

    private let manager: CLLocationManager
    private let logger = Logger(subsystem: "app.trashtrove", category: "LocationService")

    // Track whether we have delivered at least one location
    private var hasReceivedLocation = false

    // Continuation for one-shot location requests
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    enum LocationError: LocalizedError {
        case denied
        case restricted
        case unableToDetermine
        case timeout
        case unknown(Error)

        var errorDescription: String? {
            switch self {
            case .denied:
                return "Location access was denied. Please enable it in Settings."
            case .restricted:
                return "Location services are restricted on this device."
            case .unableToDetermine:
                return "Unable to determine your location. Please try again."
            case .timeout:
                return "Location request timed out. Please try again."
            case .unknown(let error):
                return error.localizedDescription
            }
        }
    }

    override init() {
        manager = CLLocationManager()
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 500 // Update when user moves 500m
    }

    // MARK: - Public Methods

    /// Requests location permission from the user.
    func requestPermission() {
        logger.info("Requesting location permission. Current status: \(String(describing: self.authorizationStatus.rawValue))")
        manager.requestWhenInUseAuthorization()
    }

    /// Starts continuous location updates.
    func startUpdating() {
        guard canAccessLocation else {
            logger.warning("Cannot start updates - authorization status: \(self.authorizationStatus.rawValue)")
            updateErrorForStatus(authorizationStatus)
            return
        }
        isLoading = userLocation == nil
        locationError = nil
        hasReceivedLocation = false
        manager.startUpdatingLocation()
        logger.info("Started location updates")
    }

    /// Stops continuous location updates.
    func stopUpdating() {
        manager.stopUpdatingLocation()
        isLoading = false
        logger.info("Stopped location updates")
    }

    /// Requests a single location fix. Returns when location is available or throws on error.
    func requestCurrentLocation() async throws -> CLLocation {
        // Return cached location if it's recent (< 5 minutes)
        if let cached = userLocation, abs(cached.timestamp.timeIntervalSinceNow) < 300 {
            return cached
        }

        guard canAccessLocation else {
            updateErrorForStatus(authorizationStatus)
            throw locationError ?? LocationError.denied
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            self.isLoading = true
            self.manager.requestLocation()

            // Timeout after 15 seconds
            Task { [weak self] in
                try? await Task.sleep(nanoseconds: 15_000_000_000)
                guard let self else { return }
                if let cont = self.locationContinuation {
                    self.locationContinuation = nil
                    self.isLoading = false
                    cont.resume(throwing: LocationError.timeout)
                }
            }
        }
    }

    // MARK: - Computed Properties

    var canAccessLocation: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    var needsPermission: Bool {
        authorizationStatus == .notDetermined
    }

    var isDenied: Bool {
        authorizationStatus == .denied
    }

    var coordinateTuple: (lat: Double, lng: Double)? {
        guard let location = userLocation else { return nil }
        return (lat: location.coordinate.latitude, lng: location.coordinate.longitude)
    }

    // MARK: - Private Helpers

    private func updateErrorForStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            locationError = .denied
        case .restricted:
            locationError = .restricted
        default:
            break
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            self.userLocation = location
            self.isLoading = false
            self.locationError = nil
            self.hasReceivedLocation = true

            self.logger.debug("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")

            // Fulfill one-shot continuation if pending
            if let continuation = self.locationContinuation {
                self.locationContinuation = nil
                continuation.resume(returning: location)
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.isLoading = false
            let clError = error as? CLError

            self.logger.error("Location error: \(error.localizedDescription)")

            switch clError?.code {
            case .denied:
                self.locationError = .denied
            case .locationUnknown:
                // Transient - may resolve itself; only report if we never got a fix
                if !self.hasReceivedLocation {
                    self.locationError = .unableToDetermine
                }
            default:
                self.locationError = .unknown(error)
            }

            // Fail one-shot continuation if pending
            if let continuation = self.locationContinuation {
                self.locationContinuation = nil
                continuation.resume(throwing: self.locationError ?? LocationError.unknown(error))
            }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            self.logger.info("Authorization changed to: \(status.rawValue)")

            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationError = nil
            case .denied:
                self.locationError = .denied
                self.stopUpdating()
            case .restricted:
                self.locationError = .restricted
                self.stopUpdating()
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
}
