import Foundation

public struct AiSessionDto: Codable, Identifiable, Equatable {
    public let id: String
    public let title: String?
    public let createdAt: String
    public let lastMessageAt: String
    
    public init(id: String, title: String? = nil, createdAt: String = "", lastMessageAt: String = "") {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.lastMessageAt = lastMessageAt
    }
}

public struct AiMessageDto: Codable, Identifiable, Equatable {
    public let id: String
    public let role: String // "USER" or "ASSISTANT"
    public let content: String
    public let createdAt: String
    public let unavailable: Bool
    
    public init(id: String, role: String, content: String, createdAt: String = "", unavailable: Bool = false) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
        self.unavailable = unavailable
    }
}

public struct SendAiMessageRequest: Codable {
    public let content: String
    
    public init(content: String) {
        self.content = content
    }
}

public struct AiStatusDto: Codable, Equatable {
    public let state: String
    public let available: Bool
    public let provider: String?
    public let message: String?
    
    public init(state: String = "AVAILABLE", available: Bool = true, provider: String? = "gemini", message: String? = nil) {
        self.state = state
        self.available = available
        self.provider = provider
        self.message = message
    }
}
