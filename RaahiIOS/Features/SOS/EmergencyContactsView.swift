import SwiftUI

public struct EmergencyContactsView: View {
    @StateObject private var viewModel = EmergencyContactsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.raahiTextSecondary)
                    }
                    Spacer()
                    Text("Emergency Contacts")
                        .font(RaahiTypography.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { viewModel.showAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.raahiOrange)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Broadcast SMS CTA
                if !viewModel.contacts.isEmpty {
                    GlassCard(cornerRadius: 16, padding: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "message.fill")
                                    .foregroundColor(Color.raahiGreen)
                                Text("One-Tap Emergency SMS")
                                    .font(RaahiTypography.bodyBold)
                                    .foregroundColor(.white)
                            }
                            
                            Text("Open your device Messages app with your current GPS coordinates pre-filled to all saved contacts.")
                                .font(RaahiTypography.caption)
                                .foregroundColor(Color.raahiTextSecondary)
                            
                            RaahiButton(
                                title: "Send Emergency SMS",
                                icon: "paperplane.fill",
                                style: .success
                            ) {
                                viewModel.alertAllContactsViaSMS()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Contacts List
                if viewModel.contacts.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "person.crop.circle.badge.plus",
                        title: "No Emergency Contacts",
                        message: "Add family members or trusted friends so you can alert them with one tap during a breakdown.",
                        actionTitle: "Add Contact"
                    ) {
                        viewModel.showAddSheet = true
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.contacts) { contact in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.raahiCardSecondary)
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "person.fill")
                                        .foregroundColor(Color.raahiOrange)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(contact.name)
                                        .font(RaahiTypography.bodyBold)
                                        .foregroundColor(.white)
                                    Text("\(contact.relationship) • \(contact.phoneNumber)")
                                        .font(RaahiTypography.caption)
                                        .foregroundColor(Color.raahiTextSecondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    if let url = URL(string: "tel://\(contact.phoneNumber)") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(Color.raahiGreen)
                                        .padding(8)
                                        .background(Color.raahiGreen.opacity(0.12))
                                        .clipShape(Circle())
                                }
                            }
                            .listRowBackground(Color.raahiCard)
                            .listRowSeparatorTint(Color.raahiBorder)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteContact(id: viewModel.contacts[index].id)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddContactSheetView(viewModel: viewModel)
        }
    }
}

private struct AddContactSheetView: View {
    @ObservedObject var viewModel: EmergencyContactsViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let relationships = ["Family", "Friend", "Spouse", "Colleague", "Other"]
    
    var body: some View {
        ZStack {
            Color.raahiSurface.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Add Emergency Contact")
                    .font(RaahiTypography.title)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                VStack(spacing: 14) {
                    RaahiTextField(
                        placeholder: "Full Name",
                        icon: "person.fill",
                        text: $viewModel.newName
                    )
                    
                    RaahiTextField(
                        placeholder: "10-digit Phone Number",
                        icon: "phone.fill",
                        text: $viewModel.newPhone,
                        keyboardType: .phonePad
                    )
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Relationship")
                            .font(RaahiTypography.captionBold)
                            .foregroundColor(Color.raahiTextSecondary)
                        
                        Picker("Relationship", selection: $viewModel.newRelationship) {
                            ForEach(relationships, id: \.self) { r in
                                Text(r).tag(r)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(.horizontal, 20)
                
                if let error = viewModel.errorMessage {
                    ErrorBannerView(message: error)
                        .padding(.horizontal, 20)
                }
                
                RaahiButton(
                    title: "Save Contact",
                    icon: "checkmark",
                    style: .primary
                ) {
                    viewModel.addContact()
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}
