import SwiftUI

@main
public struct RaahiApp: App {
    @StateObject private var authManager = AuthManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    public init() {
        configureAppearance()
    }
    
    public var body: some Scene {
        WindowGroup {
            RootView(authManager: authManager)
                .preferredColorScheme(.dark)
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        if authManager.state.currentUser != nil {
                            RaahiWebSocketClient.shared.connect()
                        }
                    case .background:
                        break
                    default:
                        break
                    }
                }
        }
    }
    
    private func configureAppearance() {
        // Configure standard UIKit dark appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.raahiBackground)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
