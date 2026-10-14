import SwiftUI

public struct PaisaBachaoView: View {
    @ObservedObject public var viewModel: WalletViewModel
    
    public init(viewModel: WalletViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 18) {
            if let savings = viewModel.savings {
                // MoM Fuel Savings Hero
                GlassCard(cornerRadius: 18, padding: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("MONTHLY FUEL SPEND")
                                .font(RaahiTypography.captionBold)
                                .foregroundColor(Color.raahiTextSecondary)
                            Spacer()
                            if let trend = savings.mileageTrendText {
                                StatusBadge(text: trend, color: Color.raahiGreen)
                            }
                        }
                        
                        if let currentSpend = savings.currentMonthFuelSpend {
                            Text("₹\(Int(currentSpend))")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        } else {
                            Text("No Fuel Logs This Month")
                                .font(RaahiTypography.headline)
                                .foregroundColor(Color.raahiTextMuted)
                        }
                        
                        if let msg = savings.fuelSpendSavingsMessage {
                            Text(msg)
                                .font(RaahiTypography.caption)
                                .foregroundColor(Color.raahiGreen)
                        }
                        
                        Divider().background(Color.raahiBorder)
                        
                        HStack(spacing: 16) {
                            StatBox(label: "Litres Filled", value: savings.currentMonthLitres != nil ? String(format: "%.1f L", savings.currentMonthLitres!) : "—")
                            StatBox(label: "Distance", value: savings.currentMonthDistanceKm != nil ? String(format: "%.0f km", savings.currentMonthDistanceKm!) : "—")
                            StatBox(label: "Mileage", value: savings.currentMonthMileageKmPerLitre != nil ? String(format: "%.1f km/L", savings.currentMonthMileageKmPerLitre!) : "—")
                        }
                    }
                }
                
                // Community Benchmark Card
                if let bench = savings.communityBenchmark, bench.available {
                    GlassCard(cornerRadius: 16, padding: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "chart.bar.xaxis")
                                    .foregroundColor(Color.raahiBlue)
                                Text("Community Mileage Benchmark")
                                    .font(RaahiTypography.bodyBold)
                                    .foregroundColor(.white)
                            }
                            
                            if let summary = bench.comparisonSummary {
                                Text(summary)
                                    .font(RaahiTypography.caption)
                                    .foregroundColor(Color.raahiTextSecondary)
                            }
                            
                            HStack {
                                Text("Your Mileage: \(String(format: "%.1f", bench.userAvgMileage ?? 0)) km/L")
                                Spacer()
                                Text("Community Avg: \(String(format: "%.1f", bench.communityAvgMileage ?? 0)) km/L")
                            }
                            .font(RaahiTypography.captionBold)
                            .foregroundColor(Color.raahiOrange)
                        }
                    }
                }
                
                // Fuel Price Radar Recommendation
                if let radar = savings.fuelPriceRadar, let advice = radar.radarAdvice {
                    GlassCard(cornerRadius: 16, padding: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "fuelpump.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color.raahiOrange)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Interstate Fuel Price Radar")
                                    .font(RaahiTypography.bodyBold)
                                    .foregroundColor(.white)
                                Text(advice)
                                    .font(RaahiTypography.caption)
                                    .foregroundColor(Color.raahiTextSecondary)
                            }
                            Spacer()
                        }
                    }
                }
                
                // Streaks & Badges
                if !savings.streaks.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SAVINGS ACHIEVEMENTS")
                            .font(RaahiTypography.captionBold)
                            .foregroundColor(Color.raahiOrange)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(savings.streaks) { badge in
                                GlassCard(cornerRadius: 12, padding: 12) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(badge.isAchieved ? Color.raahiGreen.opacity(0.2) : Color.raahiCardSecondary)
                                                .frame(width: 40, height: 40)
                                            Image(systemName: badge.isAchieved ? "trophy.fill" : "lock.fill")
                                                .foregroundColor(badge.isAchieved ? Color.raahiGreen : Color.raahiTextMuted)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(badge.title)
                                                .font(RaahiTypography.bodyBold)
                                                .foregroundColor(.white)
                                            Text(badge.subtitle)
                                                .font(RaahiTypography.caption)
                                                .foregroundColor(Color.raahiTextSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(badge.progressText)
                                            .font(RaahiTypography.captionBold)
                                            .foregroundColor(badge.isAchieved ? Color.raahiGreen : Color.raahiTextMuted)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                EmptyStateView(
                    icon: "indianrupeesign.circle",
                    title: "No Savings Data Yet",
                    message: "Log your fuel fill-ups and trips to track monthly fuel savings and community mileage benchmarks."
                )
            }
        }
    }
}

private struct StatBox: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(RaahiTypography.micro)
                .foregroundColor(Color.raahiTextMuted)
            Text(value)
                .font(RaahiTypography.bodyBold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
