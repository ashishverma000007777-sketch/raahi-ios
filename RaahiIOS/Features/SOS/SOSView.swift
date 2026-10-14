import SwiftUI

public struct SOSView: View {
    @StateObject private var viewModel = SOSViewModel()
    @State private var showContacts = false
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text("Emergency Highway SOS")
                            .font(RaahiTypography.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: { showContacts = true }) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color.raahiOrange)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Active SOS State
                    if let sos = viewModel.activeSos {
                        GlassCard(cornerRadius: 18, padding: 20) {
                            VStack(spacing: 16) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.raahiRed)
                                        .frame(width: 14, height: 14)
                                    Text("EMERGENCY BROADCAST ACTIVE")
                                        .font(RaahiTypography.headline)
                                        .foregroundColor(Color.raahiRed)
                                    Spacer()
                                }
                                
                                Text("Nearby helpers and mechanics within 15 km have been alerted with your coordinates.")
                                    .font(RaahiTypography.body)
                                    .foregroundColor(Color.raahiTextSecondary)
                                
                                if viewModel.notifiedMechanicsCount > 0 {
                                    HStack {
                                        Text("Mechanics Notified:")
                                            .font(RaahiTypography.caption)
                                            .foregroundColor(Color.raahiTextMuted)
                                        Text("\(viewModel.notifiedMechanicsCount)")
                                            .font(RaahiTypography.bodyBold)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                }
                                
                                RaahiButton(
                                    title: "Mark Incident Resolved",
                                    icon: "checkmark.circle.fill",
                                    style: .success,
                                    isLoading: viewModel.isResolving
                                ) {
                                    Task { await viewModel.resolveSos() }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    } else {
                        // Big Emergency Trigger Card
                        VStack(spacing: 20) {
                            Text("Press & Hold to Trigger SOS")
                                .font(RaahiTypography.title)
                                .foregroundColor(.white)
                            
                            Text("This will immediately broadcast your GPS location to verified mechanics and helpers within 15 km.")
                                .font(RaahiTypography.body)
                                .foregroundColor(Color.raahiTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            // Giant SOS Button
                            Button(action: {
                                viewModel.showTriggerConfirmation = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.raahiRed.opacity(0.18))
                                        .frame(width: 190, height: 190)
                                    
                                    Circle()
                                        .fill(Color.raahiRed)
                                        .frame(width: 140, height: 140)
                                        .shadow(color: Color.raahiRed.opacity(0.6), radius: 20, y: 10)
                                    
                                    VStack(spacing: 4) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 38))
                                            .foregroundColor(.white)
                                        Text("SOS")
                                            .font(.system(size: 28, weight: .black, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.vertical, 12)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Emergency Contacts Shortcut Card
                    GlassCard(cornerRadius: 16, padding: 16) {
                        HStack(spacing: 14) {
                            Image(systemName: "person.crop.circle.badge.exclamationmark")
                                .font(.system(size: 28))
                                .foregroundColor(Color.raahiOrange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Emergency Contacts")
                                    .font(RaahiTypography.bodyBold)
                                    .foregroundColor(.white)
                                Text("Notify family or friends via instant SMS")
                                    .font(RaahiTypography.caption)
                                    .foregroundColor(Color.raahiTextSecondary)
                            }
                            
                            Spacer()
                            
                            Button(action: { showContacts = true }) {
                                Text("Manage")
                                    .font(RaahiTypography.captionBold)
                                    .foregroundColor(Color.raahiOrange)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.raahiOrange.opacity(0.15))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Safety Advice
                    VStack(alignment: .leading, spacing: 10) {
                        Text("HIGHWAY BREAKDOWN SAFETY")
                            .font(RaahiTypography.captionBold)
                            .foregroundColor(Color.raahiTextMuted)
                        
                        SafetyTipRow(icon: "lightbulb.fill", text: "Turn on hazard hazard lights immediately")
                        SafetyTipRow(icon: "triangle.fill", text: "Place safety triangle 50m behind your vehicle")
                        SafetyTipRow(icon: "figure.walk", text: "Stand safely behind the highway crash barrier")
                    }
                    .padding(.horizontal, 20)
                    
                    if let error = viewModel.errorMessage {
                        ErrorBannerView(message: error)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 36)
            }
        }
        .task {
            await viewModel.checkActiveSos()
        }
        .confirmationDialog(
            "Confirm Emergency SOS Trigger",
            isPresented: $viewModel.showTriggerConfirmation,
            titleVisibility: .visible
        ) {
            Button("Broadcast Emergency SOS", role: .destructive) {
                Task { await viewModel.triggerSos() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you in immediate need of assistance? This will notify nearby mechanics and responders.")
        }
        .sheet(isPresented: $showContacts) {
            EmergencyContactsView()
        }
    }
}

private struct SafetyTipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(Color.raahiOrange)
                .frame(width: 20)
            Text(text)
                .font(RaahiTypography.caption)
                .foregroundColor(Color.raahiTextSecondary)
            Spacer()
        }
    }
}
