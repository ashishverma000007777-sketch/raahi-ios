import Foundation

public protocol TokenStorageProtocol {
    func getToken() -> String?
    func saveToken(_ token: String)
    func clearToken()
    func getUserId() -> String?
    func saveUserId(_ id: String)
}

public final class TokenStorage: TokenStorageProtocol {
    public static let shared = TokenStorage()
    
    private let tokenKey = "raahi.auth.jwt_token"
    private let userIdKey = "raahi.auth.user_id"
    private let keychain = KeychainManager.shared
    
    public init() {}
    
    public func getToken() -> String? {
        keychain.get(key: tokenKey)
    }
    
    public func saveToken(_ token: String) {
        keychain.save(key: tokenKey, value: token)
    }
    
    public func clearToken() {
        keychain.delete(key: tokenKey)
        keychain.delete(key: userIdKey)
    }
    
    public func getUserId() -> String? {
        keychain.get(key: userIdKey)
    }
    
    public func saveUserId(_ id: String) {
        keychain.save(key: userIdKey, value: id)
    }
}
