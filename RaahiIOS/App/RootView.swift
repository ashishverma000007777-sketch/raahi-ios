import SwiftUI

public struct RootView: View {
    @ObservedObject public var authManager: AuthManager
    @StateObject private var appState = AppState.shared
    @StateObject private var authViewModel = AuthViewModel()
    
    public init(authManager: AuthManager = AuthManager.shared) {
        self.authManager = authManager
    }
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            switch authManager.state {
            case .loading:
                SplashScreenView()
                
            case .unauthenticated:
                if authViewModel.isOtpSent {
                    OtpVerificationView(viewModel: authViewModel)
                } else {
                    PhoneLoginView(viewModel: authViewModel)
                }
                
            case .profileIncomplete(let user):
                ProfileSetupView(existingUser: user) {
                    Task { await authManager.checkCurrentSession() }
                }
                
            case .authenticated(_):
                MainTabBarView(appState: appState)
            }
        }
        .task {
            await authManager.checkCurrentSession()
        }
    }
}

// MARK: - Main Tab Bar View
private struct MainTabBarView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab View Content
            TabView(selection: $appState.selectedTab) {
                HomeView(
                    onRequestHelp: { appState.showRequestHelp = true },
                    onFindMechanic: { appState.selectedTab = .mechanics },
                    onMyJobs: { appState.showMyJobs = true },
                    onSOS: { appState.showSOS = true },
                    onAIMechanic: { appState.selectedTab = .aiMechanic },
                    onHelperPortal: { appState.showHelperPortal = true },
                    onNotifications: { appState.showNotifications = true },
                    onProfile: { appState.selectedTab = .profile },
                    onVehicleSetup: { appState.showVehicleSetup = true },
                    onTrackJob: { job in appState.selectedJobForTracking = job }
                )
                .tag(AppTab.home)
                
                MechanicsMapView(
                    onRequestHelp: { appState.showRequestHelp = true }
                )
                .tag(AppTab.mechanics)
                
                AIMechanicView()
                    .tag(AppTab.aiMechanic)
                
                WalletView()
                    .tag(AppTab.wallet)
                
                ProfileView()
                    .tag(AppTab.profile)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // Custom Floating Bottom Nav Bar
            FloatingBottomBar(selectedTab: $appState.selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
        }
        .sheet(isPresented: $appState.showRequestHelp) {
            RequestHelpView { createdJob in
                appState.selectedJobForTracking = createdJob
            }
        }
        .sheet(isPresented: $appState.showSOS) {
            SOSView()
        }
        .sheet(isPresented: $appState.showMyJobs) {
            MyJobsView { selectedJob in
                appState.selectedJobForTracking = selectedJob
            }
        }
        .sheet(isPresented: $appState.showHelperPortal) {
            HelperDashboardView { job in
                appState.selectedJobForTracking = job
            }
        }
        .sheet(isPresented: $appState.showNotifications) {
            NotificationsView()
        }
        .sheet(isPresented: $appState.showVehicleSetup) {
            VehicleSetupView()
        }
        .fullScreenCover(item: $appState.selectedJobForTracking) { job in
            JobDetailStatusView(job: job)
        }
    }
}

// MARK: - Floating Bottom Bar
private struct FloatingBottomBar: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        HStack(spacing: 0) {
            // Tab 0: Home
            BarItem(tab: .home, selected: selectedTab == .home) {
                selectedTab = .home
            }
            
            // Tab 1: Mechanics
            BarItem(tab: .mechanics, selected: selectedTab == .mechanics) {
                selectedTab = .mechanics
            }
            
            // Center Raised AI Button
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    selectedTab = .aiMechanic
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.raahiAiGradient)
                        .frame(width: 54, height: 54)
                        .shadow(color: Color.raahiBlue.opacity(0.4), radius: 10, y: 4)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(y: -14)
            }
            .frame(maxWidth: .infinity)
            
            // Tab 3: Wallet/Savings
            BarItem(tab: .wallet, selected: selectedTab == .wallet) {
                selectedTab = .wallet
            }
            
            // Tab 4: Profile
            BarItem(tab: .profile, selected: selectedTab == .profile) {
                selectedTab = .profile
            }
        }
        .frame(height: 64)
        .background(Color.raahiCard.opacity(0.92))
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.raahiBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 16, y: 8)
    }
}

private struct BarItem: View {
    let tab: AppTab
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                    .foregroundColor(selected ? Color.raahiOrange : Color.raahiTextMuted)
                    .scaleEffect(selected ? 1.15 : 1.0)
                
                Text(tab.title)
                    .font(RaahiTypography.micro)
                    .foregroundColor(selected ? .white : Color.raahiTextMuted)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Splash Screen View
private struct SplashScreenView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.raahiBrandGradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.raahiOrange.opacity(0.4), radius: 16, y: 8)
                Image(systemName: "car.side.fill")
                    .font(.system(size: 38))
                    .foregroundColor(.white)
            }
            
            Text("Raahi")
                .font(RaahiTypography.largeTitle)
                .foregroundColor(.white)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.raahiOrange))
                .scaleEffect(1.1)
                .padding(.top, 12)
        }
    }
}
