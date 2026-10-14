import SwiftUI

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    public var onRequestHelp: (() -> Void)?
    public var onFindMechanic: (() -> Void)?
    public var onMyJobs: (() -> Void)?
    public var onSOS: (() -> Void)?
    public var onAIMechanic: (() -> Void)?
    public var onHelperPortal: (() -> Void)?
    public var onNotifications: (() -> Void)?
    public var onProfile: (() -> Void)?
    public var onVehicleSetup: (() -> Void)?
    public var onTrackJob: ((JobDto) -> Void)?
    
    public init(
        onRequestHelp: (() -> Void)? = nil,
        onFindMechanic: (() -> Void)? = nil,
        onMyJobs: (() -> Void)? = nil,
        onSOS: (() -> Void)? = nil,
        onAIMechanic: (() -> Void)? = nil,
        onHelperPortal: (() -> Void)? = nil,
        onNotifications: (() -> Void)? = nil,
        onProfile: (() -> Void)? = nil,
        onVehicleSetup: (() -> Void)? = nil,
        onTrackJob: ((JobDto) -> Void)? = nil
    ) {
        self.onRequestHelp = onRequestHelp
        self.onFindMechanic = onFindMechanic
        self.onMyJobs = onMyJobs
        self.onSOS = onSOS
        self.onAIMechanic = onAIMechanic
        self.onHelperPortal = onHelperPortal
        self.onNotifications = onNotifications
        self.onProfile = onProfile
        self.onVehicleSetup = onVehicleSetup
        self.onTrackJob = onTrackJob
    }
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header Bar
                    HomeHeaderView(
                        greeting: viewModel.greetingTimeText,
                        userName: viewModel.user?.name ?? "Driver",
                        unreadCount: viewModel.homeSummary?.unreadNotifications ?? 0,
                        onNotificationsTap: { onNotifications?() },
                        onProfileTap: { onProfile?() }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Live Highway Ticker
                    TickerView()
                        .padding(.horizontal, 20)
                    
                    // Active Job Banner (if any)
                    if let activeJob = viewModel.activeJob {
                        ActiveJobBanner(job: activeJob) {
                            onTrackJob?(activeJob)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Vehicle Card with Health Pill
                    if let vehicle = viewModel.vehicle {
                        VehicleDashboardCard(
                            vehicle: vehicle,
                            health: viewModel.carHealth,
                            onTap: { onProfile?() }
                        )
                        .padding(.horizontal, 20)
                    } else {
                        SetupCarBanner {
                            onVehicleSetup?()
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // AI Mechanic Hero Card
                    AIMechanicHeroCard(aiStatus: viewModel.aiStatus) {
                        onAIMechanic?()
                    }
                    .padding(.horizontal, 20)
                    
                    // Quick Actions Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HIGHWAY ASSISTANCE")
                            .font(RaahiTypography.captionBold)
                            .foregroundColor(Color.raahiOrange)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            QuickActionCard(
                                title: "Roadside Help",
                                subtitle: "Puncture, Towing, Jumpstart",
                                icon: "car.side.fill",
                                color: Color.raahiOrange
                            ) {
                                onRequestHelp?()
                            }
                            
                            QuickActionCard(
                                title: "Find Mechanic",
                                subtitle: "Nearby verified garages",
                                icon: "map.fill",
                                color: Color.raahiBlue
                            ) {
                                onFindMechanic?()
                            }
                            
                            QuickActionCard(
                                title: "My Jobs",
                                subtitle: "Active & past roadside tasks",
                                icon: "list.bullet.rectangle.portrait.fill",
                                color: Color.raahiGreen
                            ) {
                                onMyJobs?()
                            }
                            
                            QuickActionCard(
                                title: "Highway SOS",
                                subtitle: "Instant 24x7 emergency broadcast",
                                icon: "exclamationmark.triangle.fill",
                                color: Color.raahiRed
                            ) {
                                onSOS?()
                            }
                            
                            if viewModel.user?.role == "HELPER" || viewModel.user?.role == "MECHANIC" {
                                QuickActionCard(
                                    title: "Helper Portal",
                                    subtitle: "Manage jobs & earnings",
                                    icon: "wrench.and.screwdriver.fill",
                                    color: Color.raahiYellow
                                ) {
                                    onHelperPortal?()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Weekly Performance Stats Strip
                    if let summary = viewModel.homeSummary {
                        StatsPerformanceStrip(summary: summary)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 36)
            }
        }
        .task {
            await viewModel.loadHomeData()
        }
    }
}

// MARK: - Subcomponents
private struct HomeHeaderView: View {
    let greeting: String
    let userName: String
    let unreadCount: Int
    let onNotificationsTap: () -> Void
    let onProfileTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(RaahiTypography.caption)
                    .foregroundColor(Color.raahiTextSecondary)
                Text(userName)
                    .font(RaahiTypography.title)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // Notifications Bell
                Button(action: onNotificationsTap) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.raahiCardSecondary)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.raahiBorder, lineWidth: 1))
                        
                        if unreadCount > 0 {
                            Circle()
                                .fill(Color.raahiOrange)
                                .frame(width: 10, height: 10)
                                .offset(x: 2, y: -2)
                        }
                    }
                }
                
                // Profile Avatar Button
                Button(action: onProfileTap) {
                    ZStack {
                        Circle()
                            .fill(Color.raahiBrandGradient)
                            .frame(width: 40, height: 40)
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                }
            }
        }
    }
}

private struct ActiveJobBanner: View {
    let job: JobDto
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            GlassCard(cornerRadius: 16, padding: 14) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.raahiOrange.opacity(0.2))
                            .frame(width: 42, height: 42)
                        Image(systemName: "car.side.fill")
                            .foregroundColor(Color.raahiOrange)
                            .font(.system(size: 18))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("Active Roadside Help")
                                .font(RaahiTypography.bodyBold)
                                .foregroundColor(.white)
                            StatusBadge(text: job.status, color: Color.raahiOrange)
                        }
                        Text("Tap to track live helper and handoff OTP")
                            .font(RaahiTypography.caption)
                            .foregroundColor(Color.raahiTextSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.raahiOrange)
                }
            }
        }
    }
}

private struct VehicleDashboardCard: View {
    let vehicle: VehicleDto
    let health: CarHealthDto?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            GlassCard(cornerRadius: 18, padding: 18) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(vehicle.brand) \(vehicle.model)")
                            .font(RaahiTypography.headline)
                            .foregroundColor(.white)
                        
                        Text("\(vehicle.registrationNumber) • \(vehicle.fuelType)")
                            .font(RaahiTypography.caption)
                            .foregroundColor(Color.raahiTextSecondary)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "speedometer")
                                .foregroundColor(Color.raahiOrange)
                                .font(.system(size: 12))
                            Text("\(vehicle.odometerKm) km")
                                .font(RaahiTypography.captionBold)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 2)
                    }
                    
                    Spacer()
                    
                    // Small score ring pill
                    ScoreRing(score: health?.score, size: 68)
                }
            }
        }
    }
}

private struct SetupCarBanner: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            GlassCard(cornerRadius: 16, padding: 16) {
                HStack(spacing: 14) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color.raahiOrange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Set Up Your Car")
                            .font(RaahiTypography.bodyBold)
                            .foregroundColor(.white)
                        Text("Monitor health score, odometer, and insurance renewals.")
                            .font(RaahiTypography.caption)
                            .foregroundColor(Color.raahiTextSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.raahiTextMuted)
                }
            }
        }
    }
}

private struct AIMechanicHeroCard: View {
    let aiStatus: AiStatusDto?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.raahiCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.raahiBlue.opacity(0.6), Color.raahiPurple.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.raahiAiGradient)
                            .frame(width: 52, height: 52)
                        Image(systemName: "sparkles")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("AI Mechanic 24x7")
                                .font(RaahiTypography.headline)
                                .foregroundColor(.white)
                            
                            StatusBadge(
                                text: (aiStatus?.available ?? true) ? "ONLINE" : "BUSY",
                                color: (aiStatus?.available ?? true) ? Color.raahiGreen : Color.raahiYellow
                            )
                        }
                        
                        Text("Describe strange sounds or warning lights for rapid AI troubleshooting.")
                            .font(RaahiTypography.caption)
                            .foregroundColor(Color.raahiTextSecondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color.raahiBlue)
                }
                .padding(18)
            }
        }
    }
}

private struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            GlassCard(cornerRadius: 16, padding: 14) {
                VStack(alignment: .leading, spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.18))
                            .frame(width: 42, height: 42)
                        Image(systemName: icon)
                            .foregroundColor(color)
                            .font(.system(size: 18))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(RaahiTypography.bodyBold)
                            .foregroundColor(.white)
                        Text(subtitle)
                            .font(RaahiTypography.micro)
                            .foregroundColor(Color.raahiTextSecondary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private struct StatsPerformanceStrip: View {
    let summary: HomeSummaryDto
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 14) {
            HStack {
                VStack(spacing: 2) {
                    Text(summary.weeklyKm?.km != nil ? "\(summary.weeklyKm!.km!) km" : "—")
                        .font(RaahiTypography.headline)
                        .foregroundColor(.white)
                    Text("Driven this week")
                        .font(RaahiTypography.micro)
                        .foregroundColor(Color.raahiTextSecondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider().background(Color.raahiBorder)
                
                VStack(spacing: 2) {
                    Text("\(summary.helpsGivenThisWeek)")
                        .font(RaahiTypography.headline)
                        .foregroundColor(Color.raahiGreen)
                    Text("Helps provided")
                        .font(RaahiTypography.micro)
                        .foregroundColor(Color.raahiTextSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
