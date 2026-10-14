import Foundation

public struct TriggerSosRequest: Codable {
    public let lat: Double
    public let lng: Double
    
    public init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
}

public struct SosDto: Codable, Identifiable, Equatable {
    public let id: String
    public let status: String
    public let lat: Double
    public let lng: Double
    public let createdAt: String
    public let requesterName: String?
    public let distanceKm: Double?
    
    public init(
        id: String,
        status: String,
        lat: Double,
        lng: Double,
        createdAt: String,
        requesterName: String? = nil,
        distanceKm: Double? = nil
    ) {
        self.id = id
        self.status = status
        self.lat = lat
        self.lng = lng
        self.createdAt = createdAt
        self.requesterName = requesterName
        self.distanceKm = distanceKm
    }
}

public struct TriggerSosResponse: Codable {
    public let sos: SosDto
    public let nearbyMechanicsNotified: Int
    
    public init(sos: SosDto, nearbyMechanicsNotified: Int) {
        self.sos = sos
        self.nearbyMechanicsNotified = nearbyMechanicsNotified
    }
}

public struct EmergencyContact: Codable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var phoneNumber: String
    public var relationship: String
    
    public init(id: UUID = UUID(), name: String, phoneNumber: String, relationship: String = "Family") {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
    }
}
