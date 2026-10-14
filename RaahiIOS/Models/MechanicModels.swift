import Foundation

public struct MechanicDto: Codable, Identifiable, Equatable {
    public var id: String { userId }
    public let userId: String
    public let name: String?
    public let phone: String?
    public let shopName: String?
    public let specializations: String?
    public let isAvailable: Bool
    public let lat: Double?
    public let lng: Double?
    public let distanceKm: Double
    public let ratingAvg: Double
    
    public init(
        userId: String,
        name: String?,
        phone: String?,
        shopName: String?,
        specializations: String?,
        isAvailable: Bool,
        lat: Double?,
        lng: Double?,
        distanceKm: Double = 0.0,
        ratingAvg: Double = 0.0
    ) {
        self.userId = userId
        self.name = name
        self.phone = phone
        self.shopName = shopName
        self.specializations = specializations
        self.isAvailable = isAvailable
        self.lat = lat
        self.lng = lng
        self.distanceKm = distanceKm
        self.ratingAvg = ratingAvg
    }
}
