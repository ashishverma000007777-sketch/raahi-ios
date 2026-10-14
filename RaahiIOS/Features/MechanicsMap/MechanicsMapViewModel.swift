import Foundation
import CoreLocation
import MapKit

@MainActor
public final class MechanicsMapViewModel: ObservableObject {
    @Published public var mechanics: [MechanicDto] = []
    @Published public var filteredMechanics: [MechanicDto] = []
    @Published public var selectedFilter: String = "All"
    @Published public var selectedMechanic: MechanicDto? = nil
    @Published public var showDetailSheet: Bool = false
    
    @Published public var userCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777)
    @Published public var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
    
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let apiClient: APIClientProtocol
    private let locationManager: LocationManager
    
    public let filters = ["All", "Engine", "Tyres", "Electrical", "Towing", "SOS"]
    
    public init(
        apiClient: APIClientProtocol = APIClient.shared,
        locationManager: LocationManager = LocationManager.shared
    ) {
        self.apiClient = apiClient
        self.locationManager = locationManager
    }
    
    public func loadNearbyMechanics() async {
        isLoading = true
        errorMessage = nil
        
        // 1. Get GPS fix
        if let loc = try? await locationManager.requestCurrentLocation() {
            self.userCoordinate = loc.coordinate
            self.region = MKCoordinateRegion(
                center: loc.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            )
        }
        
        // 2. Fetch mechanics nearby from backend
        do {
            let results: [MechanicDto] = try await apiClient.request(
                .nearbyMechanics(lat: userCoordinate.latitude, lng: userCoordinate.longitude, radius: 25.0)
            )
            self.mechanics = results
            self.applyFilter()
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func selectFilter(_ filter: String) {
        self.selectedFilter = filter
        applyFilter()
    }
    
    private func applyFilter() {
        if selectedFilter == "All" {
            filteredMechanics = mechanics
        } else {
            filteredMechanics = mechanics.filter { m in
                guard let specs = m.specializations else { return false }
                return specs.localizedCaseInsensitiveContains(selectedFilter)
            }
        }
    }
    
    public func selectMechanic(_ mechanic: MechanicDto) {
        self.selectedMechanic = mechanic
        self.showDetailSheet = true
    }
    
    public func recenter() {
        self.region = MKCoordinateRegion(
            center: userCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    }
}
