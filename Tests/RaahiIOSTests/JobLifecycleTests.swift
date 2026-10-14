import XCTest
@testable import RaahiIOS

final class JobLifecycleTests: XCTestCase {
    
    func testCancellationRule() {
        // Pending state: cancellation allowed
        let pendingJob = JobDto(
            id: "j-1",
            status: "PENDING",
            problemType: "FLAT_TYRE",
            lat: 19.0,
            lng: 72.0,
            cancelAllowed: true
        )
        let vmPending = JobDetailStatusViewModel(job: pendingJob)
        XCTAssertTrue(vmPending.canCancel)
        
        // Matched state: cancellation allowed
        let matchedJob = JobDto(
            id: "j-2",
            status: "MATCHED",
            problemType: "FLAT_TYRE",
            lat: 19.0,
            lng: 72.0,
            cancelAllowed: true
        )
        let vmMatched = JobDetailStatusViewModel(job: matchedJob)
        XCTAssertTrue(vmMatched.canCancel)
        
        // Arrived state: cancellation forbidden per backend contract (HTTP 409 CANCEL_NOT_ALLOWED)
        let arrivedJob = JobDto(
            id: "j-3",
            status: "ARRIVED",
            problemType: "FLAT_TYRE",
            lat: 19.0,
            lng: 72.0,
            cancelAllowed: false
        )
        let vmArrived = JobDetailStatusViewModel(job: arrivedJob)
        XCTAssertFalse(vmArrived.canCancel)
        
        // In Progress: cancellation forbidden
        let inProgressJob = JobDto(
            id: "j-4",
            status: "IN_PROGRESS",
            problemType: "FLAT_TYRE",
            lat: 19.0,
            lng: 72.0,
            cancelAllowed: false
        )
        let vmProgress = JobDetailStatusViewModel(job: inProgressJob)
        XCTAssertFalse(vmProgress.canCancel)
    }
    
    func testViewerRoleGating() {
        let requesterJob = JobDto(
            id: "j-10",
            status: "MATCHED",
            problemType: "BATTERY_DEAD",
            lat: 19.0,
            lng: 72.0,
            helperOtp: "123456",
            viewerRole: "REQUESTER"
        )
        let vmRequester = JobDetailStatusViewModel(job: requesterJob)
        XCTAssertTrue(vmRequester.isRequester)
        XCTAssertFalse(vmRequester.isHelper)
        XCTAssertEqual(vmRequester.job.helperOtp, "123456")
        
        let helperJob = JobDto(
            id: "j-11",
            status: "MATCHED",
            problemType: "BATTERY_DEAD",
            lat: 19.0,
            lng: 72.0,
            helperOtp: nil, // Server never sends helperOtp to helper
            viewerRole: "HELPER"
        )
        let vmHelper = JobDetailStatusViewModel(job: helperJob)
        XCTAssertTrue(vmHelper.isHelper)
        XCTAssertFalse(vmHelper.isRequester)
        XCTAssertNil(vmHelper.job.helperOtp)
    }
    
    func testActiveJobClassification() {
        let activeStatuses = ["PENDING", "MATCHED", "ARRIVED", "IN_PROGRESS", "WORK_DONE"]
        for status in activeStatuses {
            let job = JobDto(id: "j", status: status, problemType: "TOWING", lat: 0, lng: 0)
            let vm = JobDetailStatusViewModel(job: job)
            XCTAssertTrue(vm.isJobActive, "Expected \(status) to be classified as active")
        }
        
        let terminalStatuses = ["COMPLETED", "CANCELLED", "EXPIRED"]
        for status in terminalStatuses {
            let job = JobDto(id: "j", status: status, problemType: "TOWING", lat: 0, lng: 0)
            let vm = JobDetailStatusViewModel(job: job)
            XCTAssertFalse(vm.isJobActive, "Expected \(status) to be classified as inactive/terminal")
        }
    }
}
