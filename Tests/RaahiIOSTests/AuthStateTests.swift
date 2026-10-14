import XCTest
@testable import RaahiIOS

final class AuthStateTests: XCTestCase {
    
    final class MockTokenStorage: TokenStorageProtocol {
        var token: String? = nil
        var userId: String? = nil
        
        func getToken() -> String? { token }
        func saveToken(_ t: String) { token = t }
        func clearToken() { token = nil; userId = nil }
        func getUserId() -> String? { userId }
        func saveUserId(_ id: String) { userId = id }
    }
    
    final class MockAPIClient: APIClientProtocol {
        var meUser: UserDto? = nil
        var shouldFailAuth = false
        
        func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
            if endpoint.path == "auth/me" {
                if shouldFailAuth || meUser == nil {
                    throw APIError.unauthorized
                }
                return meUser! as! T
            }
            throw APIError.notFound("Not found")
        }
        
        func uploadMultipart<T: Codable>(path: String, parts: [MultipartFormPart]) async throws -> T {
            throw APIError.notFound("Not found")
        }
    }
    
    @MainActor
    func testCheckSessionWithoutTokenResultsInUnauthenticated() async {
        let storage = MockTokenStorage()
        let api = MockAPIClient()
        let authManager = AuthManager(apiClient: api, tokenStorage: storage)
        
        await authManager.checkCurrentSession()
        XCTAssertEqual(authManager.state, .unauthenticated)
    }
    
    @MainActor
    func testCheckSessionWithCompleteProfileResultsInAuthenticated() async {
        let storage = MockTokenStorage()
        storage.saveToken("valid-jwt-token")
        
        let api = MockAPIClient()
        api.meUser = UserDto(id: "u-1", name: "Rohan", phone: "+919876543210", role: "DRIVER", vehicleType: "Car", vehicleReg: "DL01AB1234")
        
        let authManager = AuthManager(apiClient: api, tokenStorage: storage)
        await authManager.checkCurrentSession()
        
        guard case .authenticated(let user) = authManager.state else {
            XCTFail("Expected authenticated state")
            return
        }
        XCTAssertEqual(user.name, "Rohan")
    }
    
    @MainActor
    func testCheckSessionWithIncompleteProfileResultsInProfileIncomplete() async {
        let storage = MockTokenStorage()
        storage.saveToken("valid-jwt-token")
        
        let api = MockAPIClient()
        api.meUser = UserDto(id: "u-2", name: nil, phone: "+919876543210", role: "DRIVER") // Name missing
        
        let authManager = AuthManager(apiClient: api, tokenStorage: storage)
        await authManager.checkCurrentSession()
        
        guard case .profileIncomplete(let user) = authManager.state else {
            XCTFail("Expected profileIncomplete state")
            return
        }
        XCTAssertEqual(user.id, "u-2")
    }
}
