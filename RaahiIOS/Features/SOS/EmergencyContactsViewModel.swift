import Foundation
import CoreLocation
import UIKit

@MainActor
public final class EmergencyContactsViewModel: ObservableObject {
    @Published public var contacts: [EmergencyContact] = []
    @Published public var newName: String = ""
    @Published public var newPhone: String = ""
    @Published public var newRelationship: String = "Family"
    @Published public var showAddSheet: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let localStore = LocalStore.shared
    private let locationManager = LocationManager.shared
    
    public init() {
        loadContacts()
    }
    
    public func loadContacts() {
        self.contacts = localStore.getEmergencyContacts()
    }
    
    public func addContact() {
        let trimmedName = newName.trimmingCharacters(in: .whitespaces)
        let trimmedPhone = newPhone.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedName.isEmpty, trimmedPhone.count >= 10 else {
            errorMessage = "Please enter a valid contact name and 10-digit phone number."
            return
        }
        
        let contact = EmergencyContact(name: trimmedName, phoneNumber: trimmedPhone, relationship: newRelationship)
        localStore.addEmergencyContact(contact)
        loadContacts()
        
        newName = ""
        newPhone = ""
        errorMessage = nil
        showAddSheet = false
    }
    
    public func deleteContact(id: UUID) {
        localStore.deleteEmergencyContact(id: id)
        loadContacts()
    }
    
    public func alertAllContactsViaSMS() {
        guard !contacts.isEmpty else { return }
        
        let loc = locationManager.currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777)
        let mapsLink = "https://maps.apple.com/?q=\(loc.latitude),\(loc.longitude)"
        let messageText = "EMERGENCY: I need urgent roadside help! My current GPS location: \(mapsLink)"
        
        let phoneNumbers = contacts.map { $0.phoneNumber }.joined(separator: ",")
        
        if let encoded = messageText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "sms:\(phoneNumbers)&body=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }
}
