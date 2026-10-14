import SwiftUI
import CoreLocation

public struct RequestHelpView: View {
    @StateObject private var viewModel = RequestHelpViewModel()
    @Environment(\.dismiss) private var dismiss
    
    public var onJobCreated: ((JobDto) -> Void)?
    
    public init(onJobCreated: ((JobDto) -> Void)? = nil) {
        self.onJobCreated = onJobCreated
    }
    
    private let quickAmounts: [Double] = [200, 350, 500, 1000]
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Top Navigation
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color.raahiTextSecondary)
                        }
                        Spacer()
                        Text("Request Roadside Help")
                            .font(RaahiTypography.headline)
                            .foregroundColor(.white)
                        Spacer()
                        // Balance spacing
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.clear)
                    }
                    .padding(.top, 16)
                    
                    // Step 1: Select Category Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. WHAT HAPPENED?")
                            .font(RaahiTypography.captionBold)
                            .foregroundColor(Color.raahiOrange)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(ProblemTypes.all) { cat in
                                let isSelected = viewModel.selectedCategory.id == cat.id
                                Button(action: {
                                    viewModel.selectCategory(cat)
                                }) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: cat.iconName)
                                                .font(.system(size: 22))
                                                .foregroundColor(isSelected ? .white : Color.raahiOrange)
                                            Spacer()
                                            if isSelected {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 16))
                                            }
                                        }
                                        
                                        Text(cat.title)
                                            .font(RaahiTypography.bodyBold)
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        
                                        Text(cat.subtitle)
                                            .font(RaahiTypography.micro)
                                            .foregroundColor(isSelected ? Color.white.opacity(0.85) : Color.raahiTextSecondary)
                                            .lineLimit(2)
                                    }
                                    .padding(14)
                                    .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
                                    .background(isSelected ? Color.raahiOrange : Color.raahiCard)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(isSelected ? Color.raahiOrange : Color.raahiBorder, lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    
                    // Step 2: Location Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("2. YOUR LOCATION")
                            .font(RaahiTypography.captionBold)
                            .foregroundColor(Color.raahiOrange)
                        
                        GlassCard(cornerRadius: 14, padding: 14) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.raahiBlue.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "location.fill")
                                        .foregroundColor(Color.raahiBlue)
                                        .font(.system(size: 18))
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    if viewModel.isLocating {
                                        Text("Detecting current GPS location...")
                                            .font(RaahiTypography.body)
                                            .foregroundColor(Color.raahiTextSecondary)
                                    } else if let loc = viewModel.currentLocation {
                                        Text("GPS Location Captured")
                                            .font(RaahiTypography.bodyBold)
                                            .foregroundColor(.white)
                                        Text(String(format: "%.4f° N, %.4f° E", loc.latitude, loc.longitude))
                                            .font(RaahiTypography.caption)
                                            .foregroundColor(Color.raahiTextSecondary)
                                    } else {
                                        Text("Tap to capture GPS location")
                                            .font(RaahiTypography.body)
                                            .foregroundColor(Color.raahiTextMuted)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: { viewModel.fetchCurrentLocation() }) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color.raahiBlue)
                                        .padding(8)
                                        .background(Color.raahiBlue.opacity(0.12))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        
                        RaahiTextField(
                            placeholder: "Highway name or nearest landmark (optional)",
                            icon: "signpost.right.fill",
                            text: $viewModel.highwayName
                        )
                    }
                    
                    // Step 3: Cash Reward Offer
                    VStack(alignment: .leading, spacing: 12) {
                        Text("3. HELPER CASH REWARD")
                            .font(RaahiTypography.captionBold)
                            .foregroundColor(Color.raahiOrange)
                        
                        Text("Cash paid directly to the helper in person. Raahi takes 0% commission.")
                            .font(RaahiTypography.caption)
                            .foregroundColor(Color.raahiTextSecondary)
                        
                        HStack(spacing: 8) {
                            ForEach(quickAmounts, id: \.self) { amt in
                                let isSelected = viewModel.rewardAmount == amt
                                Button(action: {
                                    viewModel.setQuickAmount(amt)
                                }) {
                                    Text("₹\(Int(amt))")
                                        .font(RaahiTypography.bodyBold)
                                        .foregroundColor(isSelected ? .white : Color.raahiTextSecondary)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(isSelected ? Color.raahiOrange : Color.raahiSurface)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(isSelected ? Color.raahiOrange : Color.raahiBorder, lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                    
                    // Step 4: Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("4. DESCRIBE ISSUE (OPTIONAL)")
                            .font(RaahiTypography.captionBold)
                            .foregroundColor(Color.raahiOrange)
                        
                        RaahiTextField(
                            placeholder: "e.g. Front right tyre is completely flat...",
                            icon: "note.text",
                            text: $viewModel.descriptionText
                        )
                    }
                    
                    if let error = viewModel.errorMessage {
                        ErrorBannerView(message: error)
                    }
                    
                    // Submit Button
                    RaahiButton(
                        title: "Post Help Request",
                        icon: "paperplane.fill",
                        style: .primary,
                        isLoading: viewModel.isSubmitting
                    ) {
                        Task {
                            let success = await viewModel.submitRequest()
                            if success, let job = viewModel.createdJob {
                                onJobCreated?(job)
                                dismiss()
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
        }
    }
}
