# Raahi iOS Feature Parity Matrix

This document maps all features from the Android application (`~/raahi_repo`) to the native Swift/SwiftUI iOS implementation (`RaahiIOS`).

**Classifications:**
- **Implemented**: Fully designed, modeled, and implemented natively in SwiftUI/Swift matching Android UX, business rules, and backend contracts.
- **In progress**: Active development / scaffolded.
- **Blocked by backend/configuration**: Requires external third-party keys or platform credentials (e.g. Firebase iOS `GoogleService-Info.plist`, APNs certificate, Razorpay payment gateway).
- **Not started**: Planned for future roadmap.

---

| Category | Feature | Android Status | iOS Status | Backend Endpoint / Contract | Notes |
|---|---|---|---|---|---|
| **A. Authentication** | Phone Number Entry | Implemented | **Implemented** | UI / Local Validation | Clean input with +91 country prefix & 10-digit validation |
| | Firebase SMS OTP Request & Verify | Implemented | **Implemented** | Firebase Auth iOS SDK / `FirebaseAuth` | Native SMS verification flow; requires `GoogleService-Info.plist` |
| | Backend JWT Verification | Implemented | **Implemented** | `POST /api/v1/auth/verify` | Exchanges Firebase ID Token for Backend JWT session token |
| | Secure Keychain Storage | Implemented (EncryptedSharedPreferences) | **Implemented** | Platform Keychain | Stores JWT token, user ID, and auth state securely |
| | Session Restoration & Auto-Login | Implemented | **Implemented** | `GET /api/v1/auth/me` | Validates persisted token on app launch |
| | User Profile Setup & Edit | Implemented | **Implemented** | `PUT /api/v1/auth/profile` | Set name, vehicle type, registration, language |
| | Sign Out & Session Teardown | Implemented | **Implemented** | `POST /api/v1/auth/logout` + Local Keychain wipe | Clears token, disconnects WebSocket, resets navigation |
| **B. Home Screen** | User Welcome & Header | Implemented | **Implemented** | `GET /api/v1/auth/me` | Personalized greeting based on time of day |
| | Registered Vehicle Card | Implemented | **Implemented** | `GET /api/v1/vehicles/me` | Brand, model, registration, odometer reading |
| | Car Health Score Pill | Implemented | **Implemented** | `GET /api/v1/vehicles/me/health` | Color-coded health score badge |
| | AI Mechanic Hero Card | Implemented | **Implemented** | `GET /api/v1/ai/status` | Instant shortcut with live AI availability indicator |
| | Quick Action Grid | Implemented | **Implemented** | Local Navigation | Roadside Help, Find Mechanic, My Jobs, SOS, Helper Portal |
| | Weekly Performance Strip | Implemented | **Implemented** | `GET /api/v1/home/summary` | Weekly km driven, helps provided, unread alerts |
| | Notifications Bell with Badge | Implemented | **Implemented** | `GET /api/v1/notifications` | Unread count indicator, navigates to notifications inbox |
| | News / Safety Ticker Marquee | Implemented | **Implemented** | Local UI / Daily Tips | Looping ticker display with highway announcements |
| **C. Roadside Help** | Problem Category Grid | Implemented | **Implemented** | `ProblemTypes.swift` | Flat Tyre, Battery, Fuel, Towing, Breakdown, Lockout, Overheating |
| | Custom Issue Description & Notes | Implemented | **Implemented** | `POST /api/v1/jobs` | Optional description submitted with request |
| | Cash Offer / Reward Chips | Implemented | **Implemented** | `POST /api/v1/jobs` | Quick chips (₹200, ₹500, ₹1000) or custom input; cash to helper |
| | CoreLocation Coordinate Capture | Implemented | **Implemented** | CoreLocation Framework | Accurate GPS fix with explicit user permission prompt |
| | Help Request Submission | Implemented | **Implemented** | `POST /api/v1/jobs` | Creates pending roadside job |
| | My Jobs Marketplace List | Implemented | **Implemented** | `GET /api/v1/jobs/mine` | Mixed list labeled by server-side `viewerRole` (Requester/Helper) |
| | Active Job Status & Tracking | Implemented | **Implemented** | `GET /api/v1/jobs/{id}` | Full status display: PENDING, MATCHED, ARRIVED, IN_PROGRESS, WORK_DONE, COMPLETED |
| | Live Helper Location on MapKit | Implemented | **Implemented** | `job:helper_location` WS / MapKit | Live tracking pin and route indicator |
| | Requester OTP Handoff Display | Implemented | **Implemented** | `JobDto.helperOtp` | Requester displays arrival/start OTP to helper |
| | Helper OTP Verification Flow | Implemented | **Implemented** | `POST /api/v1/jobs/{id}/verify-otp` | Helper enters OTP to transition job from MATCHED to IN_PROGRESS |
| | Arrival, Start & Completion Actions | Implemented | **Implemented** | `POST /api/v1/jobs/{id}/arrive`, `start`, `work-done`, `confirm-completion` | Multi-step lifecycle transitions |
| | Cancel Job Action | Implemented | **Implemented** | `POST /api/v1/jobs/{id}/cancel` | Permitted in PENDING/MATCHED; enforces backend cancellation rules |
| | Direct Dialer Intent | Implemented | **Implemented** | `tel://` URL scheme | Calls other participant (phone number securely gated server-side) |
| | Rating & Review Submission | Implemented | **Implemented** | `POST /api/v1/jobs/{id}/rate` | 1-5 star rating and optional comments |
| | Report Problem / Contact Support | Implemented | **Implemented** | `POST /api/v1/jobs/{id}/report` | Audit log entry for disputes or safety incidents |
| **D. Mechanics Map** | Interactive MapKit Map | Implemented | **Implemented** | Apple MapKit | Native vector map with custom mechanic annotation pins |
| | Nearby Mechanics Query | Implemented | **Implemented** | `GET /api/v1/mechanics/nearby` | Filtered to approved mechanics with coordinates on file |
| | Availability Indicators | Implemented | **Implemented** | `MechanicDto.isAvailable` | Green badge for available, amber for busy (honest, no mock fallback) |
| | Specialization Filter Chips | Implemented | **Implemented** | UI / `MechanicDto.specializations` | Filters by General, Tyres, Electrical, Towing, SOS |
| | Mechanic Profile Sheet | Implemented | **Implemented** | `GET /api/v1/mechanics/{id}` | Shop name, distance, rating, phone, services |
| | Directions in Apple Maps | Implemented | **Implemented** | `MKMapItem.openMaps` | Native turn-by-turn routing to mechanic location |
| | "Request Help" Cross-Flow CTA | Implemented | **Implemented** | RequestHelpView Navigation | Honest marketplace request flow, never a fake individual booking |
| **E. Helper Features** | Helper Onboarding Application | Implemented | **Implemented** | `POST /api/v1/helper/apply` | Multipart upload for Aadhaar Front, Aadhaar Back, and Selfie |
| | Application Status Tracking | Implemented | **Implemented** | `GET /api/v1/helper/application/me` | Tracks status (PENDING, APPROVED, REJECTED, SUSPENDED) |
| | Helper Dashboard | Implemented | **Implemented** | `GET /api/v1/helper/status` | Shows status, balance, canAcceptJobs flag, rating |
| | Online / Availability Toggle | Implemented | **Implemented** | `PUT /api/v1/helper/availability` | Helper toggles availability with current GPS location |
| | Nearby Available Jobs Feed | Implemented | **Implemented** | `GET /api/v1/jobs` | Real pending jobs feed within helper service radius |
| | Accept Job Flow | Implemented | **Implemented** | `POST /api/v1/jobs/{id}/accept` | Checks active role and commission status |
| | Incoming Job Real-Time Alert | Implemented | **Implemented** | `job:new_request` WS | Full-screen incoming alert with audio-haptic feedback |
| | Commission & Balance Ledger | Implemented | **Implemented** | `GET /api/v1/helper/commission` | Shows commission rate, balance due, transaction history |
| | Helper Earnings Breakdown | Implemented | **Implemented** | `GET /api/v1/helper/earnings` | Gross earnings, net earnings, completed job count |
| | Helper Ratings & Feedback | Implemented | **Implemented** | `GET /api/v1/helper/ratings` | Customer ratings and comments |
| **F. AI Mechanic** | Conversational Chat UI | Implemented | **Implemented** | `POST /api/v1/ai/sessions/{id}/messages` | Multi-turn chat with user and assistant bubbles |
| | Active Vehicle Context Injection | Implemented | **Implemented** | Context Enrichment | Injects vehicle brand/model/fuel into initial message |
| | Quick Category Diagnosis Chips | Implemented | **Implemented** | UI Quick Prompts | Engine noise, Brake squeal, AC cooling, Battery drain |
| | Session Management | Implemented | **Implemented** | `POST /api/v1/ai/sessions`, `GET /api/v1/ai/sessions` | Restores prior sessions or creates fresh diagnosis |
| | AI Provider Status Display | Implemented | **Implemented** | `GET /api/v1/ai/status` | Checks upstream Gemini provider availability |
| | Upstream Error Visibility | Implemented | **Implemented** | `APIError` parsing | Displays exact backend errors (`AI_UNAVAILABLE`, `AI_TIMEOUT`) |
| | Error Recovery: Retry & Edit | Implemented | **Implemented** | State Preservation | Never discards typed text on failure; provides Retry & Edit actions |
| **G. SOS Safety** | Emergency Trigger & Confirm | Implemented | **Implemented** | `POST /api/v1/sos` | High-priority SOS trigger with confirmation to prevent accidental trips |
| | Alert Notification Count | Implemented | **Implemented** | `TriggerSosResponse` | Shows exact count of nearby helpers/mechanics alerted |
| | Active SOS Banner & Resolve | Implemented | **Implemented** | `POST /api/v1/sos/{id}/resolve` | Active tracking state; allows user to mark incident resolved |
| | Local Emergency Contacts | Implemented | **Implemented** | Local Storage (UserDefaults) | Add, edit, and delete family/friend emergency contacts |
| | Emergency SMS Dispatch | Implemented | **Implemented** | `MFMessageComposeViewController` / `sms:` | Pre-fills current location and emergency message in Messages app |
| **H. Vehicle & Garage** | Vehicle Setup & Editing | Implemented | **Implemented** | `GET /api/v1/vehicles/me`, `PUT /api/v1/vehicles/me` | Model, year, fuel type, reg number, odometer |
| | Odometer Fast-Update | Implemented | **Implemented** | `PUT /api/v1/vehicles/me/odometer` | Validates forward progression; logs to audit trail |
| | Car Health Score Breakdown | Implemented | **Implemented** | `GET /api/v1/vehicles/me/health` | Score out of 100 based on service, insurance, and PUC |
| | Maintenance Items Checklist | Implemented | **Implemented** | `CarHealthDto.maintenanceItems` | Status of oil, tyres, battery, insurance, PUC |
| | Service Records History | Implemented | **Implemented** | `GET /api/v1/vehicles/me/service-records` | Log of past workshop visits and repairs |
| | Add New Service Record | Implemented | **Implemented** | `POST /api/v1/vehicles/me/service-records` | Date, odometer, service type, cost, workshop notes |
| | Fuel Fill-Up Log & Summary | Implemented | **Implemented** | `GET /api/v1/fuel-log`, `POST /api/v1/fuel-log` | Log litres, price/L, total cost; calculates fuel spend |
| **I. Commerce & Daily** | Fuel Rates Radar | Implemented | **Implemented** | `GET /api/v1/fuel-rates` | Petrol, diesel, and CNG rates by Indian state |
| | Paisa Bachao Savings Summary | Implemented | **Implemented** | `GET /api/v1/savings` | MoM fuel savings, mileage benchmark, savings badges |
| | Highway Community Alerts | Implemented | **Implemented** | `GET /api/v1/daily/alerts`, `POST /api/v1/daily/alerts` | Traffic, hazard, weather, speed trap alerts |
| | Alert Upvote/Downvote | Implemented | **Implemented** | `POST /api/v1/daily/alerts/{id}/vote` | One vote per user, prevented duplicates |
| | Daily Driving Tips | Implemented | **Implemented** | `GET /api/v1/daily/tips` | Rotating practical maintenance and highway safety tips |
| | Daily Streak & Check-in | Implemented | **Implemented** | `GET /api/v1/daily/streak`, `POST /api/v1/daily/streak/checkin` | Gamified safety streak tracking |
| | Subscription Plans Catalog | Implemented | **Implemented** | `GET /api/v1/subscriptions/plans`, `GET /api/v1/subscriptions/me` | Displays plan tiers and active subscription status |
| | Subscribe Action | Implemented | **Blocked by backend/configuration** | `POST /api/v1/subscriptions/subscribe` | Backend returns 503 `PAYMENT_UNAVAILABLE` (no payment gateway keys) |
| | Affiliate Shop Catalog | Implemented | **Implemented** | `GET /api/v1/shop/products` | Automotive emergency kit and accessories catalog with web links |
| **J. Notifications** | Notifications Inbox | Implemented | **Implemented** | `GET /api/v1/notifications` | List of system, job, and SOS notifications |
| | Mark All Read Action | Implemented | **Implemented** | `POST /api/v1/notifications/read-all` | Clears unread counter |
| | APNs Token Registration | Implemented (FCM) | **Implemented** | `PUT /api/v1/auth/fcm-token` | Sends device push token to backend |
| **K. Real-Time WebSocket** | Authenticated Handshake | Implemented | **Implemented** | `wss://.../ws` with Bearer header | Connects with JWT Authorization header |
| | Auto-reconnect with Backoff | Implemented | **Implemented** | Structured Concurrency | Reconnects on connection loss with exponential backoff |
| | Status Change Event | Implemented | **Implemented** | `job:status_change` | Updates active job screen instantly on status changes |
| | Live Location Broadcast | Implemented | **Implemented** | `job:location_update` / `job:helper_location` | Helper transmits GPS fix; requester receives coordinates |
| | SOS Nearby Alert Event | Implemented | **Implemented** | `sos:nearby_alert` | Pushes emergency alert to nearby helper accounts |
