import Foundation
import CoreLocation
import Combine

@MainActor
public final class JobDetailStatusViewModel: ObservableObject {
    @Published public var job: JobDto
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var helperLocation: CLLocationCoordinate2D? = nil
    
    // Actions state
    @Published public var otpInput: String = ""
    @Published public var isVerifyingOtp: Bool = false
    @Published public var ratingStars: Int = 5
    @Published public var ratingComment: String = ""
    @Published public var showRatingSheet: Bool = false
    @Published public var showCancelDialog: Bool = false
    @Published public var showReportDialog: Bool = false
    @Published public var reportReason: String = ""
    
    private let apiClient: APIClientProtocol
    private let wsClient: RaahiWebSocketClient
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    private var pollingTask: Task<Void, Never>?
    private var locationStreamTask: Task<Void, Never>?
    
    public init(
        job: JobDto,
        apiClient: APIClientProtocol = APIClient.shared,
        wsClient: RaahiWebSocketClient = RaahiWebSocketClient.shared,
        locationManager: LocationManager = LocationManager.shared
    ) {
        self.job = job
        self.apiClient = apiClient
        self.wsClient = wsClient
        self.locationManager = locationManager
        
        if let lat = job.helperLat, let lng = job.helperLng {
            self.helperLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        
        setupWebSocketListener()
        startPollingFallback()
    }
    
    deinit {
        pollingTask?.cancel()
        locationStreamTask?.cancel()
    }
    
    public var isRequester: Bool {
        job.viewerRole == "REQUESTER"
    }
    
    public var isHelper: Bool {
        job.viewerRole == "HELPER"
    }
    
    public var isJobActive: Bool {
        ["PENDING", "MATCHED", "ARRIVED", "IN_PROGRESS", "WORK_DONE"].contains(job.status.uppercased())
    }
    
    public var canCancel: Bool {
        // Cancellation allowed in PENDING or MATCHED
        ["PENDING", "MATCHED"].contains(job.status.uppercased()) && (job.cancelAllowed ?? true)
    }
    
    public func reloadJob() async {
        do {
            let updated: JobDto = try await apiClient.request(.getJob(id: job.id))
            self.job = updated
            if let lat = updated.helperLat, let lng = updated.helperLng {
                self.helperLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            }
            manageHelperLocationStreaming()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Helper Actions
    public func helperArrive() async {
        isLoading = true
        errorMessage = nil
        let loc = locationManager.currentLocation?.coordinate
        let req = ArriveRequest(lat: loc?.latitude, lng: loc?.longitude, otp: nil)
        
        do {
            let updated: JobDto = try await apiClient.request(.arriveJob(id: job.id, req: req))
            self.job = updated
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func verifyHandoffOtp() async {
        guard otpInput.count == 6 else {
            errorMessage = "Please enter the 6-digit OTP provided by the driver."
            return
        }
        
        isVerifyingOtp = true
        errorMessage = nil
        
        do {
            let updated: JobDto = try await apiClient.request(.verifyJobOtp(id: job.id, otp: otpInput))
            self.job = updated
            self.isVerifyingOtp = false
            self.otpInput = ""
            manageHelperLocationStreaming()
        } catch {
            self.isVerifyingOtp = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func helperStartWork() async {
        isLoading = true
        errorMessage = nil
        do {
            let updated: JobDto = try await apiClient.request(.startJob(id: job.id))
            self.job = updated
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func helperMarkWorkDone() async {
        isLoading = true
        errorMessage = nil
        let req = WorkDoneRequest(finalAmount: job.rewardAmount, paymentMode: "CASH")
        do {
            let updated: JobDto = try await apiClient.request(.workDone(id: job.id, req: req))
            self.job = updated
            self.isLoading = false
            locationStreamTask?.cancel()
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Requester Actions
    public func confirmCompletion() async {
        isLoading = true
        errorMessage = nil
        let otp = job.completionOtp ?? job.helperOtp ?? "000000"
        do {
            let updated: JobDto = try await apiClient.request(.confirmJobCompletion(id: job.id, otp: otp))
            self.job = updated
            self.isLoading = false
            self.showRatingSheet = true
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func cancelJob(reason: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await apiClient.request(.cancelJob(id: job.id, reason: reason)) as [String: AnyCodable]
            await reloadJob()
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func submitRating() async {
        isLoading = true
        errorMessage = nil
        let req = RateRequest(stars: ratingStars, comment: ratingComment.isEmpty ? nil : ratingComment)
        do {
            _ = try await apiClient.request(.rateJob(id: job.id, req: req)) as [String: Bool]
            self.showRatingSheet = false
            await reloadJob()
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func reportIssue() async {
        guard !reportReason.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        let req = ReportRequest(message: reportReason, kind: "ISSUE")
        do {
            _ = try await apiClient.request(.reportJob(id: job.id, req: req)) as [String: Bool]
            self.showReportDialog = false
            self.reportReason = ""
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - WebSocket and Polling
    private func setupWebSocketListener() {
        wsClient.$latestEvent
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .jobStatusChange(let id, _):
                    if id == self.job.id {
                        Task { await self.reloadJob() }
                    }
                case .jobHelperLocation(let id, let lat, let lng):
                    if id == self.job.id {
                        self.helperLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func startPollingFallback() {
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 15_000_000_000) // 15s fallback poll
                guard let self = self, self.isJobActive else { break }
                await self.reloadJob()
            }
        }
    }
    
    private func manageHelperLocationStreaming() {
        if isHelper && job.status.uppercased() == "IN_PROGRESS" {
            locationManager.startUpdating()
            locationStreamTask?.cancel()
            locationStreamTask = Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 8_000_000_000) // every 8s
                    guard let self = self else { break }
                    if let loc = self.locationManager.currentLocation?.coordinate {
                        self.wsClient.sendLocationUpdate(jobId: self.job.id, lat: loc.latitude, lng: loc.longitude)
                    }
                }
            }
        } else {
            locationStreamTask?.cancel()
        }
    }
}
