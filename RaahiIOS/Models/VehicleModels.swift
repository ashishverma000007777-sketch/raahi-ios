import Foundation

public struct VehicleDto: Codable, Identifiable, Equatable {
    public let id: String
    public let brand: String
    public let model: String
    public let variant: String?
    public let modelYear: Int
    public let fuelType: String
    public let registrationNumber: String
    public let odometerKm: Int
    public let odometerUpdatedAt: String?
    public let lastServiceDate: String?
    public let lastServiceOdometerKm: Int?
    public let insuranceExpiry: String?
    public let pucExpiry: String?
    public let tyreReplacedDate: String?
    public let tyreReplacedOdometerKm: Int?
    public let batteryReplacedDate: String?
    public let batteryReplacedOdometerKm: Int?
    public let createdAt: String?
    public let updatedAt: String?
    
    public init(
        id: String,
        brand: String,
        model: String,
        variant: String? = nil,
        modelYear: Int,
        fuelType: String,
        registrationNumber: String,
        odometerKm: Int,
        odometerUpdatedAt: String? = nil,
        lastServiceDate: String? = nil,
        lastServiceOdometerKm: Int? = nil,
        insuranceExpiry: String? = nil,
        pucExpiry: String? = nil,
        tyreReplacedDate: String? = nil,
        tyreReplacedOdometerKm: Int? = nil,
        batteryReplacedDate: String? = nil,
        batteryReplacedOdometerKm: Int? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.brand = brand
        self.model = model
        self.variant = variant
        self.modelYear = modelYear
        self.fuelType = fuelType
        self.registrationNumber = registrationNumber
        self.odometerKm = odometerKm
        self.odometerUpdatedAt = odometerUpdatedAt
        self.lastServiceDate = lastServiceDate
        self.lastServiceOdometerKm = lastServiceOdometerKm
        self.insuranceExpiry = insuranceExpiry
        self.pucExpiry = pucExpiry
        self.tyreReplacedDate = tyreReplacedDate
        self.tyreReplacedOdometerKm = tyreReplacedOdometerKm
        self.batteryReplacedDate = batteryReplacedDate
        self.batteryReplacedOdometerKm = batteryReplacedOdometerKm
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct UpsertVehicleRequest: Codable {
    public let brand: String
    public let model: String
    public let variant: String?
    public let modelYear: Int
    public let fuelType: String
    public let registrationNumber: String
    public let odometerKm: Int
    public let lastServiceDate: String?
    public let lastServiceOdometerKm: Int?
    public let insuranceExpiry: String?
    public let pucExpiry: String?
    public let tyreReplacedDate: String?
    public let tyreReplacedOdometerKm: Int?
    public let batteryReplacedDate: String?
    public let batteryReplacedOdometerKm: Int?
    
    public init(
        brand: String,
        model: String,
        variant: String? = nil,
        modelYear: Int,
        fuelType: String,
        registrationNumber: String,
        odometerKm: Int,
        lastServiceDate: String? = nil,
        lastServiceOdometerKm: Int? = nil,
        insuranceExpiry: String? = nil,
        pucExpiry: String? = nil,
        tyreReplacedDate: String? = nil,
        tyreReplacedOdometerKm: Int? = nil,
        batteryReplacedDate: String? = nil,
        batteryReplacedOdometerKm: Int? = nil
    ) {
        self.brand = brand
        self.model = model
        self.variant = variant
        self.modelYear = modelYear
        self.fuelType = fuelType
        self.registrationNumber = registrationNumber
        self.odometerKm = odometerKm
        self.lastServiceDate = lastServiceDate
        self.lastServiceOdometerKm = lastServiceOdometerKm
        self.insuranceExpiry = insuranceExpiry
        self.pucExpiry = pucExpiry
        self.tyreReplacedDate = tyreReplacedDate
        self.tyreReplacedOdometerKm = tyreReplacedOdometerKm
        self.batteryReplacedDate = batteryReplacedDate
        self.batteryReplacedOdometerKm = batteryReplacedOdometerKm
    }
}

public struct UpdateOdometerRequest: Codable {
    public let odometerKm: Int
    
    public init(odometerKm: Int) {
        self.odometerKm = odometerKm
    }
}

public struct MaintenanceItemDto: Codable, Identifiable, Equatable {
    public var id: String { "\(type)-\(dueAtKm ?? 0)" }
    public let type: String
    public let status: String // OK, DUE_SOON, OVERDUE, UNKNOWN
    public let detail: String
    public let dueAtKm: Int?
    public let dueAtDate: String?
}

public struct CarHealthDto: Codable, Equatable {
    public let score: Int?
    public let message: String?
    public let factorsConsidered: Int
    public let factorsTotal: Int
    public let maintenanceItems: [MaintenanceItemDto]
    public let grade: String?
    public let careScore: Int?
    public let efficiencyScore: Int?
    public let safetyScore: Int?
    
    public init(
        score: Int? = nil,
        message: String? = nil,
        factorsConsidered: Int = 0,
        factorsTotal: Int = 3,
        maintenanceItems: [MaintenanceItemDto] = [],
        grade: String? = nil,
        careScore: Int? = nil,
        efficiencyScore: Int? = nil,
        safetyScore: Int? = nil
    ) {
        self.score = score
        self.message = message
        self.factorsConsidered = factorsConsidered
        self.factorsTotal = factorsTotal
        self.maintenanceItems = maintenanceItems
        self.grade = grade
        self.careScore = careScore
        self.efficiencyScore = efficiencyScore
        self.safetyScore = safetyScore
    }
}

public struct ServiceRecordDto: Codable, Identifiable, Equatable {
    public let id: String
    public let serviceDate: String
    public let odometerKm: Int
    public let serviceType: String
    public let notes: String?
    public let cost: Double?
    public let workshopName: String?
    public let partsReplaced: String?
    public let createdAt: String?
}

public struct CreateServiceRecordRequest: Codable {
    public let serviceDate: String
    public let odometerKm: Int
    public let serviceType: String
    public let notes: String?
    public let cost: Double?
    public let workshopName: String?
    public let partsReplaced: String?
    
    public init(
        serviceDate: String,
        odometerKm: Int,
        serviceType: String,
        notes: String? = nil,
        cost: Double? = nil,
        workshopName: String? = nil,
        partsReplaced: String? = nil
    ) {
        self.serviceDate = serviceDate
        self.odometerKm = odometerKm
        self.serviceType = serviceType
        self.notes = notes
        self.cost = cost
        self.workshopName = workshopName
        self.partsReplaced = partsReplaced
    }
}

public struct FuelLogDto: Codable, Identifiable, Equatable {
    public let id: String
    public let filledAt: String
    public let litres: Double?
    public let pricePerLitre: Double?
    public let totalCost: Double
    public let odometerKm: Int?
    public let fuelType: String?
}

public struct CreateFuelLogRequest: Codable {
    public let totalCost: Double?
    public let litres: Double?
    public let pricePerLitre: Double?
    public let odometerKm: Int?
    public let fuelType: String?
    public let filledAt: String?
    
    public init(
        totalCost: Double? = nil,
        litres: Double? = nil,
        pricePerLitre: Double? = nil,
        odometerKm: Int? = nil,
        fuelType: String? = nil,
        filledAt: String? = nil
    ) {
        self.totalCost = totalCost
        self.litres = litres
        self.pricePerLitre = pricePerLitre
        self.odometerKm = odometerKm
        self.fuelType = fuelType
        self.filledAt = filledAt
    }
}

public struct FuelSummaryDto: Codable, Equatable {
    public let periodDays: Int
    public let fillUps: Int
    public let totalSpent: Double
    public let totalLitres: Double?
    public let lastFilledAt: String?
    public let hasAnyLogs: Bool
}
