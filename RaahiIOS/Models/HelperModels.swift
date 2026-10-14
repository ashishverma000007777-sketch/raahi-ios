import Foundation

public struct HelperStatusDto: Codable, Equatable {
    public let applicationStatus: String // NONE / PENDING / APPROVED / REJECTED / SUSPENDED
    public let rejectionReason: String?
    public let suspensionReason: String?
    public let accountActive: Bool
    public let blockedUntil: String?
    public let blockReason: String?
    public let online: Bool
    public let commissionBalance: Double
    public let commissionDue: Bool
    public let commissionRate: Double
    public let canAcceptJobs: Bool
    public let ratingAvg: Double
    public let totalHelps: Int
    public let name: String?
    public let phone: String?
    public let services: String?
    public let serviceRadiusKm: Int?
}

public struct LedgerEntryDto: Codable, Identifiable, Equatable {
    public let id: String?
    public let job_id: String?
    public let entry_type: String
    public let amount: Double
    public let job_amount: Double?
    public let commission_rate: Double?
    public let payment_mode: String?
    public let reference: String?
    public let created_at: String?
}

public struct HelperCommissionDto: Codable, Equatable {
    public let balance: Double
    public let due: Double
    public let rate: Double
    public let entries: [LedgerEntryDto]
}

public struct HelperEarningsDto: Codable, Equatable {
    public let completedJobs: Int
    public let grossEarnings: Double
    public let totalCommission: Double
    public let netEarnings: Double
    public let commissionBalance: Double
}

public struct HelperRatingDto: Codable, Identifiable, Equatable {
    public var id: String { job_id ?? UUID().uuidString }
    public let job_id: String?
    public let stars: Int
    public let comment: String?
    public let created_at: String?
}

public struct HelperJobHistoryDto: Codable, Identifiable, Equatable {
    public var id: String { jobId }
    public let jobId: String
    public let status: String
    public let problemType: String?
    public let amount: Double?
    public let paymentMode: String?
    public let rated: Bool?
    public let createdAt: String?
    public let completedAt: String?
}

public struct DocSummaryDto: Codable, Equatable {
    public let id: String
    public let aiStatus: String
    public let aiNote: String?
}

public struct HelperApplicationDto: Codable, Identifiable, Equatable {
    public let id: String
    public let status: String
    public let email: String?
    public let rejectionReason: String?
    public let submittedAt: String?
    public let reviewedAt: String?
    public let aadhaarFront: DocSummaryDto?
    public let aadhaarBack: DocSummaryDto?
    public let selfie: DocSummaryDto?
    public let applicantName: String?
    public let applicantPhone: String?
    public let suspensionReason: String?
    public let experienceYears: Int?
    public let serviceArea: String?
    public let services: String?
    public let equipment: String?
    public let vehicleType: String?
    public let vehicleBrand: String?
    public let vehicleModel: String?
    public let vehicleVariant: String?
    public let vehicleReg: String?
    public let serviceRadiusKm: Int?
    public let payoutUpi: String?
    public let payoutHolder: String?
    public let payoutBankAcctMasked: String?
    public let payoutIfsc: String?
    public let emailVerified: Bool?
    public let phoneVerified: Bool?
}

public struct AvailabilityRequest: Codable {
    public let online: Bool
    public let lat: Double?
    public let lng: Double?
    
    public init(online: Bool, lat: Double? = nil, lng: Double? = nil) {
        self.online = online
        self.lat = lat
        self.lng = lng
    }
}
