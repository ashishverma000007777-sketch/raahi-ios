import XCTest
@testable import RaahiIOS

final class AIMechanicTests: XCTestCase {
    
    final class MockAPIClient: APIClientProtocol {
        var shouldFailWithUpstreamError = false
        var sentContent: String?
        
        func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
            if endpoint.path == "ai/sessions" && endpoint.method == .get {
                return [] as! T
            }
            if endpoint.path == "ai/sessions" && endpoint.method == .post {
                return AiSessionDto(id: "sess-100", title: "New Session") as! T
            }
            if endpoint.path == "ai/status" {
                return AiStatusDto(state: "AVAILABLE", available: true) as! T
            }
            if endpoint.path == "vehicles/me" {
                return VehicleDto(id: "v-1", brand: "Maruti", model: "Swift", modelYear: 2021, fuelType: "PETROL", registrationNumber: "DL10AB1234", odometerKm: 15000) as! T
            }
            if endpoint.path.contains("messages") && endpoint.method == .post {
                if shouldFailWithUpstreamError {
                    throw APIError.serverError(code: "AI_UNAVAILABLE", message: "Gemini provider quota reached. Please try later.")
                }
                return AiMessageDto(id: "msg-1", role: "ASSISTANT", content: "Check your alternator belt tension.", unavailable: false) as! T
            }
            throw APIError.notFound("Not found")
        }
        
        func uploadMultipart<T: Codable>(path: String, parts: [MultipartFormPart]) async throws -> T {
            throw APIError.notFound("Not found")
        }
    }
    
    @MainActor
    func testAIMechanicErrorPreservesPromptAndAllowsRetry() async {
        let mock = MockAPIClient()
        mock.shouldFailWithUpstreamError = true
        
        let vm = AIMechanicViewModel(apiClient: mock)
        await vm.start()
        
        let symptomPrompt = "Engine is knocking loudly when accelerating up a hill"
        vm.inputText = symptomPrompt
        
        await vm.sendMessage()
        
        // Verifications
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.errorMessage?.contains("quota") ?? false)
        XCTAssertEqual(vm.lastFailedPrompt, symptomPrompt)
        XCTAssertEqual(vm.inputText, symptomPrompt, "Input text MUST be preserved so user doesn't lose their prompt")
        
        // Now simulate upstream recovery and retry
        mock.shouldFailWithUpstreamError = false
        await vm.retryLastPrompt()
        
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.messages.isEmpty)
        XCTAssertEqual(vm.messages.last?.content, "Check your alternator belt tension.")
    }
    
    @MainActor
    func testAIMechanicInjectsVehicleContextOnFirstMessage() async {
        let mock = MockAPIClient()
        let vm = AIMechanicViewModel(apiClient: mock)
        await vm.start()
        
        XCTAssertNotNil(vm.activeVehicle)
        XCTAssertEqual(vm.activeVehicle?.brand, "Maruti")
        XCTAssertEqual(vm.activeVehicle?.model, "Swift")
    }
}
