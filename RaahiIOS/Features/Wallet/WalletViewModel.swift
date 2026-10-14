import Foundation

@MainActor
public final class WalletViewModel: ObservableObject {
    @Published public var savings: SavingsSummaryDto? = nil
    @Published public var fuelRates: [FuelRateDto] = []
    @Published public var subscriptionPlans: [SubscriptionPlanDto] = []
    @Published public var mySubscription: SubscriptionStatusDto? = nil
    @Published public var shopProducts: [ShopProductDto] = []
    
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var isSubscribing: Bool = false
    @Published public var subscribeMessage: String? = nil
    
    private let apiClient: APIClientProtocol
    
    public init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    public func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let sFetch: SavingsSummaryDto = apiClient.request(.savings)
            async let fFetch: [FuelRateDto] = apiClient.request(.fuelRates)
            async let pFetch: [SubscriptionPlanDto] = apiClient.request(.subscriptionPlans)
            async let subFetch: SubscriptionStatusDto = apiClient.request(.mySubscription)
            async let shFetch: [ShopProductDto] = apiClient.request(.shopProducts())
            
            let (s, f, p, sub, sh) = try await (sFetch, fFetch, pFetch, subFetch, shFetch)
            self.savings = s
            self.fuelRates = f
            self.subscriptionPlans = p
            self.mySubscription = sub
            self.shopProducts = sh
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func subscribe(to tier: String) async {
        isSubscribing = true
        subscribeMessage = nil
        
        do {
            _ = try await apiClient.request(.subscribe(tier: tier)) as [String: AnyCodable]
            self.isSubscribing = false
            self.subscribeMessage = "Subscription tier upgraded successfully."
        } catch {
            self.isSubscribing = false
            // The backend returns 503 PAYMENT_UNAVAILABLE in the MVP
            self.subscribeMessage = error.localizedDescription
        }
    }
}
