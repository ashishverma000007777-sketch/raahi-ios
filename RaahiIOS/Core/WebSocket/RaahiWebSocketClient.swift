import Foundation

@MainActor
public final class RaahiWebSocketClient: NSObject, ObservableObject {
    public static let shared = RaahiWebSocketClient()
    
    @Published public private(set) var connectionState: WsConnectionState = .disconnected
    @Published public private(set) var latestEvent: WsEvent?
    
    public var defaultBaseURL = URL(string: "wss://raahi-fdw0.onrender.com/ws")!
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession!
    private var tokenStorage: TokenStorageProtocol
    private var shouldReconnect = false
    private var reconnectAttempt = 0
    private var pingTimer: Task<Void, Never>?
    
    public init(tokenStorage: TokenStorageProtocol = TokenStorage.shared) {
        self.tokenStorage = tokenStorage
        super.init()
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }
    
    public func connect(baseURL: URL? = nil) {
        let targetURL = baseURL ?? defaultBaseURL
        guard let token = tokenStorage.getToken(), !token.isEmpty else {
            return
        }
        
        shouldReconnect = true
        openSocket(url: targetURL, token: token)
    }
    
    public func disconnect() {
        shouldReconnect = false
        pingTimer?.cancel()
        pingTimer = nil
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        connectionState = .disconnected
    }
    
    private func openSocket(url: URL, token: String) {
        // Cancel existing socket if any
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        connectionState = .connecting
        let task = urlSession.webSocketTask(with: request)
        self.webSocketTask = task
        task.resume()
        
        startListening()
        startPinging()
    }
    
    private func startListening() {
        guard let task = webSocketTask else { return }
        
        task.receive { [weak self] result in
            guard let self = self else { return }
            
            Task { @MainActor in
                switch result {
                case .success(let message):
                    self.handleMessage(message)
                    // Continue listening for next message
                    self.startListening()
                case .failure(let error):
                    self.handleDisconnection(error: error)
                }
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            if let event = parseEvent(text: text) {
                self.latestEvent = event
            }
        case .data(let data):
            if let text = String(data: data, encoding: .utf8), let event = parseEvent(text: text) {
                self.latestEvent = event
            }
        @unknown default:
            break
        }
    }
    
    public func parseEvent(text: String) -> WsEvent? {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let eventName = json["event"] as? String else {
            return nil
        }
        
        let eventData = json["data"] as? [String: Any] ?? [:]
        
        switch eventName {
        case "job:status_change":
            let jobId = (eventData["jobId"] as? String) ?? (eventData["job_id"] as? String) ?? ""
            let status = (eventData["status"] as? String) ?? ""
            guard !jobId.isEmpty else { return nil }
            return .jobStatusChange(jobId: jobId, status: status)
            
        case "job:helper_location":
            let jobId = (eventData["jobId"] as? String) ?? (eventData["job_id"] as? String) ?? ""
            let lat = (eventData["lat"] as? Double) ?? 0.0
            let lng = (eventData["lng"] as? Double) ?? 0.0
            guard !jobId.isEmpty else { return nil }
            return .jobHelperLocation(jobId: jobId, lat: lat, lng: lng)
            
        case "sos:nearby_alert":
            let sosId = (eventData["sosId"] as? String) ?? ""
            let lat = (eventData["lat"] as? Double) ?? 0.0
            let lng = (eventData["lng"] as? Double) ?? 0.0
            return .sosNearbyAlert(sosId: sosId, lat: lat, lng: lng)
            
        case "job:new_request":
            if let dataSub = try? JSONSerialization.data(withJSONObject: eventData),
               let job = try? JSONDecoder().decode(JobDto.self, from: dataSub) {
                return .jobNewRequest(job: job)
            }
            return .unknown(event: eventName, payload: text)
            
        default:
            return .unknown(event: eventName, payload: text)
        }
    }
    
    public func sendLocationUpdate(jobId: String, lat: Double, lng: Double) {
        let payload: [String: Any] = [
            "event": "job:location_update",
            "data": [
                "jobId": jobId,
                "job_id": jobId,
                "lat": lat,
                "lng": lng
            ]
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let string = String(data: data, encoding: .utf8) else {
            return
        }
        
        webSocketTask?.send(.string(string)) { _ in }
    }
    
    private func startPinging() {
        pingTimer?.cancel()
        pingTimer = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 20_000_000_000) // 20s
                guard let self = self, self.connectionState == .connected else { continue }
                self.webSocketTask?.sendPing { error in
                    if error != nil {
                        Task { @MainActor in
                            self.handleDisconnection(error: error)
                        }
                    }
                }
            }
        }
    }
    
    private func handleDisconnection(error: Error?) {
        connectionState = .disconnected
        pingTimer?.cancel()
        pingTimer = nil
        scheduleReconnect()
    }
    
    private func scheduleReconnect() {
        guard shouldReconnect else { return }
        reconnectAttempt += 1
        let backoff = min(30.0, Double(reconnectAttempt) * 2.0)
        
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
            guard let self = self, self.shouldReconnect else { return }
            if let token = self.tokenStorage.getToken() {
                self.openSocket(url: self.defaultBaseURL, token: token)
            }
        }
    }
}

extension RaahiWebSocketClient: URLSessionWebSocketDelegate {
    public nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Task { @MainActor in
            self.reconnectAttempt = 0
            self.connectionState = .connected
        }
    }
    
    public nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        Task { @MainActor in
            self.connectionState = .disconnected
            self.scheduleReconnect()
        }
    }
}
