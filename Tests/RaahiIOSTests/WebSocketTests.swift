import XCTest
@testable import RaahiIOS

final class WebSocketTests: XCTestCase {
    
    @MainActor
    func testParseJobStatusChangeEvent() {
        let client = RaahiWebSocketClient()
        let json = """
        {
            "event": "job:status_change",
            "data": {
                "jobId": "job-555",
                "status": "ARRIVED"
            }
        }
        """
        
        let event = client.parseEvent(text: json)
        guard case .jobStatusChange(let jobId, let status) = event else {
            XCTFail("Expected jobStatusChange event")
            return
        }
        
        XCTAssertEqual(jobId, "job-555")
        XCTAssertEqual(status, "ARRIVED")
    }
    
    @MainActor
    func testParseHelperLocationEvent() {
        let client = RaahiWebSocketClient()
        let json = """
        {
            "event": "job:helper_location",
            "data": {
                "jobId": "job-777",
                "lat": 19.1234,
                "lng": 72.5678
            }
        }
        """
        
        let event = client.parseEvent(text: json)
        guard case .jobHelperLocation(let jobId, let lat, let lng) = event else {
            XCTFail("Expected jobHelperLocation event")
            return
        }
        
        XCTAssertEqual(jobId, "job-777")
        XCTAssertEqual(lat, 19.1234, accuracy: 0.0001)
        XCTAssertEqual(lng, 72.5678, accuracy: 0.0001)
    }
    
    @MainActor
    func testParseSosNearbyAlertEvent() {
        let client = RaahiWebSocketClient()
        let json = """
        {
            "event": "sos:nearby_alert",
            "data": {
                "sosId": "sos-999",
                "lat": 19.0001,
                "lng": 72.0002
            }
        }
        """
        
        let event = client.parseEvent(text: json)
        guard case .sosNearbyAlert(let sosId, let lat, let lng) = event else {
            XCTFail("Expected sosNearbyAlert event")
            return
        }
        
        XCTAssertEqual(sosId, "sos-999")
        XCTAssertEqual(lat, 19.0001, accuracy: 0.0001)
        XCTAssertEqual(lng, 72.0002, accuracy: 0.0001)
    }
}
