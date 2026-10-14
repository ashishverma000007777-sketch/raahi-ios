import SwiftUI

public struct AIMechanicView: View {
    @StateObject private var viewModel = AIMechanicViewModel()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.raahiAiGradient)
                            .frame(width: 40, height: 40)
                        Image(systemName: "sparkles")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("AI Mechanic")
                                .font(RaahiTypography.headline)
                                .foregroundColor(.white)
                            
                            if let status = viewModel.aiStatus {
                                StatusBadge(
                                    text: status.available ? "Online" : "Busy",
                                    color: status.available ? Color.raahiGreen : Color.raahiYellow
                                )
                            }
                        }
                        
                        Text("Instant vehicle troubleshooting powered by Gemini")
                            .font(RaahiTypography.caption)
                            .foregroundColor(Color.raahiTextSecondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .background(Color.raahiSurface.opacity(0.8))
                
                // Active Vehicle Context Banner
                if let v = viewModel.activeVehicle {
                    HStack(spacing: 8) {
                        Image(systemName: "car.fill")
                            .foregroundColor(Color.raahiBlue)
                            .font(.system(size: 13))
                        Text("Context: \(v.brand) \(v.model) (\(v.fuelType))")
                            .font(RaahiTypography.captionBold)
                            .foregroundColor(Color.raahiTextSecondary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                    .background(Color.raahiCard.opacity(0.5))
                }
                
                // Chat Message List
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            // Quick Prompts if no conversation yet
                            if viewModel.messages.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("COMMON SYMPTOMS & QUESTIONS")
                                        .font(RaahiTypography.captionBold)
                                        .foregroundColor(Color.raahiOrange)
                                        .padding(.top, 12)
                                    
                                    ForEach(viewModel.quickPrompts, id: \.self) { prompt in
                                        Button(action: {
                                            viewModel.inputText = prompt
                                            Task { await viewModel.sendMessage() }
                                        }) {
                                            HStack {
                                                Image(systemName: "bolt.fill")
                                                    .foregroundColor(Color.raahiBlue)
                                                    .font(.system(size: 14))
                                                Text(prompt)
                                                    .font(RaahiTypography.body)
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.leading)
                                                Spacer()
                                                Image(systemName: "arrow.up.right")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Color.raahiTextMuted)
                                            }
                                            .padding(14)
                                            .background(Color.raahiCard)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.raahiBorder, lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // Messages
                            ForEach(viewModel.messages) { msg in
                                ChatBubbleView(message: msg)
                                    .id(msg.id)
                            }
                            
                            // Sending indicator
                            if viewModel.isSending {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.raahiBlue))
                                        .scaleEffect(0.8)
                                    Text("AI Mechanic is diagnosing...")
                                        .font(RaahiTypography.caption)
                                        .foregroundColor(Color.raahiTextSecondary)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                            }
                            
                            // Error Banner with Retry & Edit actions
                            if let error = viewModel.errorMessage {
                                GlassCard(cornerRadius: 14, padding: 14) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(Color.raahiRed)
                                            Text("AI Provider Notice")
                                                .font(RaahiTypography.bodyBold)
                                                .foregroundColor(.white)
                                        }
                                        
                                        Text(error)
                                            .font(RaahiTypography.caption)
                                            .foregroundColor(Color.raahiTextSecondary)
                                        
                                        HStack(spacing: 10) {
                                            Button(action: {
                                                Task { await viewModel.retryLastPrompt() }
                                            }) {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "arrow.clockwise")
                                                    Text("Retry")
                                                }
                                                .font(RaahiTypography.captionBold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 7)
                                                .background(Color.raahiOrange)
                                                .cornerRadius(8)
                                            }
                                            
                                            Button(action: {
                                                viewModel.editLastQuestion()
                                            }) {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "pencil")
                                                    Text("Edit Question")
                                                }
                                                .font(RaahiTypography.captionBold)
                                                .foregroundColor(Color.raahiTextSecondary)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 7)
                                                .background(Color.raahiSurface)
                                                .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Bottom Input Bar
                HStack(spacing: 10) {
                    TextField(
                        "",
                        text: $viewModel.inputText,
                        prompt: Text("Describe symptoms or abnormal sounds...").foregroundColor(Color.raahiTextMuted)
                    )
                    .foregroundColor(.white)
                    .font(RaahiTypography.body)
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(Color.raahiSurface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.raahiBorder, lineWidth: 1)
                    )
                    
                    Button(action: {
                        Task { await viewModel.sendMessage() }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 38))
                            .foregroundColor(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.raahiTextMuted : Color.raahiOrange)
                    }
                    .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isSending)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.raahiSurface)
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

// MARK: - Chat Bubble
private struct ChatBubbleView: View {
    let message: AiMessageDto
    
    var isUser: Bool {
        message.role.uppercased() == "USER"
    }
    
    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 40) }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(RaahiTypography.body)
                    .foregroundColor(.white)
                    .padding(14)
                    .background(isUser ? Color.raahiOrange : (message.unavailable ? Color.raahiRed.opacity(0.2) : Color.raahiCard))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(message.unavailable ? Color.raahiRed.opacity(0.4) : Color.raahiBorder, lineWidth: 1)
                    )
            }
            
            if !isUser { Spacer(minLength: 40) }
        }
        .padding(.horizontal, 20)
    }
}
