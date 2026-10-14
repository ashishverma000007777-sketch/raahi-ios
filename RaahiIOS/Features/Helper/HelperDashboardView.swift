import SwiftUI

public struct HelperDashboardView: View {
    @StateObject private var viewModel = HelperDashboardViewModel()
    @Environment(\.dismiss) private var dismiss
    
    public var onOpenJob: ((JobDto) -> Void)?
    public var onOpenApplication: (() -> Void)?
    
    public init(onOpenJob: ((JobDto) -> Void)? = nil, onOpenApplication: (() -> Void)? = nil) {
        self.onOpenJob = onOpenJob
        self.onOpenApplication = onOpenApplication
    }
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text("Helper Portal")
                            .font(RaahiTypography.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            Task { await viewModel.loadDashboard() }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.raahiOrange)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Availability Switch Card
                    GlassCard(cornerRadius: 18, padding: 18) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(viewModel.isOnline ? Color.raahiGreen : Color.raahiTextMuted)
                                        .frame(width: 10, height: 10)
                                    Text(viewModel.isOnline ? "You are Online" : "You are Offline")
                                        .font(RaahiTypography.headline)
                                        .foregroundColor(.white)
                                }
                                Text(viewModel.isOnline ? "Receiving nearby roadside job alerts" : "Switch online to receive breakdown alerts")
                                    .font(RaahiTypography.caption)
                                    .foregroundColor(Color.raahiTextSecondary)
                            }
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { viewModel.isOnline },
                                set: { val in
                                    Task { await viewModel.toggleAvailability(to: val) }
                                }
                            ))
                            .labelsHidden()
                            .tint(Color.raahiGreen)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Helper Stats Cards
                    if let status = viewModel.helperStatus {
                        HStack(spacing: 12) {
                            GlassCard(cornerRadius: 14, padding: 14) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Helps Provided")
                                        .font(RaahiTypography.caption)
                                        .foregroundColor(Color.raahiTextSecondary)
                                    Text("\(status.totalHelps)")
                                        .font(RaahiTypography.title)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            GlassCard(cornerRadius: 14, padding: 14) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Rating")
                                        .font(RaahiTypography.caption)
                                        .foregroundColor(Color.raahiTextSecondary)
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(Color.raahiYellow)
                                            .font(.system(size: 14))
                                        Text(String(format: "%.1f", status.ratingAvg))
                                            .font(RaahiTypography.title)
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Commission & Earnings
                    if let earnings = viewModel.earnings, let commission = viewModel.commission {
                        GlassCard(cornerRadius: 16, padding: 16) {
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Gross Earnings")
                                            .font(RaahiTypography.caption)
                                            .foregroundColor(Color.raahiTextSecondary)
                                        Text("₹\(Int(earnings.grossEarnings))")
                                            .font(RaahiTypography.headline)
                                            .foregroundColor(Color.raahiGreen)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Platform Commission")
                                            .font(RaahiTypography.caption)
                                            .foregroundColor(Color.raahiTextSecondary)
                                        Text("₹\(Int(commission.due)) due")
                                            .font(RaahiTypography.headline)
                                            .foregroundColor(commission.due > 0 ? Color.raahiYellow : Color.raahiTextMuted)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Available Jobs Feed
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("NEARBY REQUESTS (\(viewModel.availableJobs.count))")
                                .font(RaahiTypography.captionBold)
                                .foregroundColor(Color.raahiOrange)
                            Spacer()
                            Button(action: {
                                Task { await viewModel.loadAvailableJobs() }
                            }) {
                                Text("Refresh")
                                    .font(RaahiTypography.captionBold)
                                    .foregroundColor(Color.raahiOrange)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        if viewModel.availableJobs.isEmpty {
                            GlassCard(cornerRadius: 14, padding: 18) {
                                HStack(spacing: 12) {
                                    Image(systemName: "clock")
                                        .foregroundColor(Color.raahiTextMuted)
                                        .font(.system(size: 20))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("No Pending Jobs Right Now")
                                            .font(RaahiTypography.bodyBold)
                                            .foregroundColor(.white)
                                        Text("New roadside help requests in your area will appear here.")
                                            .font(RaahiTypography.caption)
                                            .foregroundColor(Color.raahiTextSecondary)
                                    }
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 20)
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(viewModel.availableJobs) { job in
                                    PendingJobCard(job: job) {
                                        Task {
                                            if let accepted = await viewModel.acceptJob(id: job.id) {
                                                onOpenJob?(accepted)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Onboarding link if applicable
                    if viewModel.helperStatus?.applicationStatus != "APPROVED" {
                        GlassCard(cornerRadius: 14, padding: 14) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Helper Verification Status")
                                        .font(RaahiTypography.bodyBold)
                                        .foregroundColor(.white)
                                    Text("Application: \(viewModel.helperStatus?.applicationStatus ?? "NOT_APPLIED")")
                                        .font(RaahiTypography.caption)
                                        .foregroundColor(Color.raahiYellow)
                                }
                                Spacer()
                                Button(action: { onOpenApplication?() }) {
                                    Text("View Details")
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
                    }
                }
                .padding(.bottom, 36)
            }
        }
        .task {
            await viewModel.loadDashboard()
        }
        .fullScreenCover(item: $viewModel.incomingJobAlert) { job in
            IncomingJobAlertView(job: job) { accepted in
                viewModel.incomingJobAlert = nil
                if accepted {
                    Task {
                        if let acceptedJob = await viewModel.acceptJob(id: job.id) {
                            onOpenJob?(acceptedJob)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Subcomponents
private struct PendingJobCard: View {
    let job: JobDto
    let onAccept: () -> Void
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    let cat = ProblemTypes.category(for: job.problemType)
                    HStack(spacing: 6) {
                        Image(systemName: cat?.iconName ?? "wrench.fill")
                            .foregroundColor(Color.raahiOrange)
                        Text(cat?.title ?? job.problemType)
                            .font(RaahiTypography.bodyBold)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("₹\(Int(job.rewardAmount))")
                        .font(RaahiTypography.headline)
                        .foregroundColor(Color.raahiGreen)
                }
                
                if let desc = job.problemDesc, !desc.isEmpty {
                    Text(desc)
                        .font(RaahiTypography.caption)
                        .foregroundColor(Color.raahiTextSecondary)
                        .lineLimit(2)
                }
                
                HStack {
                    if let requester = job.requesterName {
                        Text("Requester: \(requester)")
                            .font(RaahiTypography.caption)
                            .foregroundColor(Color.raahiTextMuted)
                    }
                    Spacer()
                    Button(action: onAccept) {
                        Text("Accept Job")
                            .font(RaahiTypography.captionBold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.raahiGreen)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}
