import Foundation

@MainActor
public final class ProfileViewModel: ObservableObject {
    @Published public var user: UserDto? = nil
    @Published public var vehicle: VehicleDto? = nil
    @Published public var carHealth: CarHealthDto? = nil
    @Published public var serviceRecords: [ServiceRecordDto] = []
    
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    // Odometer dialog state
    @Published public var newOdometerText: String = ""
    @Published public var showOdometerSheet: Bool = false
    @Published public var isUpdatingOdometer: Bool = false
    
    private let apiClient: APIClientProtocol
    private let authManager: AuthManager
    
    public init(
        apiClient: APIClientProtocol = APIClient.shared,
        authManager: AuthManager = AuthManager.shared
    ) {
        self.apiClient = apiClient
        self.authManager = authManager
    }
    
    public func loadProfileData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let meFetch: UserDto = apiClient.request(.authMe)
            let user = try await meFetch
            self.user = user
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        // Fetch vehicle (handles 404 gracefully if not configured yet)
        do {
            let v: VehicleDto = try await apiClient.request(.myVehicle)
            self.vehicle = v
            self.newOdometerText = "\(v.odometerKm)"
        } catch {
            self.vehicle = nil
        }
        
        // Fetch car health
        do {
            let h: CarHealthDto = try await apiClient.request(.carHealth)
            self.carHealth = h
        } catch {
            self.carHealth = nil
        }
        
        // Fetch service records
        do {
            let records: [ServiceRecordDto] = try await apiClient.request(.serviceRecords)
            self.serviceRecords = records
        } catch {
            self.serviceRecords = []
        }
        
        self.isLoading = false
    }
    
    public func updateOdometer() async -> Bool {
        guard let km = Int(newOdometerText.trimmingCharacters(in: .whitespaces)) else {
            errorMessage = "Please enter a valid numeric odometer reading."
            return false
        }
        
        if let current = vehicle?.odometerKm, km < current {
            errorMessage = "New odometer reading cannot be less than current (\(current) km)."
            return false
        }
        
        isUpdatingOdometer = true
        errorMessage = nil
        
        do {
            let updated: VehicleDto = try await apiClient.request(.updateOdometer(km: km))
            self.vehicle = updated
            self.isUpdatingOdometer = false
            self.showOdometerSheet = false
            // Refresh health score
            if let h: CarHealthDto = try? await apiClient.request(.carHealth) {
                self.carHealth = h
            }
            return true
        } catch {
            self.isUpdatingOdometer = false
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    public func logout() async {
        await authManager.logout()
    }
}
