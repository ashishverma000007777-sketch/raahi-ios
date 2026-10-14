import Foundation
import CoreLocation

@MainActor
public final class SOSViewModel: ObservableObject {
    @Published public var activeSos: SosDto? = nil
    @Published public var notifiedMechanicsCount: Int = 0
    @Published public var isTriggering: Bool = false
    @Published public var isResolving: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var showTriggerConfirmation: Bool = false
    
    private let apiClient: APIClientProtocol
    private let locationManager: LocationManager
    
    public init(
        apiClient: APIClientProtocol = APIClient.shared,
        locationManager: LocationManager = LocationManager.shared
    ) {
        self.apiClient = apiClient
        self.locationManager = locationManager
    }
    
    public func checkActiveSos() async {
        do {
            let myEvents: [SosDto] = try await apiClient.request(.mySosEvents)
            self.activeSos = myEvents.first { $0.status.uppercased() == "ACTIVE" }
        } catch {
            // Non-blocking
        }
    }
    
    public func triggerSos() async {
        isTriggering = true
        errorMessage = nil
        
        let loc = (try? await locationManager.requestCurrentLocation())?.coordinate ??
                  locationManager.currentLocation?.coordinate ??
                  CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777)
        
        do {
            let res: TriggerSosResponse = try await apiClient.request(.triggerSos(lat: loc.latitude, lng: loc.longitude))
            self.activeSos = res.sos
            self.notifiedMechanicsCount = res.nearbyMechanicsNotified
            self.isTriggering = false
        } catch {
            self.isTriggering = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func resolveSos() async {
        guard let sos = activeSos else { return }
        isResolving = true
        errorMessage = nil
        
        do {
            _ = try await apiClient.request(.resolveSos(id: sos.id)) as [String: Bool]
            self.activeSos = nil
            self.notifiedMechanicsCount = 0
            self.isResolving = false
        } catch {
            self.isResolving = false
            self.errorMessage = error.localizedDescription
        }
    }
}
