import SwiftUI

public struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Notifications")
                        .font(RaahiTypography.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        Task { await viewModel.markAllRead() }
                    }) {
                        Text("Mark Read")
                            .font(RaahiTypography.captionBold)
                            .foregroundColor(Color.raahiOrange)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Notifications List
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    Spacer()
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.raahiOrange))
                    Spacer()
                } else if viewModel.notifications.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "bell.slash",
                        title: "No Notifications",
                        message: "Updates on your roadside jobs, safety alerts, and account status will appear here."
                    )
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.notifications) { notif in
                                GlassCard(cornerRadius: 14, padding: 14) {
                                    HStack(alignment: .top, spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(notif.read ? Color.raahiCardSecondary : Color.raahiOrange.opacity(0.2))
                                                .frame(width: 38, height: 38)
                                            Image(systemName: notif.read ? "bell.fill" : "bell.badge.fill")
                                                .foregroundColor(notif.read ? Color.raahiTextMuted : Color.raahiOrange)
                                                .font(.system(size: 16))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(notif.title)
                                                    .font(RaahiTypography.bodyBold)
                                                    .foregroundColor(.white)
                                                Spacer()
                                                if !notif.read {
                                                    Circle()
                                                        .fill(Color.raahiOrange)
                                                        .frame(width: 8, height: 8)
                                                }
                                            }
                                            
                                            Text(notif.body)
                                                .font(RaahiTypography.caption)
                                                .foregroundColor(Color.raahiTextSecondary)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .task {
            await viewModel.loadNotifications()
        }
    }
}
