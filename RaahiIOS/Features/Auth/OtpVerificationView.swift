import SwiftUI

public struct OtpVerificationView: View {
    @ObservedObject public var viewModel: AuthViewModel
    
    public init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Top Bar with back button
                HStack {
                    Button(action: {
                        viewModel.isOtpSent = false
                        viewModel.otpCode = ""
                        viewModel.errorMessage = nil
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(RaahiTypography.bodyBold)
                        .foregroundColor(Color.raahiOrange)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
                
                // Content Card
                GlassCard(cornerRadius: 20, padding: 20) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Verify Code")
                                .font(RaahiTypography.title)
                                .foregroundColor(.white)
                            
                            Text("Sent to +91 \(viewModel.phoneNumber)")
                                .font(RaahiTypography.body)
                                .foregroundColor(Color.raahiTextSecondary)
                        }
                        
                        RaahiTextField(
                            placeholder: "Enter 6-digit OTP",
                            icon: "lock.shield",
                            text: $viewModel.otpCode,
                            keyboardType: .numberPad
                        )
                        
                        if let error = viewModel.errorMessage {
                            ErrorBannerView(message: error)
                        }
                        
                        RaahiButton(
                            title: "Verify & Continue",
                            icon: "checkmark",
                            style: .primary,
                            isLoading: viewModel.isLoading
                        ) {
                            Task {
                                await viewModel.verifyOtp()
                            }
                        }
                        
                        HStack {
                            Spacer()
                            if viewModel.resendCooldown > 0 {
                                Text("Resend code in \(viewModel.resendCooldown)s")
                                    .font(RaahiTypography.caption)
                                    .foregroundColor(Color.raahiTextMuted)
                            } else {
                                Button(action: {
                                    Task {
                                        await viewModel.resendOtp()
                                    }
                                }) {
                                    Text("Didn't receive code? Resend")
                                        .font(RaahiTypography.captionBold)
                                        .foregroundColor(Color.raahiOrange)
                                }
                            }
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}
