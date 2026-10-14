import Foundation

public struct ApiEnvelope<T: Codable>: Codable {
    public let success: Bool
    public let data: T?
    public let error: ApiErrorBody?
    
    public init(success: Bool, data: T?, error: ApiErrorBody?) {
        self.success = success
        self.data = data
        self.error = error
    }
}

public struct ApiErrorBody: Codable, LocalizedError, Equatable {
    public let code: String
    public let message: String
    
    public init(code: String, message: String) {
        self.code = code
        self.message = message
    }
    
    public var errorDescription: String? {
        return message
    }
}

public enum APIError: LocalizedError, Equatable {
    case invalidURL
    case serverError(code: String, message: String)
    case unauthorized // 401
    case forbidden // 403
    case notFound(String) // 404
    case conflict(String) // 409
    case rateLimited(String) // 429
    case serviceUnavailable(String) // 503
    case networkFailure(String)
    case decodingError(String)
    case invalidResponse
    case missingToken
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid endpoint URL."
        case .serverError(let code, let message):
            return "[\(code)] \(message)"
        case .unauthorized:
            return "Session expired. Please log in again."
        case .forbidden:
            return "Access denied. You do not have permission for this action."
        case .notFound(let msg):
            return msg.isEmpty ? "Resource not found." : msg
        case .conflict(let msg):
            return msg.isEmpty ? "Conflict with current resource state." : msg
        case .rateLimited(let msg):
            return msg.isEmpty ? "Too many requests. Please slow down and try again." : msg
        case .serviceUnavailable(let msg):
            return msg.isEmpty ? "Service is temporarily unavailable. Please try again later." : msg
        case .networkFailure(let msg):
            return "Network connection error: \(msg)"
        case .decodingError(let msg):
            return "Failed to parse server response: \(msg)"
        case .invalidResponse:
            return "Invalid response from server."
        case .missingToken:
            return "Authentication required. No session token found."
        }
    }
    
    public var isAuthError: Bool {
        if case .unauthorized = self { return true }
        return false
    }
}
