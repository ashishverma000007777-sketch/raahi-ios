import Foundation

public struct FuelRateDto: Codable, Identifiable, Equatable {
    public var id: String { state }
    public let state: String
    public let petrol: Double
    public let diesel: Double
    public let cng: Double?
    public let updatedAt: String
    public let source: String?
}

public struct ShopProductDto: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let category: String
    public let price: Double
    public let discountPrice: Double?
    public let brand: String?
    public let rating: Double?
    public let reviewCount: Int?
    public let description: String?
    public let affiliateUrl: String
    public let imageUrl: String
}

public struct SubscriptionPlanDto: Codable, Identifiable, Equatable {
    public var id: String { tier }
    public let tier: String
    public let name: String
    public let priceMonthly: Double
    public let priceYearly: Double
    public let features: [String]
}

public struct SubscriptionStatusDto: Codable, Equatable {
    public let tier: String
    public let status: String
    public let expiresAt: String?
    public let isActive: Bool
}

public struct StreakDto: Codable, Equatable {
    public let currentStreak: Int
    public let longestStreak: Int
    public let totalCheckins: Int
    public let lastCheckin: String?
    public let canCheckin: Bool
    public let reward: String?
}

public struct AlertDto: Codable, Identifiable, Equatable {
    public let id: String
    public let type: String
    public let message: String
    public let location: String?
    public let lat: Double?
    public let lng: Double?
    public let upvotes: Int
    public let downvotes: Int
    public let createdAt: String
    public let postedBy: String?
    public let myVote: String?
}

public struct CreateAlertRequest: Codable {
    public let type: String
    public let message: String
    public let location: String?
    public let lat: Double?
    public let lng: Double?
    
    public init(type: String, message: String, location: String? = nil, lat: Double? = nil, lng: Double? = nil) {
        self.type = type
        self.message = message
        self.location = location
        self.lat = lat
        self.lng = lng
    }
}

public struct VoteRequest: Codable {
    public let vote: String
    
    public init(vote: String) {
        self.vote = vote
    }
}

public struct TipDto: Codable, Equatable {
    public let title: String
    public let body: String
}

public struct WeeklyKmDto: Codable, Equatable {
    public let km: Int?
    public let since: String?
    public let fullWindow: Bool
    public let unavailableReason: String?
}

public struct HomeSummaryDto: Codable, Equatable {
    public let weeklyKm: WeeklyKmDto?
    public let helpsGivenThisWeek: Int
    public let unreadNotifications: Int
}

public struct NotificationDto: Codable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let body: String
    public let createdAt: String
    public let read: Bool
}

public struct StreakBadgeDto: Codable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let icon: String
    public let badgeText: String
    public let isAchieved: Bool
    public let currentCount: Int
    public let targetCount: Int
    public let progressText: String
}

public struct StateFuelRateDto: Codable, Identifiable, Equatable {
    public var id: String { state }
    public let state: String
    public let petrol: Double?
    public let diesel: Double?
    public let cng: Double?
}

public struct FuelPriceRadarDto: Codable, Equatable {
    public let homeState: String?
    public let homeStatePetrol: Double?
    public let homeStateDiesel: Double?
    public let cheapestNearbyState: String?
    public let cheapestStatePetrol: Double?
    public let priceDifferencePerLitre: Double?
    public let radarAdvice: String?
    public let stateRates: [StateFuelRateDto]
}

public struct CommunityBenchmarkDto: Codable, Equatable {
    public let available: Bool
    public let vehicleModel: String?
    public let fuelType: String?
    public let userAvgMileage: Double?
    public let communityAvgMileage: Double?
    public let differenceKmPerLitre: Double?
    public let comparisonSummary: String?
    public let note: String?
}

public struct SavingsSummaryDto: Codable, Equatable {
    public let currentMonthFuelSpend: Double?
    public let previousMonthFuelSpend: Double?
    public let fuelSpendSavings: Double?
    public let fuelSpendSavingsMessage: String?
    public let hasMoMComparison: Bool?
    public let currentMonthLitres: Double?
    public let currentMonthDistanceKm: Double?
    public let currentMonthMileageKmPerLitre: Double?
    public let previousMonthMileageKmPerLitre: Double?
    public let mileageTrendKmPerLitre: Double?
    public let mileageTrendText: String?
    public let totalMaintenanceSpend: Double?
    public let currentYearMaintenanceSpend: Double?
    public let maintenanceRecordsCount: Int?
    public let streaks: [StreakBadgeDto]
    public let fuelPriceRadar: FuelPriceRadarDto?
    public let communityBenchmark: CommunityBenchmarkDto?
}
