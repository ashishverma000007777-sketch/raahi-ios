import SwiftUI
import MapKit

public struct JobDetailStatusView: View {
    @StateObject private var viewModel: JobDetailStatusViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(job: JobDto) {
        _viewModel = StateObject(wrappedValue: JobDetailStatusViewModel(job: job))
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
                        VStack(spacing: 2) {
                            Text("Job Details")
                                .font(RaahiTypography.headline)
                                .foregroundColor(.white)
                            Text("#\(viewModel.job.id.prefix(8))")
                                .font(RaahiTypography.caption)
                                .foregroundColor(Color.raahiTextSecondary)
                        }
                        Spacer()
                        Button(action: {
                            Task { await viewModel.reloadJob() }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.raahiOrange)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Map preview
                    JobTrackingMapView(
                        jobLocation: CLLocationCoordinate2D(latitude: viewModel.job.lat, longitude: viewModel.job.lng),
                        helperLocation: viewModel.helperLocation
                    )
                    .frame(height: 200)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.raahiBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Status Stepper Card
                    GlassCard(cornerRadius: 16, padding: 16) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("CURRENT STATUS")
                                    .font(RaahiTypography.captionBold)
                                    .foregroundColor(Color.raahiTextSecondary)
                                Spacer()
                                StatusBadge(text: viewModel.job.status, color: statusColor(viewModel.job.status))
                            }
                            
                            JobStatusTimeline(status: viewModel.job.status)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Problem Summary Card
                    GlassCard(cornerRadius: 16, padding: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                let category = ProblemTypes.category(for: viewModel.job.problemType)
                                Image(systemName: category?.iconName ?? "wrench.fill")
                                    .foregroundColor(Color.raahiOrange)
                                    .font(.system(size: 20))
                                Text(category?.title ?? viewModel.job.problemType)
                                    .font(RaahiTypography.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("₹\(Int(viewModel.job.rewardAmount))")
                                    .font(RaahiTypography.title)
                                    .foregroundColor(Color.raahiGreen)
                            }
                            
                            if let desc = viewModel.job.problemDesc, !desc.isEmpty {
                                Text(desc)
                                    .font(RaahiTypography.body)
                                    .foregroundColor(Color.raahiTextSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Participant Card
                    ParticipantCard(
                        isHelperViewer: viewModel.isHelper,
                        name: viewModel.isHelper ? (viewModel.job.requesterName ?? "Driver") : (viewModel.job.helperName ?? "Awaiting Helper"),
                        phone: viewModel.isHelper ? viewModel.job.requesterPhone : viewModel.job.helperPhone,
                        rating: viewModel.isHelper ? nil : viewModel.job.helperRatingAvg,
                        totalHelps: viewModel.isHelper ? nil : viewModel.job.helperTotalHelps,
                        isVerified: viewModel.isHelper ? true : (viewModel.job.helperVerified ?? false)
                    )
                    .padding(.horizontal, 20)
                    
                    // Contextual Action Card
                    VStack(spacing: 14) {
                        // Requester In-Person OTP Card
                        if viewModel.isRequester && viewModel.job.status.uppercased() == "MATCHED" {
                            if let otp = viewModel.job.helperOtp {
                                GlassCard(cornerRadius: 16, padding: 16) {
                                    VStack(spacing: 8) {
                                        Text("MEETUP HANDOFF OTP")
                                            .font(RaahiTypography.captionBold)
                                            .foregroundColor(Color.raahiOrange)
                                        Text("Show this code to your helper upon arrival:")
                                            .font(RaahiTypography.caption)
                                            .foregroundColor(Color.raahiTextSecondary)
                                        Text(otp)
                                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white)
                                            .tracking(8)
                                            .padding(.vertical, 4)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        
                        // Helper Actions
                        if viewModel.isHelper {
                            if viewModel.job.status.uppercased() == "MATCHED" {
                                RaahiButton(
                                    title: "I Have Arrived at Location",
                                    icon: "mappin.and.ellipse",
                                    style: .primary,
                                    isLoading: viewModel.isLoading
                                ) {
                                    Task { await viewModel.helperArrive() }
                                }
                            } else if viewModel.job.status.uppercased() == "ARRIVED" {
                                GlassCard(cornerRadius: 16, padding: 16) {
                                    VStack(spacing: 12) {
                                        Text("ENTER DRIVER'S OTP")
                                            .font(RaahiTypography.captionBold)
                                            .foregroundColor(Color.raahiOrange)
                                        
                                        RaahiTextField(
                                            placeholder: "6-digit OTP",
                                            icon: "key.fill",
                                            text: $viewModel.otpInput,
                                            keyboardType: .numberPad
                                        )
                                        
                                        RaahiButton(
                                            title: "Verify OTP & Start Help",
                                            icon: "checkmark",
                                            style: .primary,
                                            isLoading: viewModel.isVerifyingOtp
                                        ) {
                                            Task { await viewModel.verifyHandoffOtp() }
                                        }
                                    }
                                }
                            } else if viewModel.job.status.uppercased() == "IN_PROGRESS" {
                                RaahiButton(
                                    title: "Mark Work Finished",
                                    icon: "checkmark.circle.fill",
                                    style: .success,
                                    isLoading: viewModel.isLoading
                                ) {
                                    Task { await viewModel.helperMarkWorkDone() }
                                }
                            }
                        }
                        
                        // Requester Completion Action
                        if viewModel.isRequester && viewModel.job.status.uppercased() == "WORK_DONE" {
                            RaahiButton(
                                title: "Confirm Work Completed",
                                icon: "checkmark.seal.fill",
                                style: .success,
                                isLoading: viewModel.isLoading
                            ) {
                                Task { await viewModel.confirmCompletion() }
                            }
                        }
                        
                        // Rating Action for Completed
                        if viewModel.isRequester && viewModel.job.status.uppercased() == "COMPLETED" && !(viewModel.job.rated ?? false) {
                            RaahiButton(
                                title: "Rate Your Helper",
                                icon: "star.fill",
                                style: .primary
                            ) {
                                viewModel.showRatingSheet = true
                            }
                        }
                        
                        // Cancel Action
                        if viewModel.canCancel {
                            Button(action: { viewModel.showCancelDialog = true }) {
                                Text("Cancel Request")
                                    .font(RaahiTypography.bodyBold)
                                    .foregroundColor(Color.raahiRed)
                                    .padding(.vertical, 8)
                            }
                        }
                        
                        // Report Button
                        Button(action: { viewModel.showReportDialog = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "flag.fill")
                                Text("Report an Issue")
                            }
                            .font(RaahiTypography.captionBold)
                            .foregroundColor(Color.raahiTextMuted)
                        }
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
        .sheet(isPresented: $viewModel.showRatingSheet) {
            RatingSheetView(viewModel: viewModel)
        }
        .alert("Cancel Roadside Job?", isPresented: $viewModel.showCancelDialog) {
            Button("Keep Job", role: .cancel) {}
            Button("Confirm Cancel", role: .destructive) {
                Task { await viewModel.cancelJob(reason: "User requested cancellation") }
            }
        } message: {
            Text("Are you sure you want to cancel this help request?")
        }
        .sheet(isPresented: $viewModel.showReportDialog) {
            ReportSheetView(viewModel: viewModel)
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

// MARK: - Subcomponents
private struct JobTrackingMapView: View {
    let jobLocation: CLLocationCoordinate2D
    let helperLocation: CLLocationCoordinate2D?
    
    @State private var region: MKCoordinateRegion
    
    init(jobLocation: CLLocationCoordinate2D, helperLocation: CLLocationCoordinate2D?) {
        self.jobLocation = jobLocation
        self.helperLocation = helperLocation
        _region = State(initialValue: MKCoordinateRegion(
            center: jobLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: annotations) { item in
            MapAnnotation(coordinate: item.coordinate) {
                VStack(spacing: 2) {
                    Image(systemName: item.icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(item.color)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                    
                    Text(item.title)
                        .font(RaahiTypography.micro)
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(4)
                }
            }
        }
    }
    
    private var annotations: [MapItem] {
        var items = [
            MapItem(id: "job", coordinate: jobLocation, title: "Breakdown", icon: "car.fill", color: Color.raahiOrange)
        ]
        if let hLoc = helperLocation {
            items.append(MapItem(id: "helper", coordinate: hLoc, title: "Helper", icon: "wrench.fill", color: Color.raahiBlue))
        }
        return items
    }
    
    struct MapItem: Identifiable {
        let id: String
        let coordinate: CLLocationCoordinate2D
        let title: String
        let icon: String
        let color: Color
    }
}

private struct JobStatusTimeline: View {
    let status: String
    
    private let steps = ["PENDING", "MATCHED", "ARRIVED", "IN_PROGRESS", "WORK_DONE", "COMPLETED"]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<steps.count, id: \.self) { idx in
                let step = steps[idx]
                let isCompleted = stepIndex(status) >= idx
                let isCurrent = stepIndex(status) == idx
                
                VStack(spacing: 4) {
                    Circle()
                        .fill(isCurrent ? Color.raahiOrange : (isCompleted ? Color.raahiGreen : Color.raahiBorder))
                        .frame(width: isCurrent ? 12 : 8, height: isCurrent ? 12 : 8)
                    
                    Text(labelForStep(step))
                        .font(RaahiTypography.micro)
                        .foregroundColor(isCurrent ? Color.raahiOrange : (isCompleted ? .white : Color.raahiTextMuted))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                
                if idx < steps.count - 1 {
                    Rectangle()
                        .fill(stepIndex(status) > idx ? Color.raahiGreen : Color.raahiBorder)
                        .frame(height: 2)
                        .padding(.top, isCurrent ? 2 : 0)
                }
            }
        }
    }
    
    private func stepIndex(_ s: String) -> Int {
        steps.firstIndex(of: s.uppercased()) ?? 0
    }
    
    private func labelForStep(_ s: String) -> String {
        switch s {
        case "PENDING": return "Post"
        case "MATCHED": return "Match"
        case "ARRIVED": return "Arrived"
        case "IN_PROGRESS": return "Progress"
        case "WORK_DONE": return "Done"
        case "COMPLETED": return "Finish"
        default: return s
        }
    }
}

private struct ParticipantCard: View {
    let isHelperViewer: Bool
    let name: String
    let phone: String?
    let rating: Double?
    let totalHelps: Int?
    let isVerified: Bool
    
    var body: some View {
        GlassCard(cornerRadius: 16, padding: 16) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.raahiCardSecondary)
                        .frame(width: 50, height: 50)
                    Image(systemName: isHelperViewer ? "person.crop.circle.fill" : "wrench.and.screwdriver.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color.raahiOrange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(name)
                            .font(RaahiTypography.bodyBold)
                            .foregroundColor(.white)
                        if isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color.raahiBlue)
                                .font(.system(size: 14))
                        }
                    }
                    
                    if let rating = rating, rating > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.raahiYellow)
                                .font(.system(size: 12))
                            Text(String(format: "%.1f", rating))
                                .font(RaahiTypography.captionBold)
                                .foregroundColor(.white)
                            if let helps = totalHelps {
                                Text("(\(helps) helps)")
                                    .font(RaahiTypography.caption)
                                    .foregroundColor(Color.raahiTextMuted)
                            }
                        }
                    } else {
                        Text(isHelperViewer ? "Customer" : "Verified Raahi Helper")
                            .font(RaahiTypography.caption)
                            .foregroundColor(Color.raahiTextSecondary)
                    }
                }
                
                Spacer()
                
                if let phone = phone, !phone.isEmpty {
                    Button(action: {
                        if let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.raahiGreen)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

private struct RatingSheetView: View {
    @ObservedObject var viewModel: JobDetailStatusViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.raahiSurface.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Rate Your Helper")
                    .font(RaahiTypography.title)
                    .foregroundColor(.white)
                    .padding(.top, 24)
                
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { star in
                        Button(action: { viewModel.ratingStars = star }) {
                            Image(systemName: star <= viewModel.ratingStars ? "star.fill" : "star")
                                .font(.system(size: 32))
                                .foregroundColor(star <= viewModel.ratingStars ? Color.raahiYellow : Color.raahiTextMuted)
                        }
                    }
                }
                
                RaahiTextField(
                    placeholder: "Leave an optional comment...",
                    icon: "bubble.left.fill",
                    text: $viewModel.ratingComment
                )
                .padding(.horizontal, 20)
                
                RaahiButton(
                    title: "Submit Feedback",
                    icon: "checkmark",
                    style: .primary,
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        await viewModel.submitRating()
                        dismiss()
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}

private struct ReportSheetView: View {
    @ObservedObject var viewModel: JobDetailStatusViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.raahiSurface.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Report an Issue")
                    .font(RaahiTypography.title)
                    .foregroundColor(.white)
                    .padding(.top, 24)
                
                Text("Please describe what went wrong. Raahi support will review this incident.")
                    .font(RaahiTypography.body)
                    .foregroundColor(Color.raahiTextSecondary)
                    .padding(.horizontal, 20)
                
                RaahiTextField(
                    placeholder: "Describe the issue...",
                    icon: "exclamationmark.bubble.fill",
                    text: $viewModel.reportReason
                )
                .padding(.horizontal, 20)
                
                RaahiButton(
                    title: "Submit Report",
                    icon: "flag.fill",
                    style: .destructive,
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        await viewModel.reportIssue()
                        dismiss()
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}
