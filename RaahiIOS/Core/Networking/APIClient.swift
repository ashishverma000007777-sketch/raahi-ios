import Foundation

public protocol APIClientProtocol {
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
    func uploadMultipart<T: Codable>(
        path: String,
        parts: [MultipartFormPart]
    ) async throws -> T
}

public struct MultipartFormPart {
    public let name: String
    public let filename: String?
    public let mimeType: String?
    public let data: Data
    
    public init(name: String, filename: String? = nil, mimeType: String? = nil, data: Data) {
        self.name = name
        self.filename = filename
        self.mimeType = mimeType
        self.data = data
    }
}

public final class APIClient: APIClientProtocol {
    public static let shared = APIClient()
    
    public var baseURL = URL(string: "https://raahi-fdw0.onrender.com/api/v1")!
    private let session: URLSession
    private let tokenStorage: TokenStorageProtocol
    private let decoder: JSONDecoder
    
    public static let sessionExpiredNotification = Notification.Name("raahi.api.sessionExpired")
    
    public init(
        session: URLSession = .shared,
        tokenStorage: TokenStorageProtocol = TokenStorage.shared
    ) {
        self.session = session
        self.tokenStorage = tokenStorage
        self.decoder = JSONDecoder()
    }
    
    public func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        var url = baseURL.appendingPathComponent(endpoint.path)
        
        if let queryItems = endpoint.queryItems, !queryItems.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            components?.queryItems = queryItems
            if let resolved = components?.url {
                url = resolved
            }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 30.0
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body = endpoint.body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // Add Bearer token if present
        if let token = tokenStorage.getToken(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let headers = endpoint.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            throw APIError.networkFailure(urlError.localizedDescription)
        } catch {
            throw APIError.networkFailure(error.localizedDescription)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Intercept 401 Unauthorized
        if httpResponse.statusCode == 401 {
            NotificationCenter.default.post(name: Self.sessionExpiredNotification, object: nil)
            throw APIError.unauthorized
        }
        
        // Parse the universal ApiEnvelope<T>
        let envelope: ApiEnvelope<T>
        do {
            envelope = try decoder.decode(ApiEnvelope<T>.self, from: data)
        } catch {
            // Attempt to decode error envelope even if T decoding failed
            if let errorEnvelope = try? decoder.decode(ApiEnvelope<DummyCodable>.self, from: data),
               let err = errorEnvelope.error {
                throw APIError.serverError(code: err.code, message: err.message)
            }
            throw APIError.decodingError("\(error.localizedDescription) (status: \(httpResponse.statusCode))")
        }
        
        if envelope.success, let responseData = envelope.data {
            return responseData
        } else if let error = envelope.error {
            throw APIError.serverError(code: error.code, message: error.message)
        } else if !envelope.success {
            throw APIError.serverError(code: "UNKNOWN_ERROR", message: "Request failed with unknown status.")
        } else {
            throw APIError.invalidResponse
        }
    }
    
    public func uploadMultipart<T: Codable>(
        path: String,
        parts: [MultipartFormPart]
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60.0
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = tokenStorage.getToken(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var bodyData = Data()
        for part in parts {
            bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
            if let filename = part.filename, let mimeType = part.mimeType {
                bodyData.append("Content-Disposition: form-data; name=\"\(part.name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
                bodyData.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            } else {
                bodyData.append("Content-Disposition: form-data; name=\"\(part.name)\"\r\n\r\n".data(using: .utf8)!)
            }
            bodyData.append(part.data)
            bodyData.append("\r\n".data(using: .utf8)!)
        }
        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = bodyData
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            NotificationCenter.default.post(name: Self.sessionExpiredNotification, object: nil)
            throw APIError.unauthorized
        }
        
        let envelope = try decoder.decode(ApiEnvelope<T>.self, from: data)
        if envelope.success, let responseData = envelope.data {
            return responseData
        } else if let error = envelope.error {
            throw APIError.serverError(code: error.code, message: error.message)
        } else {
            throw APIError.invalidResponse
        }
    }
}

private struct DummyCodable: Codable {}
