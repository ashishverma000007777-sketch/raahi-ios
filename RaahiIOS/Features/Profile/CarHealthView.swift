import SwiftUI

public struct CarHealthView: View {
    @ObservedObject public var viewModel: ProfileViewModel
    public var onEditVehicle: (() -> Void)?
    public var onOpenServiceHistory: (() -> Void)?
    
    public init(
        viewModel: ProfileViewModel,
        onEditVehicle: (() -> Void)? = nil,
        onOpenServiceHistory: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onEditVehicle = onEditVehicle
        self.onOpenServiceHistory = onOpenServiceHistory
    }
    
    public var body: some View {
        VStack(spacing: 18) {
            // Vehicle Summary Card
            if let v = viewModel.vehicle {
                GlassCard(cornerRadius: 18, padding: 18) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("\(v.brand) \(v.model)")
                                    .font(RaahiTypography.title)
                                    .foregroundColor(.white)
                                Text("\(v.registrationNumber) • \(v.fuelType)")
                                    .font(RaahiTypography.caption)
                                    .foregroundColor(Color.raahiTextSecondary)
                            }
                            Spacer()
                            Button(action: { onEditVehicle?() }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.raahiOrange)
                                    .padding(8)
                                    .background(Color.raahiOrange.opacity(0.12))
                                    .clipShape(Circle())
                            }
                        }
                        
                        Divider().background(Color.raahiBorder)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Odometer Reading")
                                    .font(RaahiTypography.caption)
                                    .foregroundColor(Color.raahiTextMuted)
                                Text("\(v.odometerKm) km")
                                    .font(RaahiTypography.headline)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Button(action: {
                                viewModel.newOdometerText = "\(v.odometerKm)"
                                viewModel.showOdometerSheet = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.circle.fill")
                                    Text("Update Km")
                                }
                                .font(RaahiTypography.captionBold)
                                .foregroundColor(Color.raahiOrange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.raahiOrange.opacity(0.12))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            } else {
                // Setup Car Prompt
                GlassCard(cornerRadius: 18, padding: 20) {
                    VStack(spacing: 12) {
                        Image(systemName: "car.badge.gearshape")
                            .font(.system(size: 38))
                            .foregroundColor(Color.raahiOrange)
                        Text("No Vehicle Configured")
                            .font(RaahiTypography.headline)
                            .foregroundColor(.white)
                        Text("Add your car to monitor its maintenance health, insurance expiry, and service history.")
                            .font(RaahiTypography.caption)
                            .foregroundColor(Color.raahiTextSecondary)
                            .multilineTextAlignment(.center)
                        RaahiButton(
                            title: "Set Up Your Car",
                            icon: "plus.circle.fill",
                            style: .primary
                        ) {
                            onEditVehicle?()
                        }
                        .padding(.top, 4)
                    }
                }
            }
            
            // Health Score Ring Card
            if let health = viewModel.carHealth {
                GlassCard(cornerRadius: 18, padding: 18) {
                    HStack(spacing: 20) {
                        ScoreRing(score: health.score, size: 90)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if let score = health.score {
                                Text("Score: \(score) / 100")
                                    .font(RaahiTypography.headline)
                                    .foregroundColor(.white)
                                Text("Based on \(health.factorsConsidered) of \(health.factorsTotal) verified maintenance factors")
                                    .font(RaahiTypography.caption)
                                    .foregroundColor(Color.raahiTextSecondary)
                            } else {
                                Text("Score Pending")
                                    .font(RaahiTypography.headline)
                                    .foregroundColor(.white)
                                Text(health.message ?? "Add service or insurance details to compute health score.")
                                    .font(RaahiTypography.caption)
                                    .foregroundColor(Color.raahiTextSecondary)
                            }
                        }
                        Spacer()
                    }
                }
                
                // Maintenance Checklist
                if !health.maintenanceItems.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("MAINTENANCE SCHEDULE")
                                .font(RaahiTypography.captionBold)
                                .foregroundColor(Color.raahiOrange)
                            Spacer()
                            Button(action: { onOpenServiceHistory?() }) {
                                Text("Service History")
                                    .font(RaahiTypography.captionBold)
                                    .foregroundColor(Color.raahiOrange)
                            }
                        }
                        
                        LazyVStack(spacing: 8) {
                            ForEach(health.maintenanceItems) { item in
                                MaintenanceItemRow(item: item)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showOdometerSheet) {
            OdometerUpdateSheet(viewModel: viewModel)
        }
    }
}

private struct MaintenanceItemRow: View {
    let item: MaintenanceItemDto
    
    var body: some View {
        GlassCard(cornerRadius: 12, padding: 12) {
            HStack(spacing: 12) {
                Image(systemName: iconForType(item.type))
                    .foregroundColor(colorForStatus(item.status))
                    .font(.system(size: 18))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.type.replacingOccurrences(of: "_", with: " "))
                        .font(RaahiTypography.bodyBold)
                        .foregroundColor(.white)
                    Text(item.detail)
                        .font(RaahiTypography.caption)
                        .foregroundColor(Color.raahiTextSecondary)
                }
                
                Spacer()
                
                StatusBadge(text: item.status, color: colorForStatus(item.status))
            }
        }
    }
    
    private func iconForType(_ t: String) -> String {
        switch t.uppercased() {
        case "OIL_CHANGE": return "drop.fill"
        case "TYRE_ROTATION": return "circle.circle.fill"
        case "BATTERY_CHECK": return "bolt.fill"
        case "INSURANCE_RENEWAL": return "shield.fill"
        case "PUC_RENEWAL": return "doc.text.fill"
        default: return "wrench.fill"
        }
    }
    
    private func colorForStatus(_ s: String) -> Color {
        switch s.uppercased() {
        case "OK": return Color.raahiGreen
        case "DUE_SOON": return Color.raahiYellow
        case "OVERDUE": return Color.raahiRed
        default: return Color.raahiTextMuted
        }
    }
}

private struct OdometerUpdateSheet: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.raahiSurface.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Update Odometer")
                    .font(RaahiTypography.title)
                    .foregroundColor(.white)
                    .padding(.top, 24)
                
                Text("Enter your current dashboard odometer reading in kilometers.")
                    .font(RaahiTypography.body)
                    .foregroundColor(Color.raahiTextSecondary)
                    .padding(.horizontal, 20)
                
                RaahiTextField(
                    placeholder: "e.g. 28500",
                    icon: "speedometer",
                    text: $viewModel.newOdometerText,
                    keyboardType: .numberPad
                )
                .padding(.horizontal, 20)
                
                if let error = viewModel.errorMessage {
                    ErrorBannerView(message: error)
                        .padding(.horizontal, 20)
                }
                
                RaahiButton(
                    title: "Save Odometer Reading",
                    icon: "checkmark",
                    style: .primary,
                    isLoading: viewModel.isUpdatingOdometer
                ) {
                    Task {
                        _ = await viewModel.updateOdometer()
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}
