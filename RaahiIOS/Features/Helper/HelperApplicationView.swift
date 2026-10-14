import SwiftUI
import PhotosUI

public struct HelperApplicationView: View {
    @StateObject private var viewModel = HelperApplicationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // Photo pickers
    @State private var frontPickerItem: PhotosPickerItem? = nil
    @State private var backPickerItem: PhotosPickerItem? = nil
    @State private var selfiePickerItem: PhotosPickerItem? = nil
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text("Become a Helper")
                            .font(RaahiTypography.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18))
                            .foregroundColor(.clear)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Status Banner if existing application
                    if let app = viewModel.application {
                        GlassCard(cornerRadius: 16, padding: 16) {
                            HStack {
                                Image(systemName: iconForStatus(app.status))
                                    .font(.system(size: 24))
                                    .foregroundColor(colorForStatus(app.status))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Application Status: \(app.status)")
                                        .font(RaahiTypography.bodyBold)
                                        .foregroundColor(.white)
                                    if let reason = app.rejectionReason {
                                        Text("Reason: \(reason)")
                                            .font(RaahiTypography.caption)
                                            .foregroundColor(Color.raahiRed)
                                    } else {
                                        Text(captionForStatus(app.status))
                                            .font(RaahiTypography.caption)
                                            .foregroundColor(Color.raahiTextSecondary)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Form Content
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Personal & Vehicle Details")
                            .font(RaahiTypography.headline)
                            .foregroundColor(.white)
                        
                        RaahiTextField(placeholder: "Full Legal Name", icon: "person.fill", text: $viewModel.applicantName)
                        RaahiTextField(placeholder: "Phone Number", icon: "phone.fill", text: $viewModel.applicantPhone, keyboardType: .phonePad)
                        RaahiTextField(placeholder: "Vehicle Brand & Model (e.g. Maruti Swift)", icon: "car.fill", text: $viewModel.vehicleBrand)
                        RaahiTextField(placeholder: "Vehicle Registration (e.g. MH 02 AB 1234)", icon: "number", text: $viewModel.vehicleReg)
                        RaahiTextField(placeholder: "Years of Mechanic / Breakdown Experience", icon: "clock.fill", text: $viewModel.experienceYears, keyboardType: .numberPad)
                        RaahiTextField(placeholder: "Payout UPI ID (e.g. name@upi)", icon: "indianrupeesign", text: $viewModel.payoutUpi)
                    }
                    .padding(.horizontal, 20)
                    
                    // Document Upload Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Identity Verification Documents")
                            .font(RaahiTypography.headline)
                            .foregroundColor(.white)
                        
                        Text("Government Aadhaar card front & back required. Advisory tamper screening applied.")
                            .font(RaahiTypography.caption)
                            .foregroundColor(Color.raahiTextSecondary)
                        
                        // Aadhaar Front Picker
                        PhotosPicker(selection: $frontPickerItem, matching: .images) {
                            DocumentUploadCard(
                                title: "Aadhaar Card (Front)",
                                isUploaded: viewModel.aadhaarFrontData != nil
                            )
                        }
                        .onChange(of: frontPickerItem) { item in
                            Task {
                                if let data = try? await item?.loadTransferable(type: Data.self) {
                                    viewModel.aadhaarFrontData = data
                                }
                            }
                        }
                        
                        // Aadhaar Back Picker
                        PhotosPicker(selection: $backPickerItem, matching: .images) {
                            DocumentUploadCard(
                                title: "Aadhaar Card (Back)",
                                isUploaded: viewModel.aadhaarBackData != nil
                            )
                        }
                        .onChange(of: backPickerItem) { item in
                            Task {
                                if let data = try? await item?.loadTransferable(type: Data.self) {
                                    viewModel.aadhaarBackData = data
                                }
                            }
                        }
                        
                        // Optional Selfie
                        PhotosPicker(selection: $selfiePickerItem, matching: .images) {
                            DocumentUploadCard(
                                title: "Selfie Photo (Optional)",
                                isUploaded: viewModel.selfieData != nil
                            )
                        }
                        .onChange(of: selfiePickerItem) { item in
                            Task {
                                if let data = try? await item?.loadTransferable(type: Data.self) {
                                    viewModel.selfieData = data
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    if let error = viewModel.errorMessage {
                        ErrorBannerView(message: error)
                            .padding(.horizontal, 20)
                    }
                    
                    if viewModel.submissionSuccess {
                        GlassCard(cornerRadius: 14, padding: 14) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.raahiGreen)
                                Text("Application submitted successfully for manual review.")
                                    .font(RaahiTypography.bodyBold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Submit Button
                    RaahiButton(
                        title: "Submit Helper Application",
                        icon: "paperplane.fill",
                        style: .primary,
                        isLoading: viewModel.isSubmitting
                    ) {
                        Task {
                            _ = await viewModel.submitApplication()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                }
            }
        }
        .task {
            await viewModel.loadApplication()
        }
    }
    
    private func iconForStatus(_ s: String) -> String {
        switch s.uppercased() {
        case "APPROVED": return "checkmark.seal.fill"
        case "PENDING": return "hourglass"
        case "REJECTED": return "xmark.seal.fill"
        default: return "doc.fill"
        }
    }
    
    private func colorForStatus(_ s: String) -> Color {
        switch s.uppercased() {
        case "APPROVED": return Color.raahiGreen
        case "PENDING": return Color.raahiYellow
        case "REJECTED": return Color.raahiRed
        default: return Color.raahiTextSecondary
        }
    }
    
    private func captionForStatus(_ s: String) -> String {
        switch s.uppercased() {
        case "APPROVED": return "You are verified to accept roadside assistance requests."
        case "PENDING": return "Your application is currently pending admin review."
        case "REJECTED": return "Please review rejection reason and resubmit."
        default: return "Submit your documents below."
        }
    }
}

private struct DocumentUploadCard: View {
    let title: String
    let isUploaded: Bool
    
    var body: some View {
        GlassCard(cornerRadius: 12, padding: 14) {
            HStack {
                Image(systemName: isUploaded ? "checkmark.circle.fill" : "camera.fill")
                    .foregroundColor(isUploaded ? Color.raahiGreen : Color.raahiOrange)
                    .font(.system(size: 18))
                
                Text(title)
                    .font(RaahiTypography.bodyBold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(isUploaded ? "Selected" : "Tap to Choose")
                    .font(RaahiTypography.captionBold)
                    .foregroundColor(isUploaded ? Color.raahiGreen : Color.raahiTextMuted)
            }
        }
    }
}
