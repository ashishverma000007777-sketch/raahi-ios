import SwiftUI

public struct SubscriptionView: View {
    @ObservedObject public var viewModel: WalletViewModel
    
    public init(viewModel: WalletViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Active Subscription Card
            if let sub = viewModel.mySubscription {
                GlassCard(cornerRadius: 16, padding: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CURRENT MEMBERSHIP")
                                .font(RaahiTypography.captionBold)
                                .foregroundColor(Color.raahiTextSecondary)
                            Text(sub.tier)
                                .font(RaahiTypography.title)
                                .foregroundColor(.white)
                            Text(sub.isActive ? "Active membership" : "Inactive")
                                .font(RaahiTypography.caption)
                                .foregroundColor(sub.isActive ? Color.raahiGreen : Color.raahiYellow)
                        }
                        Spacer()
                        StatusBadge(
                            text: sub.isActive ? "ACTIVE" : "EXPIRED",
                            color: sub.isActive ? Color.raahiGreen : Color.raahiRed
                        )
                    }
                }
            }
            
            if let msg = viewModel.subscribeMessage {
                ErrorBannerView(message: msg)
            }
            
            // Available Plans
            VStack(alignment: .leading, spacing: 14) {
                Text("AVAILABLE PLANS")
                    .font(RaahiTypography.captionBold)
                    .foregroundColor(Color.raahiOrange)
                
                ForEach(viewModel.subscriptionPlans) { plan in
                    GlassCard(cornerRadius: 16, padding: 18) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(plan.name)
                                        .font(RaahiTypography.headline)
                                        .foregroundColor(.white)
                                    Text("₹\(Int(plan.priceMonthly))/month or ₹\(Int(plan.priceYearly))/year")
                                        .font(RaahiTypography.caption)
                                        .foregroundColor(Color.raahiGreen)
                                }
                                Spacer()
                                StatusBadge(text: plan.tier, color: Color.raahiBlue)
                            }
                            
                            Divider().background(Color.raahiBorder)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(plan.features, id: \.self) { feature in
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(Color.raahiGreen)
                                        Text(feature)
                                            .font(RaahiTypography.caption)
                                            .foregroundColor(Color.raahiTextSecondary)
                                    }
                                }
                            }
                            
                            RaahiButton(
                                title: "Choose \(plan.name)",
                                icon: "crown.fill",
                                style: .primary,
                                isLoading: viewModel.isSubscribing
                            ) {
                                Task {
                                    await viewModel.subscribe(to: plan.tier)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                }
            }
        }
    }
}
