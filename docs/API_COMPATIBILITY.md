# Raahi iOS — Backend & API Compatibility Guide

This document defines the contract and runtime compatibility between the native iOS application and the existing Raahi production backend.

## 1. Production Backend Coordinates

- **Base URL**: `https://raahi-fdw0.onrender.com`
- **REST API Base**: `https://raahi-fdw0.onrender.com/api/v1`
- **WebSocket URL**: `wss://raahi-fdw0.onrender.com/ws`
- **Environment**: Cloud Spring Boot service with PostgreSQL and Flyway database migrations.

---

## 2. Universal Response Envelope

All REST endpoints strictly adhere to a unified response envelope:

### Success Response (HTTP 200/201)
```json
{
  "success": true,
  "data": { ... },
  "error": null
}
```

### Error Response (HTTP 4xx/5xx)
```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "ERROR_CODE_STRING",
    "message": "Human readable description of the error."
  }
}
```

In the iOS app, `APIClient` decodes this directly via the generic `ApiEnvelope<T>` type:
```swift
public struct ApiEnvelope<T: Codable>: Codable {
    public let success: Bool
    public let data: T?
    public let error: ApiErrorBody?
}

public struct ApiErrorBody: Codable, LocalizedError {
    public let code: String
    public let message: String
    
    public var errorDescription: String? { message }
}
```

---

## 3. Authentication & Token Lifecycle

1. **Identity Provider**: Firebase Authentication (Phone Number SMS OTP).
2. **Exchange**: Upon SMS verification, the client receives a Firebase `idToken`. This is submitted to:
   ```http
   POST /api/v1/auth/verify
   Content-Type: application/json

   {
     "idToken": "<Firebase-ID-Token>",
     "requestedRole": "DRIVER"
   }
   ```
3. **Session Token**: The server returns a JWT valid for 30 days (`token`).
4. **Subsequent Calls**: All authenticated endpoints require:
   ```http
   Authorization: Bearer <JWT>
   ```
5. **Secure Storage**: Tokens are stored strictly in the iOS platform **Keychain** (`kSecClassGenericPassword`), never in `UserDefaults` or plaintext files.
6. **401 Handling**: When an HTTP 401 Unauthorized status is returned, the app invalidates the stored session and resets navigation to the Login screen.

---

## 4. WebSocket Protocol

The live tracking and job alert system connects via WebSocket:
- **Handshake URL**: `wss://raahi-fdw0.onrender.com/ws`
- **Handshake Header**: `Authorization: Bearer <JWT>`
- **Security Note**: Authentication tokens are passed via the standard HTTP handshake header, NEVER as query parameters (e.g. `?token=...` or `?userId=...`) to avoid logging tokens in access logs or caches.

### Inbound Server Events:
- `job:status_change`: `{ "event": "job:status_change", "data": { "jobId": "...", "status": "IN_PROGRESS" } }`
- `job:helper_location`: `{ "event": "job:helper_location", "data": { "jobId": "...", "lat": 19.076, "lng": 72.877 } }`
- `job:new_request`: `{ "event": "job:new_request", "data": { "id": "...", ... } }`
- `sos:nearby_alert`: `{ "event": "sos:nearby_alert", "data": { "sosId": "...", "lat": 19.076, "lng": 72.877 } }`

### Outbound Client Events:
- Helper location update:
  ```json
  {
    "event": "job:location_update",
    "data": {
      "jobId": "uuid",
      "lat": 19.0760,
      "lng": 72.8777
    }
  }
  ```

---

## 5. Specific Feature Behaviors & Error Handling

### A. AI Mechanic Upstream Failures
- The backend delegates queries to the Gemini AI API via `AiMechanicProvider`.
- If the upstream provider fails, times out, or quota is exceeded, the server returns an explicit error code:
  - `AI_TIMEOUT` (HTTP 504)
  - `AI_RATE_LIMIT` (HTTP 429)
  - `AI_CONFIG_ERROR` (HTTP 503)
  - `AI_UNAVAILABLE` (HTTP 503)
- **iOS Policy**: The UI does NOT mask this error or replace it with fake mock diagnoses. The exact message is displayed in an alert card with **"Retry"** and **"Edit Question"** buttons, and the user's typed prompt is retained in the text input.

### B. Payment & Subscription
- Calling `POST /api/v1/subscriptions/subscribe` triggers:
  ```json
  {
    "success": false,
    "error": {
      "code": "PAYMENT_UNAVAILABLE",
      "message": "Payment processing is currently unavailable. No payment gateway configured."
    }
  }
  ```
- The iOS client displays a friendly notification explaining that in-app subscriptions are undergoing gateway activation, without crashing.

### C. Helper Document Uploads
- `POST /api/v1/helper/apply` accepts multipart/form-data:
  - `aadhaarFront` (image/jpeg or image/png)
  - `aadhaarBack` (image/jpeg or image/png)
  - `selfie` (image/jpeg or image/png, optional)
  - String parts for `applicantName`, `applicantPhone`, `vehicleType`, `vehicleReg`, etc.
- Files are streamed as multipart chunks with explicit boundary formatting.
