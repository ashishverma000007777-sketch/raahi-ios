import SwiftUI

public struct FuelRatesView: View {
    @ObservedObject public var viewModel: WalletViewModel
    @State private var searchText = ""
    
    public init(viewModel: WalletViewModel) {
        self.viewModel = viewModel
    }
    
    private var filteredRates: [FuelRateDto] {
        if searchText.isEmpty {
            return viewModel.fuelRates
        } else {
            return viewModel.fuelRates.filter { $0.state.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Search Bar
            RaahiTextField(
                placeholder: "Search state (e.g. Maharashtra, Delhi)...",
                icon: "magnifyingglass",
                text: $searchText
            )
            
            if filteredRates.isEmpty {
                EmptyStateView(
                    icon: "fuelpump.slash",
                    title: "No Fuel Rates Found",
                    message: "Check back shortly for updated fuel rates across Indian states."
                )
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(filteredRates) { rate in
                        GlassCard(cornerRadius: 14, padding: 14) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(rate.state)
                                        .font(RaahiTypography.bodyBold)
                                        .foregroundColor(.white)
                                    Spacer()
                                    if let source = rate.source {
                                        Text(source == "ADMIN_MANUAL" ? "Verified" : "Indicative")
                                            .font(RaahiTypography.micro)
                                            .foregroundColor(Color.raahiTextMuted)
                                    }
                                }
                                
                                HStack(spacing: 16) {
                                    FuelPricePill(title: "Petrol", price: rate.petrol, color: Color.raahiOrange)
                                    FuelPricePill(title: "Diesel", price: rate.diesel, color: Color.raahiBlue)
                                    if let cng = rate.cng {
                                        FuelPricePill(title: "CNG", price: cng, color: Color.raahiGreen)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct FuelPricePill: View {
    let title: String
    let price: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(RaahiTypography.micro)
                .foregroundColor(Color.raahiTextMuted)
            Text(String(format: "₹%.2f", price))
                .font(RaahiTypography.bodyBold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
