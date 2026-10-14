import SwiftUI

// MARK: - Glass Card
public struct GlassCard<Content: View>: View {
    public let cornerRadius: CGFloat
    public let padding: CGFloat
    public let content: Content
    
    public init(cornerRadius: CGFloat = 16, padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background(Color.raahiCard.opacity(0.85))
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.raahiBorder, lineWidth: 1)
            )
    }
}

// MARK: - Button Style & Component
public enum RaahiButtonStyle {
    case primary
    case secondary
    case ai
    case success
    case destructive
    case outline
}

public struct RaahiButton: View {
    public let title: String
    public let icon: String?
    public let style: RaahiButtonStyle
    public let isLoading: Bool
    public let action: () -> Void
    
    public init(
        title: String,
        icon: String? = nil,
        style: RaahiButtonStyle = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(RaahiTypography.bodyBold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(.white)
            .background(backgroundForStyle)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderForStyle, lineWidth: 1)
            )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
    }
    
    @ViewBuilder
    private var backgroundForStyle: some View {
        switch style {
        case .primary:
            Color.raahiBrandGradient
        case .secondary:
            Color.raahiCardSecondary
        case .ai:
            Color.raahiAiGradient
        case .success:
            Color.raahiGreenGradient
        case .destructive:
            Color.raahiRed
        case .outline:
            Color.clear
        }
    }
    
    private var borderForStyle: Color {
        switch style {
        case .outline:
            return Color.raahiOrange
        case .secondary:
            return Color.raahiBorder
        default:
            return Color.white.opacity(0.15)
        }
    }
}

// MARK: - Text Field
public struct RaahiTextField: View {
    public let placeholder: String
    public let icon: String?
    @Binding public var text: String
    public var isSecure: Bool = false
    public var keyboardType: UIKeyboardType = .default
    
    public init(
        placeholder: String,
        icon: String? = nil,
        text: Binding<String>,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        self.placeholder = placeholder
        self.icon = icon
        self._text = text
        self.isSecure = isSecure
        self.keyboardType = keyboardType
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(Color.raahiTextSecondary)
                    .frame(width: 20)
            }
            
            if isSecure {
                SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.raahiTextMuted))
                    .foregroundColor(.white)
                    .font(RaahiTypography.body)
            } else {
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.raahiTextMuted))
                    .foregroundColor(.white)
                    .font(RaahiTypography.body)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
            }
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.raahiTextMuted)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(Color.raahiSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.raahiBorder, lineWidth: 1)
        )
    }
}

// MARK: - Status Badge
public struct StatusBadge: View {
    public let text: String
    public let color: Color
    
    public init(text: String, color: Color) {
        self.text = text
        self.color = color
    }
    
    public var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(text)
                .font(RaahiTypography.micro)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.12))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Score Ring
public struct ScoreRing: View {
    public let score: Int?
    public let size: CGFloat
    
    public init(score: Int?, size: CGFloat = 84) {
        self.score = score
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .stroke(Color.raahiBorder, lineWidth: 8)
                .frame(width: size, height: size)
            
            if let score = score {
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(max(score, 0), 100)) / 100.0)
                    .stroke(
                        scoreColor(score),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: size, height: size)
                
                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: size * 0.32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("HEALTH")
                        .font(.system(size: size * 0.12, weight: .bold))
                        .foregroundColor(Color.raahiTextSecondary)
                }
            } else {
                Text("–")
                    .font(.system(size: size * 0.35, weight: .bold))
                    .foregroundColor(Color.raahiTextMuted)
            }
        }
    }
    
    private func scoreColor(_ s: Int) -> Color {
        if s >= 80 { return Color.raahiGreen }
        if s >= 50 { return Color.raahiYellow }
        return Color.raahiRed
    }
}

// MARK: - Ticker View
public struct TickerView: View {
    public let messages: [String]
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 4.5, on: .main, in: .common).autoconnect()
    
    public init(messages: [String] = [
        "Highway Help 24x7 active on NH-48 and major expressways",
        "Keep 10-foot following distance during highway night drives",
        "Check tyre pressure before heading onto long trips"
    ]) {
        self.messages = messages
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 4) {
                Image(systemName: "bell.badge.fill")
                    .foregroundColor(Color.raahiOrange)
                    .font(.system(size: 13))
                Text("LIVE")
                    .font(RaahiTypography.micro)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.raahiOrange)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.raahiOrange.opacity(0.15))
            .cornerRadius(6)
            
            Text(messages.isEmpty ? "" : messages[currentIndex % messages.count])
                .font(RaahiTypography.caption)
                .foregroundColor(Color.raahiTextSecondary)
                .lineLimit(1)
                .animation(.easeInOut, value: currentIndex)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.raahiCard.opacity(0.7))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.raahiBorder, lineWidth: 1)
        )
        .onReceive(timer) { _ in
            if !messages.isEmpty {
                withAnimation {
                    currentIndex = (currentIndex + 1) % messages.count
                }
            }
        }
    }
}

// MARK: - Empty State View
public struct EmptyStateView: View {
    public let icon: String
    public let title: String
    public let message: String
    public var actionTitle: String? = nil
    public var action: (() -> Void)? = nil
    
    public init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 42))
                .foregroundColor(Color.raahiTextMuted)
            
            Text(title)
                .font(RaahiTypography.headline)
                .foregroundColor(.white)
            
            Text(message)
                .font(RaahiTypography.body)
                .foregroundColor(Color.raahiTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(RaahiTypography.bodyBold)
                        .foregroundColor(Color.raahiOrange)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Color.raahiOrange.opacity(0.12))
                        .cornerRadius(10)
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Error Banner View
public struct ErrorBannerView: View {
    public let message: String
    public var retryAction: (() -> Void)? = nil
    
    public init(message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(Color.raahiRed)
            
            Text(message)
                .font(RaahiTypography.caption)
                .foregroundColor(.white)
                .lineLimit(2)
            
            Spacer()
            
            if let retry = retryAction {
                Button(action: retry) {
                    Text("Retry")
                        .font(RaahiTypography.captionBold)
                        .foregroundColor(Color.raahiRed)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.raahiRed.opacity(0.15))
                        .cornerRadius(6)
                }
            }
        }
        .padding(12)
        .background(Color.raahiRed.opacity(0.12))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.raahiRed.opacity(0.3), lineWidth: 1)
        )
    }
}
