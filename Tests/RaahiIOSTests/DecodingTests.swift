import XCTest
@testable import RaahiIOS

final class DecodingTests: XCTestCase {
    
    func testDecodeUserSuccessEnvelope() throws {
        let json = """
        {
            "success": true,
            "data": {
                "id": "u-12345",
                "name": "Arjun Mehta",
                "phone": "+919876543210",
                "role": "DRIVER",
                "vehicleType": "Car",
                "vehicleReg": "MH01AB1234",
                "isVerified": true,
                "ratingAvg": 4.8,
                "totalHelps": 12,
                "email": "arjun@example.com",
                "emailVerified": true
            },
            "error": null
        }
        """.data(using: .utf8)!
        
        let envelope = try JSONDecoder().decode(ApiEnvelope<UserDto>.self, from: json)
        XCTAssertTrue(envelope.success)
        XCTAssertNotNil(envelope.data)
        XCTAssertEqual(envelope.data?.id, "u-12345")
        XCTAssertEqual(envelope.data?.name, "Arjun Mehta")
        XCTAssertEqual(envelope.data?.role, "DRIVER")
        XCTAssertTrue(envelope.data?.isVerified ?? false)
    }
    
    func testDecodeJobEnvelopeWithViewerRole() throws {
        let json = """
        {
            "success": true,
            "data": {
                "id": "job-789",
                "status": "MATCHED",
                "problemType": "FLAT_TYRE",
                "problemDesc": "Rear left tyre punctured on highway",
                "lat": 19.0760,
                "lng": 72.8777,
                "rewardAmount": 350.0,
                "helperOtp": "482910",
                "requesterName": "Vikram Singh",
                "requesterPhone": "+919811122233",
                "helperName": "Ramesh Mechanic",
                "helperPhone": "+919844455566",
                "helperRatingAvg": 4.9,
                "helperTotalHelps": 45,
                "helperVerified": true,
                "viewerRole": "REQUESTER",
                "cancelAllowed": true
            },
            "error": null
        }
        """.data(using: .utf8)!
        
        let envelope = try JSONDecoder().decode(ApiEnvelope<JobDto>.self, from: json)
        XCTAssertTrue(envelope.success)
        let job = try XCTUnwrap(envelope.data)
        XCTAssertEqual(job.id, "job-789")
        XCTAssertEqual(job.status, "MATCHED")
        XCTAssertEqual(job.viewerRole, "REQUESTER")
        XCTAssertEqual(job.helperOtp, "482910")
        XCTAssertEqual(job.rewardAmount, 350.0)
    }
    
    func testDecodeCarHealthWithDeterministicFactors() throws {
        let json = """
        {
            "success": true,
            "data": {
                "score": 85,
                "message": null,
                "factorsConsidered": 3,
                "factorsTotal": 3,
                "maintenanceItems": [
                    {
                        "type": "OIL_CHANGE",
                        "status": "OK",
                        "detail": "Changed 3,000 km ago",
                        "dueAtKm": 30000,
                        "dueAtDate": null
                    },
                    {
                        "type": "INSURANCE_RENEWAL",
                        "status": "DUE_SOON",
                        "detail": "Expires in 18 days",
                        "dueAtKm": null,
                        "dueAtDate": "2026-11-01"
                    }
                ],
                "grade": "GOOD",
                "careScore": 90,
                "efficiencyScore": 82,
                "safetyScore": 85
            },
            "error": null
        }
        """.data(using: .utf8)!
        
        let envelope = try JSONDecoder().decode(ApiEnvelope<CarHealthDto>.self, from: json)
        XCTAssertTrue(envelope.success)
        let health = try XCTUnwrap(envelope.data)
        XCTAssertEqual(health.score, 85)
        XCTAssertEqual(health.factorsConsidered, 3)
        XCTAssertEqual(health.maintenanceItems.count, 2)
        XCTAssertEqual(health.maintenanceItems[1].status, "DUE_SOON")
    }
    
    func testDecodeErrorEnvelope() throws {
        let json = """
        {
            "success": false,
            "data": null,
            "error": {
                "code": "AI_UNAVAILABLE",
                "message": "AI Mechanic is currently busy. Please try again in a few moments."
            }
        }
        """.data(using: .utf8)!
        
        let envelope = try JSONDecoder().decode(ApiEnvelope<AiMessageDto>.self, from: json)
        XCTAssertFalse(envelope.success)
        XCTAssertNil(envelope.data)
        XCTAssertNotNil(envelope.error)
        XCTAssertEqual(envelope.error?.code, "AI_UNAVAILABLE")
        XCTAssertEqual(envelope.error?.message, "AI Mechanic is currently busy. Please try again in a few moments.")
    }
}
