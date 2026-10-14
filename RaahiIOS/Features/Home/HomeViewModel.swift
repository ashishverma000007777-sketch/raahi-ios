import Foundation

@MainActor
public final class HomeViewModel: ObservableObject {
    @Published public var user: UserDto? = nil
    @Published public var vehicle: VehicleDto? = nil
    @Published public var carHealth: CarHealthDto? = nil
    @Published public var homeSummary: HomeSummaryDto? = nil
    @Published public var activeJob: JobDto? = nil
    @Published public var aiStatus: AiStatusDto? = nil
    
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let apiClient: APIClientProtocol
    
    public init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    public var greetingTimeText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good morning"
        } else if hour < 17 {
            return "Good afternoon"
        } else {
            return "Good evening"
        }
    }
    
    public func loadHomeData() async {
        isLoading = true
        errorMessage = nil
        
        // 1. Fetch user profile
        if let u: UserDto = try? await apiClient.request(.authMe) {
            self.user = u
        }
        
        // 2. Fetch vehicle
        if let v: VehicleDto = try? await apiClient.request(.myVehicle) {
            self.vehicle = v
        } else {
            self.vehicle = nil
        }
        
        // 3. Fetch car health
        if let h: CarHealthDto = try? await apiClient.request(.carHealth) {
            self.carHealth = h
        } else {
            self.carHealth = nil
        }
        
        // 4. Fetch home summary
        if let s: HomeSummaryDto = try? await apiClient.request(.homeSummary) {
            self.homeSummary = s
        }
        
        // 5. Fetch AI status
        if let ai: AiStatusDto = try? await apiClient.request(.aiStatus) {
            self.aiStatus = ai
        }
        
        // 6. Check for active job banner
        if let myJobsList: [JobDto] = try? await apiClient.request(.myJobs) {
            self.activeJob = myJobsList.first { job in
                ["PENDING", "MATCHED", "ARRIVED", "IN_PROGRESS", "WORK_DONE"].contains(job.status.uppercased())
            }
        }
        
        self.isLoading = false
    }
}
