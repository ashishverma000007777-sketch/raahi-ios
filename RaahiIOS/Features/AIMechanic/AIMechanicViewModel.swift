import Foundation

@MainActor
public final class AIMechanicViewModel: ObservableObject {
    @Published public var sessionId: String? = nil
    @Published public var messages: [AiMessageDto] = []
    @Published public var inputText: String = ""
    @Published public var isSending: Bool = false
    @Published public var isLoadingHistory: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var lastFailedPrompt: String? = nil
    @Published public var aiStatus: AiStatusDto? = nil
    @Published public var activeVehicle: VehicleDto? = nil
    
    public let quickPrompts = [
        "Loud clicking sound on cold engine start",
        "Brake squealing and vibrating when stopping",
        "AC blowing warm air when idling",
        "White exhaust smoke on acceleration",
        "Battery warning light flickering",
        "Gear slips when shifting into 3rd"
    ]
    
    private let apiClient: APIClientProtocol
    
    public init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    public func start() async {
        isLoadingHistory = true
        errorMessage = nil
        
        // 1. Fetch AI Provider Status
        if let status: AiStatusDto = try? await apiClient.request(.aiStatus) {
            self.aiStatus = status
        }
        
        // 2. Fetch active vehicle for context injection
        if let vehicle: VehicleDto = try? await apiClient.request(.myVehicle) {
            self.activeVehicle = vehicle
        }
        
        // 3. Restore or create session
        do {
            let sessions: [AiSessionDto] = try await apiClient.request(.myAiSessions)
            if let latest = sessions.first {
                self.sessionId = latest.id
                let history: [AiMessageDto] = try await apiClient.request(.aiSessionMessages(id: latest.id))
                self.messages = history
            } else {
                let newSession: AiSessionDto = try await apiClient.request(.createAiSession)
                self.sessionId = newSession.id
                self.messages = []
            }
            self.isLoadingHistory = false
        } catch {
            self.isLoadingHistory = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func sendMessage(_ text: String? = nil) async {
        let promptToSend = (text ?? inputText).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !promptToSend.isEmpty, !isSending else { return }
        
        isSending = true
        errorMessage = nil
        lastFailedPrompt = nil
        
        // Optimistic UI update
        let optimisticId = "pending-\(UUID().uuidString)"
        let optimisticMessage = AiMessageDto(id: optimisticId, role: "USER", content: promptToSend, createdAt: "", unavailable: false)
        messages.append(optimisticMessage)
        let originalInput = inputText
        inputText = ""
        
        // Context enrichment with active vehicle details on first message
        var payload = promptToSend
        if messages.count <= 1, let vehicle = activeVehicle {
            let variantText = vehicle.variant != nil ? " \(vehicle.variant!)" : ""
            payload += "\n[Context: Vehicle is \(vehicle.brand) \(vehicle.model)\(variantText), Fuel: \(vehicle.fuelType), Reg: \(vehicle.registrationNumber)]"
        }
        
        do {
            // Ensure session exists
            if sessionId == nil {
                let newSession: AiSessionDto = try await apiClient.request(.createAiSession)
                self.sessionId = newSession.id
            }
            
            guard let sid = sessionId else {
                throw APIError.invalidResponse
            }
            
            let reply: AiMessageDto = try await apiClient.request(.sendAiMessage(sessionId: sid, content: payload))
            
            if reply.unavailable {
                self.errorMessage = reply.content
                self.lastFailedPrompt = promptToSend
                self.inputText = promptToSend
            }
            
            self.messages.append(reply)
            self.isSending = false
        } catch {
            self.isSending = false
            self.errorMessage = error.localizedDescription
            self.lastFailedPrompt = promptToSend
            self.inputText = originalInput.isEmpty ? promptToSend : originalInput
            // Remove optimistic message on failure
            self.messages.removeAll { $0.id == optimisticId }
        }
    }
    
    public func retryLastPrompt() async {
        if let failed = lastFailedPrompt {
            await sendMessage(failed)
        }
    }
    
    public func editLastQuestion() {
        if let failed = lastFailedPrompt {
            self.inputText = failed
            self.errorMessage = nil
        }
    }
}
