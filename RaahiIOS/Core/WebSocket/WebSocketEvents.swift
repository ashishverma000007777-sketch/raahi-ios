import Foundation

public enum WsConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
}

public enum WsEvent: Equatable {
    case jobStatusChange(jobId: String, status: String)
    case jobHelperLocation(jobId: String, lat: Double, lng: Double)
    case sosNearbyAlert(sosId: String, lat: Double, lng: Double)
    case jobNewRequest(job: JobDto)
    case unknown(event: String, payload: String)
}

struct RawWsMessage: Codable {
    let event: String
    let data: [String: AnyCodable]?
}

// Helper for dynamic JSON dictionary decoding
public struct AnyCodable: Codable, Equatable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal.map { $0.value }
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal.mapValues { $0.value }
        } else {
            value = ""
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let boolVal = value as? Bool {
            try container.encode(boolVal)
        } else if let intVal = value as? Int {
            try container.encode(intVal)
        } else if let doubleVal = value as? Double {
            try container.encode(doubleVal)
        } else if let stringVal = value as? String {
            try container.encode(stringVal)
        }
    }
    
    public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        String(describing: lhs.value) == String(describing: rhs.value)
    }
}
