import Foundation

public struct UserDto: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String?
    public let phone: String?
    public let role: String
    public let vehicleType: String?
    public let vehicleReg: String?
    public let isVerified: Bool
    public let ratingAvg: Double
    public let totalHelps: Int
    public let email: String?
    public let emailVerified: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, phone, role, vehicleType, vehicleReg
        case isVerified, verified
        case ratingAvg, totalHelps, email, emailVerified
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        role = try container.decode(String.self, forKey: .role)
        vehicleType = try container.decodeIfPresent(String.self, forKey: .vehicleType)
        vehicleReg = try container.decodeIfPresent(String.self, forKey: .vehicleReg)
        
        // Handle isVerified / verified alias
        if let v = try? container.decode(Bool.self, forKey: .isVerified) {
            isVerified = v
        } else if let v = try? container.decode(Bool.self, forKey: .verified) {
            isVerified = v
        } else {
            isVerified = false
        }
        
        ratingAvg = (try? container.decode(Double.self, forKey: .ratingAvg)) ?? 0.0
        totalHelps = (try? container.decode(Int.self, forKey: .totalHelps)) ?? 0
        email = try container.decodeIfPresent(String.self, forKey: .email)
        emailVerified = (try? container.decode(Bool.self, forKey: .emailVerified)) ?? false
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encode(role, forKey: .role)
        try container.encodeIfPresent(vehicleType, forKey: .vehicleType)
        try container.encodeIfPresent(vehicleReg, forKey: .vehicleReg)
        try container.encode(isVerified, forKey: .isVerified)
        try container.encode(ratingAvg, forKey: .ratingAvg)
        try container.encode(totalHelps, forKey: .totalHelps)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encode(emailVerified, forKey: .emailVerified)
    }
    
    public init(
        id: String,
        name: String?,
        phone: String?,
        role: String = "DRIVER",
        vehicleType: String? = nil,
        vehicleReg: String? = nil,
        isVerified: Bool = false,
        ratingAvg: Double = 0.0,
        totalHelps: Int = 0,
        email: String? = nil,
        emailVerified: Bool = false
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.role = role
        self.vehicleType = vehicleType
        self.vehicleReg = vehicleReg
        self.isVerified = isVerified
        self.ratingAvg = ratingAvg
        self.totalHelps = totalHelps
        self.email = email
        self.emailVerified = emailVerified
    }
}

public struct VerifyRequest: Codable {
    public let idToken: String
    public let requestedRole: String?
    public let email: String?
    
    public init(idToken: String, requestedRole: String? = nil, email: String? = nil) {
        self.idToken = idToken
        self.requestedRole = requestedRole
        self.email = email
    }
}

public struct VerifyResponse: Codable {
    public let token: String
    public let isNewUser: Bool
    public let user: UserDto
    
    public init(token: String, isNewUser: Bool, user: UserDto) {
        self.token = token
        self.isNewUser = isNewUser
        self.user = user
    }
}

public struct UpdateProfileRequest: Codable {
    public let name: String?
    public let vehicleType: String?
    public let vehicleReg: String?
    public let language: String?
    
    public init(name: String? = nil, vehicleType: String? = nil, vehicleReg: String? = nil, language: String? = nil) {
        self.name = name
        self.vehicleType = vehicleType
        self.vehicleReg = vehicleReg
        self.language = language
    }
}

public struct FcmTokenRequest: Codable {
    public let token: String
    
    public init(token: String) {
        self.token = token
    }
}
