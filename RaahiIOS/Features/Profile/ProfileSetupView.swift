import SwiftUI

public struct ProfileSetupView: View {
    @State private var name: String = ""
    @State private var vehicleType: String = "Car"
    @State private var vehicleReg: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    public let isEditing: Bool
    public let existingUser: UserDto?
    public var onComplete: (() -> Void)?
    
    public init(isEditing: Bool = false, existingUser: UserDto? = nil, onComplete: (() -> Void)? = nil) {
        self.isEditing = isEditing
        self.existingUser = existingUser
        self.onComplete = onComplete
        _name = State(initialValue: existingUser?.name ?? "")
        _vehicleType = State(initialValue: existingUser?.vehicleType ?? "Car")
        _vehicleReg = State(initialValue: existingUser?.vehicleReg ?? "")
    }
    
    private let vehicleTypes = ["Car", "SUV", "Bike", "Truck"]
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(isEditing ? "Edit Profile" : "Set Up Your Profile")
                            .font(RaahiTypography.title)
                            .foregroundColor(.white)
                        
                        Text("Tell us your name and vehicle to help roadside helpers identify you.")
                            .font(RaahiTypography.body)
                            .foregroundColor(Color.raahiTextSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 24)
                    
                    // Form Card
                    GlassCard(cornerRadius: 20, padding: 20) {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Full Name")
                                    .font(RaahiTypography.subheadline)
                                    .foregroundColor(Color.raahiTextSecondary)
                                
                                RaahiTextField(
                                    placeholder: "e.g. Rahul Sharma",
                                    icon: "person.fill",
                                    text: $name
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Primary Vehicle Type")
                                    .font(RaahiTypography.subheadline)
                                    .foregroundColor(Color.raahiTextSecondary)
                                
                                HStack(spacing: 10) {
                                    ForEach(vehicleTypes, id: \.self) { type in
                                        Button(action: {
                                            vehicleType = type
                                        }) {
                                            Text(type)
                                                .font(RaahiTypography.bodyBold)
                                                .foregroundColor(vehicleType == type ? .white : Color.raahiTextSecondary)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 44)
                                                .background(vehicleType == type ? Color.raahiOrange : Color.raahiSurface)
                                                .cornerRadius(10)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(vehicleType == type ? Color.raahiOrange : Color.raahiBorder, lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Vehicle Registration (Optional)")
                                    .font(RaahiTypography.subheadline)
                                    .foregroundColor(Color.raahiTextSecondary)
                                
                                RaahiTextField(
                                    placeholder: "e.g. DL 03 AX 1234",
                                    icon: "car.fill",
                                    text: $vehicleReg
                                )
                            }
                            
                            if let error = errorMessage {
                                ErrorBannerView(message: error)
                            }
                            
                            RaahiButton(
                                title: isEditing ? "Save Changes" : "Complete Profile",
                                icon: "checkmark",
                                style: .primary,
                                isLoading: isLoading
                            ) {
                                saveProfile()
                            }
                            
                            if !isEditing {
                                Button(action: {
                                    // Skip to home
                                    onComplete?()
                                }) {
                                    Text("Skip for now")
                                        .font(RaahiTypography.bodyBold)
                                        .foregroundColor(Color.raahiTextMuted)
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.top, 4)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }
    
    private func saveProfile() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your name."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await AuthManager.shared.updateProfile(
                    name: name.trimmingCharacters(in: .whitespaces),
                    vehicleType: vehicleType,
                    vehicleReg: vehicleReg.trimmingCharacters(in: .whitespaces).uppercased()
                )
                isLoading = false
                onComplete?()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
