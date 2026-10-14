import Foundation
import Combine

public enum AuthState: Equatable {
    case loading
    case unauthenticated
    case profileIncomplete(UserDto)
    case authenticated(UserDto)
    
    public var currentUser: UserDto? {
        switch self {
        case .authenticated(let user), .profileIncomplete(let user):
            return user
        default:
            return nil
        }
    }
}

@MainActor
public final class AuthManager: ObservableObject {
    public static let shared = AuthManager()
    
    @Published public private(set) var state: AuthState = .loading
    
    private let apiClient: APIClientProtocol
    private let tokenStorage: TokenStorageProtocol
    private let wsClient: RaahiWebSocketClient
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        apiClient: APIClientProtocol = APIClient.shared,
        tokenStorage: TokenStorageProtocol = TokenStorage.shared,
        wsClient: RaahiWebSocketClient = RaahiWebSocketClient.shared
    ) {
        self.apiClient = apiClient
        self.tokenStorage = tokenStorage
        self.wsClient = wsClient
        
        NotificationCenter.default.publisher(for: APIClient.sessionExpiredNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleSessionExpired()
            }
            .store(in: &cancellables)
    }
    
    public func checkCurrentSession() async {
        guard let token = tokenStorage.getToken(), !token.isEmpty else {
            self.state = .unauthenticated
            return
        }
        
        do {
            let user: UserDto = try await apiClient.request(.authMe)
            self.tokenStorage.saveUserId(user.id)
            self.wsClient.connect()
            
            if isProfileComplete(user) {
                self.state = .authenticated(user)
            } else {
                self.state = .profileIncomplete(user)
            }
        } catch {
            // Token is invalid or expired
            tokenStorage.clearToken()
            self.state = .unauthenticated
        }
    }
    
    public func loginWithFirebaseToken(idToken: String, requestedRole: String = "DRIVER") async throws -> VerifyResponse {
        let req = VerifyRequest(idToken: idToken, requestedRole: requestedRole)
        let response: VerifyResponse = try await apiClient.request(.authVerify(req: req))
        
        // Save session in secure Keychain
        tokenStorage.saveToken(response.token)
        tokenStorage.saveUserId(response.user.id)
        
        // Connect live WebSocket
        wsClient.connect()
        
        if response.isNewUser || !isProfileComplete(response.user) {
            self.state = .profileIncomplete(response.user)
        } else {
            self.state = .authenticated(response.user)
        }
        
        return response
    }
    
    public func updateProfile(name: String?, vehicleType: String?, vehicleReg: String?, language: String? = "en") async throws -> UserDto {
        let req = UpdateProfileRequest(name: name, vehicleType: vehicleType, vehicleReg: vehicleReg, language: language)
        let updated: UserDto = try await apiClient.request(.authUpdateProfile(req: req))
        
        if isProfileComplete(updated) {
            self.state = .authenticated(updated)
        } else {
            self.state = .profileIncomplete(updated)
        }
        return updated
    }
    
    public func logout() async {
        // Fire-and-forget backend logout
        Task {
            _ = try? await apiClient.request(.authLogout) as [String: Bool]
        }
        
        tokenStorage.clearToken()
        wsClient.disconnect()
        self.state = .unauthenticated
    }
    
    private func handleSessionExpired() {
        tokenStorage.clearToken()
        wsClient.disconnect()
        self.state = .unauthenticated
    }
    
    private func isProfileComplete(_ user: UserDto) -> Bool {
        guard let name = user.name, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        return true
    }
}
