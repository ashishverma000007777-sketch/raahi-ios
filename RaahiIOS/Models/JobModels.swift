import Foundation

public struct JobDto: Codable, Identifiable, Equatable {
    public let id: String
    public let status: String
    public let problemType: String
    public let problemDesc: String?
    public let lat: Double
    public let lng: Double
    public let rewardAmount: Double
    public let helperOtp: String?
    public let requesterName: String?
    public let requesterPhone: String?
    public let helperName: String?
    public let helperPhone: String?
    public let helperRatingAvg: Double?
    public let helperTotalHelps: Int?
    public let helperVerified: Bool?
    public let viewerRole: String? // "REQUESTER" or "HELPER"
    public let cancelAllowed: Bool?
    public let arrivalMethod: String?
    public let arrivedAt: String?
    public let finalAmount: Double?
    public let paymentMode: String?
    public let rated: Bool?
    public let completionOtp: String?
    public let commissionAmount: Double?
    public let distanceKm: Double?
    public let createdAt: String?
    public let helperLat: Double?
    public let helperLng: Double?
    public let nearbyHelperCount: Int?
    
    public init(
        id: String,
        status: String,
        problemType: String,
        problemDesc: String? = nil,
        lat: Double,
        lng: Double,
        rewardAmount: Double = 0.0,
        helperOtp: String? = nil,
        requesterName: String? = nil,
        requesterPhone: String? = nil,
        helperName: String? = nil,
        helperPhone: String? = nil,
        helperRatingAvg: Double? = nil,
        helperTotalHelps: Int? = nil,
        helperVerified: Bool? = nil,
        viewerRole: String? = nil,
        cancelAllowed: Bool? = nil,
        arrivalMethod: String? = nil,
        arrivedAt: String? = nil,
        finalAmount: Double? = nil,
        paymentMode: String? = nil,
        rated: Bool? = nil,
        completionOtp: String? = nil,
        commissionAmount: Double? = nil,
        distanceKm: Double? = nil,
        createdAt: String? = nil,
        helperLat: Double? = nil,
        helperLng: Double? = nil,
        nearbyHelperCount: Int? = nil
    ) {
        self.id = id
        self.status = status
        self.problemType = problemType
        self.problemDesc = problemDesc
        self.lat = lat
        self.lng = lng
        self.rewardAmount = rewardAmount
        self.helperOtp = helperOtp
        self.requesterName = requesterName
        self.requesterPhone = requesterPhone
        self.helperName = helperName
        self.helperPhone = helperPhone
        self.helperRatingAvg = helperRatingAvg
        self.helperTotalHelps = helperTotalHelps
        self.helperVerified = helperVerified
        self.viewerRole = viewerRole
        self.cancelAllowed = cancelAllowed
        self.arrivalMethod = arrivalMethod
        self.arrivedAt = arrivedAt
        self.finalAmount = finalAmount
        self.paymentMode = paymentMode
        self.rated = rated
        self.completionOtp = completionOtp
        self.commissionAmount = commissionAmount
        self.distanceKm = distanceKm
        self.createdAt = createdAt
        self.helperLat = helperLat
        self.helperLng = helperLng
        self.nearbyHelperCount = nearbyHelperCount
    }
}

public struct CreateJobRequest: Codable {
    public let problemType: String
    public let problemDesc: String?
    public let lat: Double
    public let lng: Double
    public let highwayName: String?
    public let rewardAmount: Double
    
    public init(
        problemType: String,
        problemDesc: String? = nil,
        lat: Double,
        lng: Double,
        highwayName: String? = nil,
        rewardAmount: Double = 0.0
    ) {
        self.problemType = problemType
        self.problemDesc = problemDesc
        self.lat = lat
        self.lng = lng
        self.highwayName = highwayName
        self.rewardAmount = rewardAmount
    }
}

public struct VerifyOtpRequest: Codable {
    public let otp: String
    
    public init(otp: String) {
        self.otp = otp
    }
}

public struct ArriveRequest: Codable {
    public let lat: Double?
    public let lng: Double?
    public let otp: String?
    
    public init(lat: Double? = nil, lng: Double? = nil, otp: String? = nil) {
        self.lat = lat
        self.lng = lng
        self.otp = otp
    }
}

public struct WorkDoneRequest: Codable {
    public let finalAmount: Double?
    public let paymentMode: String
    
    public init(finalAmount: Double?, paymentMode: String = "CASH") {
        self.finalAmount = finalAmount
        self.paymentMode = paymentMode
    }
}

public struct RateRequest: Codable {
    public let stars: Int
    public let comment: String?
    
    public init(stars: Int, comment: String? = nil) {
        self.stars = stars
        self.comment = comment
    }
}

public struct CancelRequest: Codable {
    public let reason: String?
    
    public init(reason: String? = nil) {
        self.reason = reason
    }
}

public struct ReportRequest: Codable {
    public let message: String
    public let kind: String
    
    public init(message: String, kind: String = "ISSUE") {
        self.message = message
        self.kind = kind
    }
}

public struct JobLocationUpdateRequest: Codable {
    public let lat: Double
    public let lng: Double
    
    public init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
}
