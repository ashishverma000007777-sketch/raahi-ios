import SwiftUI

public struct WalletView: View {
    @StateObject private var viewModel = WalletViewModel()
    @State private var selectedTab: Int = 0 // 0: Savings, 1: Fuel Rates, 2: Plans, 3: Shop
    
    public init() {}
    
    private let tabs = ["Savings", "Fuel Radar", "Membership", "Shop"]
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Paisa Bachao & Services")
                            .font(RaahiTypography.title)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            Task { await viewModel.loadData() }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.raahiOrange)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Horizontal Tab Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(0..<tabs.count, id: \.self) { idx in
                                let isSelected = selectedTab == idx
                                Button(action: { selectedTab = idx }) {
                                    Text(tabs[idx])
                                        .font(RaahiTypography.captionBold)
                                        .foregroundColor(isSelected ? .white : Color.raahiTextSecondary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(isSelected ? Color.raahiOrange : Color.raahiCard)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isSelected ? Color.raahiOrange : Color.raahiBorder, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Selected Tab Content
                    VStack {
                        switch selectedTab {
                        case 0:
                            PaisaBachaoView(viewModel: viewModel)
                        case 1:
                            FuelRatesView(viewModel: viewModel)
                        case 2:
                            SubscriptionView(viewModel: viewModel)
                        case 3:
                            ShopView(viewModel: viewModel)
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 36)
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}
