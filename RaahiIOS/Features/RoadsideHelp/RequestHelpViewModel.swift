import Foundation
import CoreLocation

@MainActor
public final class RequestHelpViewModel: ObservableObject {
    @Published public var selectedCategory: ProblemCategory = ProblemTypes.all[0]
    @Published public var descriptionText: String = ""
    @Published public var highwayName: String = ""
    @Published public var rewardAmount: Double = 300.0
    @Published public var customAmountText: String = ""
    
    @Published public var currentLocation: CLLocationCoordinate2D? = nil
    @Published public var isLocating: Bool = false
    @Published public var isSubmitting: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var createdJob: JobDto? = nil
    
    private let apiClient: APIClientProtocol
    private let locationManager: LocationManager
    
    public init(
        apiClient: APIClientProtocol = APIClient.shared,
        locationManager: LocationManager = LocationManager.shared
    ) {
        self.apiClient = apiClient
        self.locationManager = locationManager
        self.rewardAmount = selectedCategory.suggestedAmount
        self.fetchCurrentLocation()
    }
    
    public func selectCategory(_ category: ProblemCategory) {
        self.selectedCategory = category
        self.rewardAmount = category.suggestedAmount
        self.customAmountText = "\(Int(category.suggestedAmount))"
    }
    
    public func setQuickAmount(_ amount: Double) {
        self.rewardAmount = amount
        self.customAmountText = "\(Int(amount))"
    }
    
    public func fetchCurrentLocation() {
        isLocating = true
        Task {
            do {
                let loc = try await locationManager.requestCurrentLocation()
                self.currentLocation = loc.coordinate
                self.isLocating = false
            } catch {
                self.isLocating = false
                // Default fallback if simulator without location
                if self.currentLocation == nil {
                    self.currentLocation = CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777) // Mumbai default
                }
            }
        }
    }
    
    public func submitRequest() async -> Bool {
        guard let location = currentLocation else {
            errorMessage = "Location is required to request roadside help. Please turn on GPS."
            return false
        }
        
        isSubmitting = true
        errorMessage = nil
        
        let effectiveReward = Double(customAmountText) ?? rewardAmount
        
        let req = CreateJobRequest(
            problemType: selectedCategory.code,
            problemDesc: descriptionText.isEmpty ? nil : descriptionText,
            lat: location.latitude,
            lng: location.longitude,
            highwayName: highwayName.isEmpty ? nil : highwayName,
            rewardAmount: effectiveReward
        )
        
        do {
            let job: JobDto = try await apiClient.request(.createJob(req: req))
            self.createdJob = job
            self.isSubmitting = false
            return true
        } catch {
            self.isSubmitting = false
            self.errorMessage = error.localizedDescription
            return false
        }
    }
}
