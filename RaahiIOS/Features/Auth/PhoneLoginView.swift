import SwiftUI

public struct PhoneLoginView: View {
    @ObservedObject public var viewModel: AuthViewModel
    
    public init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                // Brand Header
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.raahiBrandGradient)
                            .frame(width: 76, height: 76)
                            .shadow(color: Color.raahiOrange.opacity(0.35), radius: 16, y: 8)
                        
                        Image(systemName: "car.side.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                    
                    Text("Raahi")
                        .font(RaahiTypography.largeTitle)
                        .foregroundColor(.white)
                    
                    Text("Highway Assistance & Car Care")
                        .font(RaahiTypography.subheadline)
                        .foregroundColor(Color.raahiTextSecondary)
                }
                
                // Input Card
                GlassCard(cornerRadius: 20, padding: 20) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Enter your phone number")
                            .font(RaahiTypography.headline)
                            .foregroundColor(.white)
                        
                        Text("We'll send a 6-digit OTP code to verify your account")
                            .font(RaahiTypography.caption)
                            .foregroundColor(Color.raahiTextSecondary)
                        
                        HStack(spacing: 10) {
                            HStack(spacing: 4) {
                                Text("🇮🇳")
                                Text("+91")
                                    .font(RaahiTypography.bodyBold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 52)
                            .background(Color.raahiSurface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.raahiBorder, lineWidth: 1)
                            )
                            
                            RaahiTextField(
                                placeholder: "98765 43210",
                                icon: nil,
                                text: $viewModel.phoneNumber,
                                keyboardType: .phonePad
                            )
                        }
                        
                        if let error = viewModel.errorMessage {
                            ErrorBannerView(message: error)
                        }
                        
                        RaahiButton(
                            title: "Send Verification Code",
                            icon: "arrow.right",
                            style: .primary,
                            isLoading: viewModel.isLoading
                        ) {
                            Task {
                                await viewModel.sendOtp()
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Terms footer
                Text("By continuing, you agree to Raahi's Terms of Service and Privacy Policy")
                    .font(RaahiTypography.caption)
                    .foregroundColor(Color.raahiTextMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
            }
        }
    }
}
