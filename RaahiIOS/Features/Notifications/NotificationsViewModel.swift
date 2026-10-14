import Foundation

@MainActor
public final class NotificationsViewModel: ObservableObject {
    @Published public var notifications: [NotificationDto] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let apiClient: APIClientProtocol
    
    public init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    public func loadNotifications() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched: [NotificationDto] = try await apiClient.request(.notifications)
            self.notifications = fetched
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func markAllRead() async {
        do {
            _ = try await apiClient.request(.markAllNotificationsRead) as [String: Int]
            await loadNotifications()
        } catch {
            // Ignore error
        }
    }
}
