# Raahi iOS — Native Roadside Assistance & Vehicle Management

[![iOS Version](https://img.shields.io/badge/iOS-16.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift Version](https://img.shields.io/badge/Swift-5.9%2B-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI%20MVVM-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20MVVM-purple.svg)]()

Raahi is an on-demand, peer-to-peer roadside assistance marketplace, smart mechanic locator, and comprehensive vehicle health & garage management platform.

This repository hosts the **native iOS application**, built from the ground up using Swift and SwiftUI to deliver full feature parity with the existing Raahi Android app while leveraging Apple platform conventions (MapKit, CoreLocation, Keychain, SF Symbols, and Structured Concurrency).

---

## 🌟 Key Features

- **🔐 Native Authentication**: Firebase Phone SMS OTP authentication exchanged for a secure 30-day backend JWT stored in the iOS platform Keychain.
- **🚗 Smart Home Dashboard**: Live vehicle card, odometer tracker, Car Health score pill, AI Mechanic hero card, and quick action shortcuts.
- **🆘 24x7 Roadside Assistance**:
  - Request help with specific breakdown categories (flat tyres, battery jumpstarts, towing, lockout, overheating).
  - Cash offer chips paid directly to helpers (0% platform cut for drivers).
  - CoreLocation GPS positioning.
  - Multi-step job lifecycle (`PENDING` ➔ `MATCHED` ➔ `ARRIVED` ➔ `IN_PROGRESS` ➔ `WORK_DONE` ➔ `COMPLETED`).
  - Secure in-person OTP handoff validation.
  - Live helper tracking on MapKit.
  - One-tap phone dialer and cancellation support.
- **🗺️ Interactive Mechanics Map**: Real-time nearby verified mechanics query via MapKit with availability badges (green/amber), specialization filters, and Apple Maps turn-by-turn navigation.
- **🛠️ Helper & Mechanic Portal**:
  - Driver-to-helper onboarding with Aadhaar and selfie document uploads.
  - Online/offline availability switch with location synchronization.
  - Real-time incoming job alerts over WebSocket.
  - Earnings overview and commission ledger.
- **🤖 AI Mechanic Diagnostics**: Context-aware troubleshooting powered by Gemini AI with vehicle context injection, symptom chips, and resilient error recovery with question preservation.
- **🚨 SOS Emergency Network**: Instant SOS broadcast alerting nearby verified mechanics and helpers, combined with local emergency contact SMS alerts with current GPS coordinates.
- **🏎️ My Garage & Car Health**: Track odometer readings, maintenance intervals (oil, tyres, battery, insurance, PUC), service history records, and fuel fill-up logs.
- **💰 Paisa Bachao & Daily Engagement**: State fuel rate radar (petrol, diesel, CNG), community highway alerts with upvoting, rotating driving tips, and gamified safety streaks.

---

## 🏗️ Architecture & Directory Structure

The project follows a modular, clean **MVVM (Model-View-ViewModel)** architecture:

```
RaahiIOS/
├── App/                     # Application lifecycle, state coordinator & root navigation
│   ├── RaahiApp.swift
│   ├── AppState.swift
│   └── RootView.swift
├── Core/                    # Foundation infrastructure
│   ├── Authentication/      # Auth state manager, session management
│   ├── DesignSystem/        # Color palette, glass cards, custom typography & components
│   ├── Location/            # CoreLocation async manager
│   ├── Networking/          # URLSession HTTP client, endpoint definitions, envelope parser
│   ├── Storage/             # Platform Keychain wrapper & local persistence
│   └── WebSocket/           # URLSessionWebSocketTask client with reconnect logic
├── Features/                # Feature-driven UI and ViewModels
│   ├── Auth/                # Phone number login & OTP verification
│   ├── Home/                # Home dashboard, stats strip, vehicle card
│   ├── RoadsideHelp/        # Request help form & problem selection
│   ├── Jobs/                # My jobs list, live tracking & job lifecycle transitions
│   ├── MechanicsMap/        # MapKit map, mechanics list, detail sheet
│   ├── Helper/              # Helper portal, application form, job alerts
│   ├── AIMechanic/          # AI chat interface, diagnosis & error states
│   ├── SOS/                 # SOS trigger, emergency contacts & SMS dispatcher
│   ├── Profile/             # Profile setup, Car Health score, vehicle & service history
│   ├── Wallet/              # Fuel rates radar, Paisa Bachao, shop catalog, subscriptions
│   └── Notifications/       # In-app notifications inbox
├── Models/                  # Decodable DTOs matching backend REST & WS contracts
└── Resources/               # Assets, Info.plist, entitlements
```

---

## 🚀 Getting Started

### Prerequisites
- macOS Sonoma 14.0+ or Sequoia 15.0+
- Xcode 15.0+ or 16.0+
- iOS 16.0+ deployment target

### Quick Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/ashishverma000007777-sketch/raahi-ios.git
   cd raahi-ios
   ```
2. Open in Xcode:
   ```bash
   open RaahiIOS.xcodeproj
   ```
3. Add your `GoogleService-Info.plist` from Firebase project `raahi-a3194` into `RaahiIOS/Resources/`.
4. Select an iPhone 15 or 16 Simulator and press **Cmd + R** to run.

For full setup and configuration details, read the [iOS Setup Guide](docs/IOS_SETUP.md).

---

## 🔌 Backend Integration

Raahi iOS connects to the production Spring Boot backend:
- **Base API**: `https://raahi-fdw0.onrender.com/api/v1`
- **WebSocket**: `wss://raahi-fdw0.onrender.com/ws`

Read the [Backend API Compatibility Guide](docs/API_COMPATIBILITY.md) and [Feature Parity Matrix](docs/IOS_PARITY_MATRIX.md) for full endpoint specifications.

---

## 🧪 Testing

Unit tests are written using Apple's **XCTest** framework in `Tests/RaahiIOSTests/`:
- DTO serialization and envelope decoding
- Authentication session restoration & 401 handling
- Job lifecycle state machine transitions & OTP checks
- AI Mechanic failure recovery and prompt preservation
- WebSocket event dispatching

Run the test suite in Xcode via **Cmd + U** or via CLI:
```bash
xcodebuild test -project RaahiIOS.xcodeproj -scheme RaahiIOS -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' CODE_SIGNING_ALLOWED=NO
```

---

## 📄 License
Proprietary & Confidential. Copyright © 2026 Raahi. All rights reserved.
