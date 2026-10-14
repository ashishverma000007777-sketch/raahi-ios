import Foundation
import UIKit

@MainActor
public final class HelperApplicationViewModel: ObservableObject {
    @Published public var application: HelperApplicationDto? = nil
    @Published public var isLoading: Bool = false
    @Published public var isSubmitting: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var submissionSuccess: Bool = false
    
    // Form fields
    @Published public var applicantName: String = ""
    @Published public var applicantPhone: String = ""
    @Published public var vehicleType: String = "Car"
    @Published public var vehicleBrand: String = ""
    @Published public var vehicleModel: String = ""
    @Published public var vehicleReg: String = ""
    @Published public var experienceYears: String = "3"
    @Published public var services: String = "Tyre repair, Battery jumpstart, Towing"
    @Published public var payoutUpi: String = ""
    
    // Document image data
    @Published public var aadhaarFrontData: Data? = nil
    @Published public var aadhaarBackData: Data? = nil
    @Published public var selfieData: Data? = nil
    
    private let apiClient: APIClientProtocol
    
    public init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    public func loadApplication() async {
        isLoading = true
        errorMessage = nil
        do {
            let app: HelperApplicationDto = try await apiClient.request(.myHelperApplication)
            self.application = app
            self.applicantName = app.applicantName ?? ""
            self.applicantPhone = app.applicantPhone ?? ""
            self.isLoading = false
        } catch {
            self.isLoading = false
            // 404 NO_APPLICATION is normal for first-time applicants
        }
    }
    
    public func submitApplication() async -> Bool {
        guard let front = aadhaarFrontData, let back = aadhaarBackData else {
            errorMessage = "Please upload both front and back photos of your Aadhaar card."
            return false
        }
        
        guard !applicantName.isEmpty, !applicantPhone.isEmpty else {
            errorMessage = "Name and phone number are required."
            return false
        }
        
        isSubmitting = true
        errorMessage = nil
        
        var parts: [MultipartFormPart] = [
            MultipartFormPart(name: "applicantName", data: applicantName.data(using: .utf8)!),
            MultipartFormPart(name: "applicantPhone", data: applicantPhone.data(using: .utf8)!),
            MultipartFormPart(name: "vehicleType", data: vehicleType.data(using: .utf8)!),
            MultipartFormPart(name: "vehicleBrand", data: vehicleBrand.data(using: .utf8)!),
            MultipartFormPart(name: "vehicleModel", data: vehicleModel.data(using: .utf8)!),
            MultipartFormPart(name: "vehicleReg", data: vehicleReg.data(using: .utf8)!),
            MultipartFormPart(name: "experienceYears", data: experienceYears.data(using: .utf8)!),
            MultipartFormPart(name: "services", data: services.data(using: .utf8)!),
            MultipartFormPart(name: "payoutUpi", data: payoutUpi.data(using: .utf8)!),
            MultipartFormPart(name: "aadhaarFront", filename: "aadhaar_front.jpg", mimeType: "image/jpeg", data: front),
            MultipartFormPart(name: "aadhaarBack", filename: "aadhaar_back.jpg", mimeType: "image/jpeg", data: back)
        ]
        
        if let selfie = selfieData {
            parts.append(MultipartFormPart(name: "selfie", filename: "selfie.jpg", mimeType: "image/jpeg", data: selfie))
        }
        
        do {
            let submitted: HelperApplicationDto = try await apiClient.uploadMultipart(
                path: "helper/apply",
                parts: parts
            )
            self.application = submitted
            self.isSubmitting = false
            self.submissionSuccess = true
            return true
        } catch {
            self.isSubmitting = false
            self.errorMessage = error.localizedDescription
            return false
        }
    }
}
