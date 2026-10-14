import Foundation
import SwiftUI

public struct ProblemCategory: Identifiable, Equatable {
    public var id: String { code }
    public let code: String
    public let title: String
    public let subtitle: String
    public let iconName: String
    public let suggestedAmount: Double
    
    public init(code: String, title: String, subtitle: String, iconName: String, suggestedAmount: Double) {
        self.code = code
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.suggestedAmount = suggestedAmount
    }
}

public struct ProblemTypes {
    public static let all: [ProblemCategory] = [
        ProblemCategory(
            code: "FLAT_TYRE",
            title: "Flat Tyre",
            subtitle: "Puncture repair or spare tyre swap",
            iconName: "circle.circle.fill",
            suggestedAmount: 300
        ),
        ProblemCategory(
            code: "BATTERY_DEAD",
            title: "Battery Jumpstart",
            subtitle: "Dead battery or slow crank",
            iconName: "bolt.car.fill",
            suggestedAmount: 350
        ),
        ProblemCategory(
            code: "OUT_OF_FUEL",
            title: "Fuel Delivery",
            subtitle: "Emergency 3-5 litres fuel delivery",
            iconName: "fuelpump.fill",
            suggestedAmount: 250
        ),
        ProblemCategory(
            code: "TOWING",
            title: "Towing Service",
            subtitle: "Flatbed or wheel-lift tow truck",
            iconName: "truck.pickup.side.fill",
            suggestedAmount: 1200
        ),
        ProblemCategory(
            code: "ENGINE_BREAKDOWN",
            title: "Breakdown",
            subtitle: "Strange noise, stalling, or smoke",
            iconName: "wrench.and.screwdriver.fill",
            suggestedAmount: 500
        ),
        ProblemCategory(
            code: "LOCKOUT",
            title: "Car Lockout",
            subtitle: "Keys locked inside the car",
            iconName: "key.fill",
            suggestedAmount: 400
        ),
        ProblemCategory(
            code: "OVERHEATING",
            title: "Overheating",
            subtitle: "Coolant leak or temperature warning",
            iconName: "thermometer.high",
            suggestedAmount: 400
        )
    ]
    
    public static func category(for code: String) -> ProblemCategory? {
        all.first { $0.code == code }
    }
}
