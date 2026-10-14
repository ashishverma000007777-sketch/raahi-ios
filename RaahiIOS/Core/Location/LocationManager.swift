import Foundation
import CoreLocation

@MainActor
public final class LocationManager: NSObject, ObservableObject {
    public static let shared = LocationManager()
    
    @Published public private(set) var currentLocation: CLLocation?
    @Published public private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public private(set) var isUpdatingLocation: Bool = false
    
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10.0 // 10 meters
        authorizationStatus = locationManager.authorizationStatus
    }
    
    public func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func startUpdating() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestAuthorization()
            return
        }
        isUpdatingLocation = true
        locationManager.startUpdatingLocation()
    }
    
    public func stopUpdating() {
        isUpdatingLocation = false
        locationManager.stopUpdatingLocation()
    }
    
    public func requestCurrentLocation() async throws -> CLLocation {
        if let loc = currentLocation, Date().timeIntervalSince(loc.timestamp) < 30 {
            return loc
        }
        
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            self.locationManager.requestLocation()
        }
    }
    
    public static func distanceInKm(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let loc2 = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return loc1.distance(from: loc2) / 1000.0
    }
}

extension LocationManager: CLLocationManagerDelegate {
    public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }
    
    public nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = location
            if let continuation = self.locationContinuation {
                self.locationContinuation = nil
                continuation.resume(returning: location)
            }
        }
    }
    
    public nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            if let continuation = self.locationContinuation {
                self.locationContinuation = nil
                continuation.resume(throwing: error)
            }
        }
    }
}
