import SwiftUI

public struct ShopView: View {
    @ObservedObject public var viewModel: WalletViewModel
    
    public init(viewModel: WalletViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Emergency Roadside Gear & Accessories")
                    .font(RaahiTypography.body)
                    .foregroundColor(Color.raahiTextSecondary)
                Spacer()
            }
            
            if viewModel.shopProducts.isEmpty {
                EmptyStateView(
                    icon: "bag",
                    title: "Curating Roadside Products",
                    message: "Emergency jumpstart kits, tyre inflators, and safety gear will be listed here."
                )
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(viewModel.shopProducts) { product in
                        GlassCard(cornerRadius: 14, padding: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                ZStack {
                                    Color.raahiCardSecondary
                                    Image(systemName: "wrench.and.screwdriver")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color.raahiOrange)
                                }
                                .frame(height: 100)
                                .cornerRadius(10)
                                
                                Text(product.name)
                                    .font(RaahiTypography.bodyBold)
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                
                                HStack {
                                    Text("₹\(Int(product.price))")
                                        .font(RaahiTypography.headline)
                                        .foregroundColor(Color.raahiGreen)
                                    if let disc = product.discountPrice {
                                        Text("₹\(Int(disc))")
                                            .font(RaahiTypography.caption)
                                            .strikethrough()
                                            .foregroundColor(Color.raahiTextMuted)
                                    }
                                    Spacer()
                                }
                                
                                Button(action: {
                                    if let url = URL(string: product.affiliateUrl) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Text("View on Store")
                                        Image(systemName: "arrow.up.right")
                                    }
                                    .font(RaahiTypography.captionBold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 32)
                                    .background(Color.raahiOrange)
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
