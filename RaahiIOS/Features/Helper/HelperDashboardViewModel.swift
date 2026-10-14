import Foundation
import CoreLocation
import Combine

@MainActor
public final class HelperDashboardViewModel: ObservableObject {
    @Published public var helperStatus: HelperStatusDto? = nil
    @Published public var commission: HelperCommissionDto? = nil
    @Published public var earnings: HelperEarningsDto? = nil
    @Published public var availableJobs: [JobDto] = []
    @Published public var isOnline: Bool = false
    
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var incomingJobAlert: JobDto? = nil
    
    private let apiClient: APIClientProtocol
    private let wsClient: RaahiWebSocketClient
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        apiClient: APIClientProtocol = APIClient.shared,
        wsClient: RaahiWebSocketClient = RaahiWebSocketClient.shared,
        locationManager: LocationManager = LocationManager.shared
    ) {
        self.apiClient = apiClient
        self.wsClient = wsClient
        self.locationManager = locationManager
        
        setupWebSocketListener()
    }
    
    public func loadDashboard() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let statusFetch: HelperStatusDto = apiClient.request(.helperStatus)
            async let commFetch: HelperCommissionDto = apiClient.request(.helperCommission)
            async let earningsFetch: HelperEarningsDto = apiClient.request(.helperEarnings)
            
            let (s, c, e) = try await (statusFetch, commFetch, earningsFetch)
            self.helperStatus = s
            self.commission = c
            self.earnings = e
            self.isOnline = s.online
            
            await loadAvailableJobs()
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func loadAvailableJobs() async {
        let loc = locationManager.currentLocation?.coordinate
        do {
            let jobs: [JobDto] = try await apiClient.request(.availableJobs(lat: loc?.latitude, lng: loc?.longitude))
            self.availableJobs = jobs
        } catch {
            // Keep existing jobs if fail
        }
    }
    
    public func toggleAvailability(to online: Bool) async {
        let loc = locationManager.currentLocation?.coordinate
        isOnline = online
        
        do {
            _ = try await apiClient.request(.setHelperAvailability(online: online, lat: loc?.latitude, lng: loc?.longitude)) as [String: Bool]
            await loadDashboard()
        } catch {
            self.isOnline = !online
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func acceptJob(id: String) async -> JobDto? {
        isLoading = true
        errorMessage = nil
        
        do {
            let accepted: JobDto = try await apiClient.request(.acceptJob(id: id))
            self.isLoading = false
            await loadAvailableJobs()
            return accepted
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            return nil
        }
    }
    
    private func setupWebSocketListener() {
        wsClient.$latestEvent
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .jobNewRequest(let job):
                    self.incomingJobAlert = job
                    Task { await self.loadAvailableJobs() }
                case .jobStatusChange(_, _):
                    Task { await self.loadAvailableJobs() }
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
