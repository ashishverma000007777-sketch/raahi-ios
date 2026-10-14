import Foundation

public final class LocalStore {
    public static let shared = LocalStore()
    private let userDefaults = UserDefaults.standard
    
    private let emergencyContactsKey = "raahi.emergency_contacts"
    private let helperModeKey = "raahi.helper_mode_enabled"
    private let activeVehicleIdKey = "raahi.active_vehicle_id"
    
    private init() {}
    
    // MARK: - Emergency Contacts
    public func getEmergencyContacts() -> [EmergencyContact] {
        guard let data = userDefaults.data(forKey: emergencyContactsKey) else {
            return []
        }
        return (try? JSONDecoder().decode([EmergencyContact].self, from: data)) ?? []
    }
    
    public func saveEmergencyContacts(_ contacts: [EmergencyContact]) {
        if let data = try? JSONEncoder().encode(contacts) {
            userDefaults.set(data, forKey: emergencyContactsKey)
        }
    }
    
    public func addEmergencyContact(_ contact: EmergencyContact) {
        var existing = getEmergencyContacts()
        existing.append(contact)
        saveEmergencyContacts(existing)
    }
    
    public func deleteEmergencyContact(id: UUID) {
        var existing = getEmergencyContacts()
        existing.removeAll { $0.id == id }
        saveEmergencyContacts(existing)
    }
    
    // MARK: - Helper Mode
    public var isHelperModeEnabled: Bool {
        get { userDefaults.bool(forKey: helperModeKey) }
        set { userDefaults.set(newValue, forKey: helperModeKey) }
    }
    
    // MARK: - Active Vehicle ID
    public var activeVehicleId: String? {
        get { userDefaults.string(forKey: activeVehicleIdKey) }
        set { userDefaults.set(newValue, forKey: activeVehicleIdKey) }
    }
}
