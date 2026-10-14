import Foundation

@MainActor
public final class AuthViewModel: ObservableObject {
    @Published public var phoneNumber: String = ""
    @Published public var otpCode: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var resendCooldown: Int = 0
    @Published public var isOtpSent: Bool = false
    @Published public var verificationId: String? = nil
    
    private let authManager: AuthManager
    private var cooldownTimer: Task<Void, Never>?
    
    public init(authManager: AuthManager = AuthManager.shared) {
        self.authManager = authManager
    }
    
    public var isValidPhone: Bool {
        let cleaned = phoneNumber.filter { $0.isNumber }
        return cleaned.count == 10
    }
    
    public var isValidOtp: Bool {
        let cleaned = otpCode.filter { $0.isNumber }
        return cleaned.count == 6
    }
    
    public func sendOtp() async {
        guard isValidPhone else {
            errorMessage = "Please enter a valid 10-digit phone number."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // In real iOS build with Firebase Phone Auth:
        // PhoneAuthProvider.provider().verifyPhoneNumber("+91\(phoneNumber)", uiDelegate: nil) { ... }
        // For development/mock fallback or staging:
        try? await Task.sleep(nanoseconds: 800_000_000)
        self.verificationId = "auth-verification-\(UUID().uuidString.prefix(8))"
        self.isOtpSent = true
        self.isLoading = false
        self.startCooldown()
    }
    
    public func verifyOtp() async {
        guard isValidOtp else {
            errorMessage = "Please enter the 6-digit OTP code."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Simulated Firebase ID token for verification against backend
            // In production: PhoneAuthCredential -> Auth.auth().signIn -> user.getIDToken()
            let mockOrRealIdToken = "firebase-token-\(phoneNumber)-\(otpCode)"
            _ = try await authManager.loginWithFirebaseToken(idToken: mockOrRealIdToken)
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func resendOtp() async {
        guard resendCooldown == 0 else { return }
        await sendOtp()
    }
    
    private func startCooldown() {
        resendCooldown = 30
        cooldownTimer?.cancel()
        cooldownTimer = Task {
            while resendCooldown > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if !Task.isCancelled {
                    self.resendCooldown -= 1
                }
            }
        }
    }
}
