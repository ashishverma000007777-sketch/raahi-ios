import Foundation

@MainActor
public final class MyJobsViewModel: ObservableObject {
    @Published public var jobs: [JobDto] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let apiClient: APIClientProtocol
    
    public init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    public var activeJobs: [JobDto] {
        jobs.filter { job in
            ["PENDING", "MATCHED", "ARRIVED", "IN_PROGRESS", "WORK_DONE"].contains(job.status.uppercased())
        }
    }
    
    public var pastJobs: [JobDto] {
        jobs.filter { job in
            ["COMPLETED", "CANCELLED", "EXPIRED"].contains(job.status.uppercased())
        }
    }
    
    public func loadJobs() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched: [JobDto] = try await apiClient.request(.myJobs)
            self.jobs = fetched
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
}
