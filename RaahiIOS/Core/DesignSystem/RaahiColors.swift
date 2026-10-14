import SwiftUI

public extension Color {
    static let raahiBackground = Color(hex: "#07090F")
    static let raahiSurface = Color(hex: "#0C0F18")
    static let raahiCard = Color(hex: "#121E2D")
    static let raahiCardSecondary = Color(hex: "#1A2738")
    static let raahiBorder = Color.white.opacity(0.10)
    
    // Accents
    static let raahiOrange = Color(hex: "#FF6B00")
    static let raahiOrangeEnd = Color(hex: "#FF3D7F")
    static let raahiGreen = Color(hex: "#00C853")
    static let raahiBlue = Color(hex: "#00A2FF")
    static let raahiPurple = Color(hex: "#7C5CFF")
    static let raahiRed = Color(hex: "#FF4D4F")
    static let raahiYellow = Color(hex: "#FFA726")
    
    // Text
    static let raahiTextPrimary = Color.white
    static let raahiTextSecondary = Color(hex: "#8A9BAE")
    static let raahiTextMuted = Color.white.opacity(0.40)
    
    // Gradients
    static var raahiBrandGradient: LinearGradient {
        LinearGradient(
            colors: [Color.raahiOrange, Color.raahiOrangeEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var raahiAiGradient: LinearGradient {
        LinearGradient(
            colors: [Color.raahiBlue, Color.raahiPurple],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var raahiGreenGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#00E676"), Color(hex: "#00A844")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
