import SwiftUI

public struct MyJobsView: View {
    @StateObject private var viewModel = MyJobsViewModel()
    @State private var selectedTab: Int = 0 // 0: Active, 1: History
    @Environment(\.dismiss) private var dismiss
    
    public var onSelectJob: ((JobDto) -> Void)?
    
    public init(onSelectJob: ((JobDto) -> Void)? = nil) {
        self.onSelectJob = onSelectJob
    }
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("My Roadside Jobs")
                        .font(RaahiTypography.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        Task { await viewModel.loadJobs() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.raahiOrange)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Tab Picker
                HStack(spacing: 8) {
                    TabButton(title: "Active Jobs (\(viewModel.activeJobs.count))", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    TabButton(title: "History (\(viewModel.pastJobs.count))", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
                
                // Content
                if viewModel.isLoading && viewModel.jobs.isEmpty {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.raahiOrange))
                        .scaleEffect(1.2)
                    Spacer()
                } else if let error = viewModel.errorMessage, viewModel.jobs.isEmpty {
                    Spacer()
                    ErrorBannerView(message: error) {
                        Task { await viewModel.loadJobs() }
                    }
                    .padding(20)
                    Spacer()
                } else {
                    let displayJobs = selectedTab == 0 ? viewModel.activeJobs : viewModel.pastJobs
                    
                    if displayJobs.isEmpty {
                        Spacer()
                        EmptyStateView(
                            icon: selectedTab == 0 ? "car.badge.gearshape" : "clock.arrow.circlepath",
                            title: selectedTab == 0 ? "No Active Jobs" : "No Past Jobs",
                            message: selectedTab == 0 ? "You do not have any roadside requests currently in progress." : "Your completed or cancelled jobs will appear here."
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(displayJobs) { job in
                                    JobCard(job: job) {
                                        onSelectJob?(job)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                        }
                        .refreshable {
                            await viewModel.loadJobs()
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadJobs()
        }
    }
}

// MARK: - Subcomponents
private struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(RaahiTypography.subheadline)
                .fontWeight(isSelected ? .bold : .medium)
                .foregroundColor(isSelected ? .white : Color.raahiTextSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(isSelected ? Color.raahiCardSecondary : Color.raahiSurface)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.raahiOrange.opacity(0.6) : Color.raahiBorder, lineWidth: 1)
                )
        }
    }
}

private struct JobCard: View {
    let job: JobDto
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            GlassCard(cornerRadius: 16, padding: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(spacing: 8) {
                            let category = ProblemTypes.category(for: job.problemType)
                            Image(systemName: category?.iconName ?? "wrench.fill")
                                .foregroundColor(Color.raahiOrange)
                                .font(.system(size: 16))
                            Text(category?.title ?? job.problemType)
                                .font(RaahiTypography.bodyBold)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        StatusBadge(text: job.status, color: statusColor(job.status))
                    }
                    
                    if let desc = job.problemDesc, !desc.isEmpty {
                        Text(desc)
                            .font(RaahiTypography.caption)
                            .foregroundColor(Color.raahiTextSecondary)
                            .lineLimit(2)
                    }
                    
                    Divider().background(Color.raahiBorder)
                    
                    HStack {
                        HStack(spacing: 6) {
                            Text(job.viewerRole == "HELPER" ? "Helping:" : "Assistance for:")
                                .font(RaahiTypography.caption)
                                .foregroundColor(Color.raahiTextMuted)
                            Text(job.viewerRole == "HELPER" ? (job.requesterName ?? "Driver") : (job.helperName ?? "Awaiting helper"))
                                .font(RaahiTypography.captionBold)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("₹\(Int(job.rewardAmount))")
                            .font(RaahiTypography.headline)
                            .foregroundColor(Color.raahiGreen)
                    }
                }
            }
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status.uppercased() {
        case "COMPLETED":
            return Color.raahiGreen
        case "MATCHED", "ARRIVED", "IN_PROGRESS", "WORK_DONE":
            return Color.raahiBlue
        case "PENDING":
            return Color.raahiYellow
        case "CANCELLED":
            return Color.raahiRed
        default:
            return Color.raahiTextSecondary
        }
    }
}
