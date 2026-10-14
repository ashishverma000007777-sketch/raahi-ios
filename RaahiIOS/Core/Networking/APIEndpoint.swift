import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public struct APIEndpoint {
    public let path: String
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem]?
    public let body: Data?
    public let headers: [String: String]?
    
    public init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: [String: String]? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = body
        self.headers = headers
    }
}

// MARK: - Pre-configured Endpoints
extension APIEndpoint {
    // Auth
    public static func authVerify(req: VerifyRequest) -> APIEndpoint {
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "auth/verify", method: .post, body: data)
    }
    
    public static var authMe: APIEndpoint {
        APIEndpoint(path: "auth/me", method: .get)
    }
    
    public static func authUpdateProfile(req: UpdateProfileRequest) -> APIEndpoint {
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "auth/profile", method: .put, body: data)
    }
    
    public static func authFcmToken(token: String) -> APIEndpoint {
        let req = FcmTokenRequest(token: token)
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "auth/fcm-token", method: .put, body: data)
    }
    
    public static var authLogout: APIEndpoint {
        APIEndpoint(path: "auth/logout", method: .post)
    }
    
    // Jobs
    public static func createJob(req: CreateJobRequest) -> APIEndpoint {
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "jobs", method: .post, body: data)
    }
    
    public static func availableJobs(lat: Double? = nil, lng: Double? = nil) -> APIEndpoint {
        var items: [URLQueryItem] = []
        if let lat = lat { items.append(URLQueryItem(name: "lat", value: "\(lat)")) }
        if let lng = lng { items.append(URLQueryItem(name: "lng", value: "\(lng)")) }
        return APIEndpoint(path: "jobs", method: .get, queryItems: items.isEmpty ? nil : items)
    }
    
    public static var myJobs: APIEndpoint {
        APIEndpoint(path: "jobs/mine", method: .get)
    }
    
    public static func getJob(id: String) -> APIEndpoint {
        APIEndpoint(path: "jobs/\(id)", method: .get)
    }
    
    public static func acceptJob(id: String) -> APIEndpoint {
        APIEndpoint(path: "jobs/\(id)/accept", method: .post)
    }
    
    public static func arriveJob(id: String, req: ArriveRequest) -> APIEndpoint {
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "jobs/\(id)/arrive", method: .post, body: data)
    }
    
    public static func startJob(id: String) -> APIEndpoint {
        APIEndpoint(path: "jobs/\(id)/start", method: .post)
    }
    
    public static func workDone(id: String, req: WorkDoneRequest) -> APIEndpoint {
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "jobs/\(id)/work-done", method: .post, body: data)
    }
    
    public static func verifyJobOtp(id: String, otp: String) -> APIEndpoint {
        let req = VerifyOtpRequest(otp: otp)
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "jobs/\(id)/verify-otp", method: .post, body: data)
    }
    
    public static func confirmJobCompletion(id: String, otp: String) -> APIEndpoint {
        let req = VerifyOtpRequest(otp: otp)
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "jobs/\(id)/confirm-completion", method: .post, body: data)
    }
    
    public static func rateJob(id: String, req: RateRequest) -> APIEndpoint {
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "jobs/\(id)/rate", method: .post, body: data)
    }
    
    public static func cancelJob(id: String, reason: String?) -> APIEndpoint {
        let req = CancelRequest(reason: reason)
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "jobs/\(id)/cancel", method: .post, body: data)
    }
    
    public static func reportJob(id: String, req: ReportRequest) -> APIEndpoint {
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "jobs/\(id)/report", method: .post, body: data)
    }
    
    public static func updateJobLocation(id: String, lat: Double, lng: Double) -> APIEndpoint {
        let req = JobLocationUpdateRequest(lat: lat, lng: lng)
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "jobs/\(id)/location", method: .post, body: data)
    }
    
    // Mechanics
    public static func nearbyMechanics(lat: Double, lng: Double, radius: Double? = nil) -> APIEndpoint {
        var items = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lng", value: "\(lng)")
        ]
        if let radius = radius {
            items.append(URLQueryItem(name: "radius", value: "\(radius)"))
        }
        return APIEndpoint(path: "mechanics/nearby", method: .get, queryItems: items)
    }
    
    public static func getMechanic(id: String) -> APIEndpoint {
        APIEndpoint(path: "mechanics/\(id)", method: .get)
    }
    
    // SOS
    public static func triggerSos(lat: Double, lng: Double) -> APIEndpoint {
        let req = TriggerSosRequest(lat: lat, lng: lng)
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "sos", method: .post, body: data)
    }
    
    public static func activeSosNearby(lat: Double, lng: Double, radius: Double? = nil) -> APIEndpoint {
        var items = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lng", value: "\(lng)")
        ]
        if let radius = radius {
            items.append(URLQueryItem(name: "radius", value: "\(radius)"))
        }
        return APIEndpoint(path: "sos/active", method: .get, queryItems: items)
    }
    
    public static var mySosEvents: APIEndpoint {
        APIEndpoint(path: "sos/mine", method: .get)
    }
    
    public static func resolveSos(id: String) -> APIEndpoint {
        APIEndpoint(path: "sos/\(id)/resolve", method: .post)
    }
    
    // Helper Portal
    public static var helperStatus: APIEndpoint {
        APIEndpoint(path: "helper/status", method: .get)
    }
    
    public static func setHelperAvailability(online: Bool, lat: Double? = nil, lng: Double? = nil) -> APIEndpoint {
        let req = AvailabilityRequest(online: online, lat: lat, lng: lng)
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "helper/availability", method: .put, body: data)
    }
    
    public static var helperCommission: APIEndpoint {
        APIEndpoint(path: "helper/commission", method: .get)
    }
    
    public static var helperEarnings: APIEndpoint {
        APIEndpoint(path: "helper/earnings", method: .get)
    }
    
    public static var helperRatings: APIEndpoint {
        APIEndpoint(path: "helper/ratings", method: .get)
    }
    
    public static var helperJobHistory: APIEndpoint {
        APIEndpoint(path: "helper/jobs/history", method: .get)
    }
    
    public static var myHelperApplication: APIEndpoint {
        APIEndpoint(path: "helper/application/me", method: .get)
    }
    
    // AI Mechanic
    public static var aiStatus: APIEndpoint {
        APIEndpoint(path: "ai/status", method: .get)
    }
    
    public static var createAiSession: APIEndpoint {
        APIEndpoint(path: "ai/sessions", method: .post)
    }
    
    public static var myAiSessions: APIEndpoint {
        APIEndpoint(path: "ai/sessions", method: .get)
    }
    
    public static func aiSessionMessages(id: String) -> APIEndpoint {
        APIEndpoint(path: "ai/sessions/\(id)/messages", method: .get)
    }
    
    public static func sendAiMessage(sessionId: String, content: String) -> APIEndpoint {
        let req = SendAiMessageRequest(content: content)
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "ai/sessions/\(sessionId)/messages", method: .post, body: data)
    }
    
    // Vehicles & Health
    public static var myVehicle: APIEndpoint {
        APIEndpoint(path: "vehicles/me", method: .get)
    }
    
    public static func upsertVehicle(req: UpsertVehicleRequest) -> APIEndpoint {
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "vehicles/me", method: .put, body: data)
    }
    
    public static func updateOdometer(km: Int) -> APIEndpoint {
        let req = UpdateOdometerRequest(odometerKm: km)
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "vehicles/me/odometer", method: .put, body: data)
    }
    
    public static var carHealth: APIEndpoint {
        APIEndpoint(path: "vehicles/me/health", method: .get)
    }
    
    public static var serviceRecords: APIEndpoint {
        APIEndpoint(path: "vehicles/me/service-records", method: .get)
    }
    
    public static func addServiceRecord(req: CreateServiceRecordRequest) -> APIEndpoint {
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "vehicles/me/service-records", method: .post, body: data)
    }
    
    // Home & Daily
    public static var homeSummary: APIEndpoint {
        APIEndpoint(path: "home/summary", method: .get)
    }
    
    public static var fuelSummary: APIEndpoint {
        APIEndpoint(path: "fuel-log/summary", method: .get)
    }
    
    public static func addFuelLog(req: CreateFuelLogRequest) -> APIEndpoint {
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "fuel-log", method: .post, body: data)
    }
    
    public static var fuelLogs: APIEndpoint {
        APIEndpoint(path: "fuel-log", method: .get)
    }
    
    public static var fuelRates: APIEndpoint {
        APIEndpoint(path: "fuel-rates", method: .get)
    }
    
    public static func shopProducts(category: String? = nil) -> APIEndpoint {
        var items: [URLQueryItem]? = nil
        if let category = category {
            items = [URLQueryItem(name: "category", value: category)]
        }
        return APIEndpoint(path: "shop/products", method: .get, queryItems: items)
    }
    
    public static var subscriptionPlans: APIEndpoint {
        APIEndpoint(path: "subscriptions/plans", method: .get)
    }
    
    public static var mySubscription: APIEndpoint {
        APIEndpoint(path: "subscriptions/me", method: .get)
    }
    
    public static func subscribe(tier: String) -> APIEndpoint {
        let items = [URLQueryItem(name: "tier", value: tier)]
        return APIEndpoint(path: "subscriptions/subscribe", method: .post, queryItems: items)
    }
    
    public static var streak: APIEndpoint {
        APIEndpoint(path: "daily/streak", method: .get)
    }
    
    public static var checkinStreak: APIEndpoint {
        APIEndpoint(path: "daily/streak/checkin", method: .post)
    }
    
    public static func alerts(type: String? = nil) -> APIEndpoint {
        var items: [URLQueryItem]? = nil
        if let type = type {
            items = [URLQueryItem(name: "type", value: type)]
        }
        return APIEndpoint(path: "daily/alerts", method: .get, queryItems: items)
    }
    
    public static func createAlert(req: CreateAlertRequest) -> APIEndpoint {
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "daily/alerts", method: .post, body: data)
    }
    
    public static func voteAlert(id: String, vote: String) -> APIEndpoint {
        let req = VoteRequest(vote: vote)
        let data = try? JSONEncoder().encode(req)
        return APIEndpoint(path: "daily/alerts/\(id)/vote", method: .post, body: data)
    }
    
    public static var dailyTips: APIEndpoint {
        APIEndpoint(path: "daily/tips", method: .get)
    }
    
    public static var notifications: APIEndpoint {
        APIEndpoint(path: "notifications", method: .get)
    }
    
    public static var markAllNotificationsRead: APIEndpoint {
        APIEndpoint(path: "notifications/read-all", method: .post)
    }
    
    public static var savings: APIEndpoint {
        APIEndpoint(path: "savings", method: .get)
    }
}
