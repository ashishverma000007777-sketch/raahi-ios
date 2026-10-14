import Foundation
import SwiftUI

public enum AppTab: Int, CaseIterable, Identifiable {
    case home = 0
    case mechanics = 1
    case aiMechanic = 2
    case wallet = 3
    case profile = 4
    
    public var id: Int { rawValue }
    
    public var title: String {
        switch self {
        case .home: return "Home"
        case .mechanics: return "Mechanics"
        case .aiMechanic: return "AI Diagnose"
        case .wallet: return "Savings"
        case .profile: return "Profile"
        }
    }
    
    public var icon: String {
        switch self {
        case .home: return "house.fill"
        case .mechanics: return "map.fill"
        case .aiMechanic: return "sparkles"
        case .wallet: return "indianrupeesign.circle.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

@MainActor
public final class AppState: ObservableObject {
    public static let shared = AppState()
    
    @Published public var selectedTab: AppTab = .home
    
    // Global sheets & Modals
    @Published public var showRequestHelp: Bool = false
    @Published public var showSOS: Bool = false
    @Published public var showMyJobs: Bool = false
    @Published public var showHelperPortal: Bool = false
    @Published public var showNotifications: Bool = false
    @Published public var showVehicleSetup: Bool = false
    @Published public var selectedJobForTracking: JobDto? = nil
    
    public init() {}
}
