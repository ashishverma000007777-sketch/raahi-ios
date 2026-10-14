import SwiftUI

public struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab: Int = 0 // 0: Car Health, 1: Profile
    @State private var showEditProfile = false
    @State private var showVehicleSetup = false
    @State private var showServiceHistory = false
    @State private var showLogoutConfirmation = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Top User Header
                    if let user = viewModel.user {
                        GlassCard(cornerRadius: 20, padding: 20) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.raahiBrandGradient)
                                        .frame(width: 60, height: 60)
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Text(user.name ?? "Raahi Driver")
                                            .font(RaahiTypography.title)
                                            .foregroundColor(.white)
                                        if user.isVerified {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundColor(Color.raahiBlue)
                                                .font(.system(size: 16))
                                        }
                                    }
                                    
                                    if let phone = user.phone {
                                        Text(phone)
                                            .font(RaahiTypography.caption)
                                            .foregroundColor(Color.raahiTextSecondary)
                                    }
                                    
                                    HStack(spacing: 8) {
                                        StatusBadge(text: user.role, color: Color.raahiOrange)
                                        if user.totalHelps > 0 {
                                            Text("• \(user.totalHelps) helps")
                                                .font(RaahiTypography.caption)
                                                .foregroundColor(Color.raahiTextSecondary)
                                        }
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                    
                    // Sliding Tab Selector (Car Health / Profile)
                    HStack(spacing: 12) {
                        TabSelectionButton(title: "Car Health", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        TabSelectionButton(title: "Profile & Account", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Tab Content
                    if selectedTab == 0 {
                        CarHealthView(
                            viewModel: viewModel,
                            onEditVehicle: { showVehicleSetup = true },
                            onOpenServiceHistory: { showServiceHistory = true }
                        )
                        .padding(.horizontal, 20)
                    } else {
                        ProfileAccountDetailsView(
                            user: viewModel.user,
                            onEditProfile: { showEditProfile = true },
                            onLogout: { showLogoutConfirmation = true }
                        )
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 36)
            }
        }
        .task {
            await viewModel.loadProfileData()
        }
        .sheet(isPresented: $showEditProfile) {
            ProfileSetupView(isEditing: true, existingUser: viewModel.user) {
                showEditProfile = false
                Task { await viewModel.loadProfileData() }
            }
        }
        .sheet(isPresented: $showVehicleSetup) {
            VehicleSetupView(existingVehicle: viewModel.vehicle) { _ in
                showVehicleSetup = false
                Task { await viewModel.loadProfileData() }
            }
        }
        .sheet(isPresented: $showServiceHistory) {
            ServiceHistoryView(viewModel: viewModel)
        }
        .confirmationDialog("Log Out", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
            Button("Log Out", role: .destructive) {
                Task { await viewModel.logout() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to log out of Raahi?")
        }
    }
}

private struct TabSelectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(RaahiTypography.bodyBold)
                .foregroundColor(isSelected ? .white : Color.raahiTextSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? Color.raahiCardSecondary : Color.raahiSurface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.raahiOrange.opacity(0.8) : Color.raahiBorder, lineWidth: 1)
                )
        }
    }
}

private struct ProfileAccountDetailsView: View {
    let user: UserDto?
    let onEditProfile: () -> Void
    let onLogout: () -> Void
    
    var body: some View {
        VStack(spacing: 18) {
            GlassCard(cornerRadius: 16, padding: 16) {
                VStack(spacing: 14) {
                    HStack {
                        Text("ACCOUNT INFORMATION")
                            .font(RaahiTypography.captionBold)
                            .foregroundColor(Color.raahiTextMuted)
                        Spacer()
                        Button(action: onEditProfile) {
                            Text("Edit")
                                .font(RaahiTypography.captionBold)
                                .foregroundColor(Color.raahiOrange)
                        }
                    }
                    
                    ProfileDetailRow(label: "Full Name", value: user?.name ?? "—")
                    ProfileDetailRow(label: "Phone", value: user?.phone ?? "—")
                    ProfileDetailRow(label: "Email", value: user?.email ?? "Not configured")
                    ProfileDetailRow(label: "Account Role", value: user?.role ?? "DRIVER")
                }
            }
            
            // Logout Card
            Button(action: onLogout) {
                HStack(spacing: 10) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .bold))
                    Text("Log Out of Raahi")
                        .font(RaahiTypography.bodyBold)
                }
                .foregroundColor(Color.raahiRed)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.raahiCard)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.raahiRed.opacity(0.3), lineWidth: 1)
                )
            }
            
            Text("Raahi iOS v1.0.0 (Build 20261014)\nProduction Backend: raahi-fdw0.onrender.com")
                .font(RaahiTypography.caption)
                .foregroundColor(Color.raahiTextMuted)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
    }
}

private struct ProfileDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(RaahiTypography.body)
                .foregroundColor(Color.raahiTextSecondary)
            Spacer()
            Text(value)
                .font(RaahiTypography.bodyBold)
                .foregroundColor(.white)
        }
    }
}
