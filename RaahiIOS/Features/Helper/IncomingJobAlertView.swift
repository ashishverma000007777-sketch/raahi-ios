import SwiftUI

public struct IncomingJobAlertView: View {
    public let job: JobDto
    public let onDecision: (Bool) -> Void
    
    @State private var timeRemaining = 30
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    public init(job: JobDto, onDecision: @escaping (Bool) -> Void) {
        self.job = job
        self.onDecision = onDecision
    }
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                // Pulsing Alert Icon
                ZStack {
                    Circle()
                        .fill(Color.raahiOrange.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .fill(Color.raahiOrange)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 8) {
                    Text("New Roadside Request!")
                        .font(RaahiTypography.largeTitle)
                        .foregroundColor(.white)
                    
                    let cat = ProblemTypes.category(for: job.problemType)
                    Text(cat?.title ?? job.problemType)
                        .font(RaahiTypography.title)
                        .foregroundColor(Color.raahiOrange)
                }
                
                // Job Details Card
                GlassCard(cornerRadius: 18, padding: 18) {
                    VStack(spacing: 14) {
                        HStack {
                            Text("Customer Cash Reward")
                                .font(RaahiTypography.body)
                                .foregroundColor(Color.raahiTextSecondary)
                            Spacer()
                            Text("₹\(Int(job.rewardAmount))")
                                .font(RaahiTypography.largeTitle)
                                .foregroundColor(Color.raahiGreen)
                        }
                        
                        Divider().background(Color.raahiBorder)
                        
                        if let desc = job.problemDesc, !desc.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Description")
                                    .font(RaahiTypography.captionBold)
                                    .foregroundColor(Color.raahiTextMuted)
                                Text(desc)
                                    .font(RaahiTypography.body)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        if let name = job.requesterName {
                            HStack {
                                Text("Customer:")
                                    .font(RaahiTypography.caption)
                                    .foregroundColor(Color.raahiTextMuted)
                                Text(name)
                                    .font(RaahiTypography.captionBold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // Countdown
                Text("Auto-dismissing in \(timeRemaining)s")
                    .font(RaahiTypography.caption)
                    .foregroundColor(Color.raahiTextMuted)
                
                Spacer()
                
                // Accept & Decline Buttons
                VStack(spacing: 12) {
                    RaahiButton(
                        title: "Accept Roadside Job",
                        icon: "checkmark.circle.fill",
                        style: .success
                    ) {
                        onDecision(true)
                    }
                    
                    Button(action: { onDecision(false) }) {
                        Text("Decline")
                            .font(RaahiTypography.bodyBold)
                            .foregroundColor(Color.raahiTextSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                onDecision(false)
            }
        }
    }
}
