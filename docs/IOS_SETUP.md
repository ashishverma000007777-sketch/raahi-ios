# Raahi iOS — Setup & Build Guide

This guide walks you through setting up, configuring, and compiling the native **Raahi** iOS application on macOS using Xcode.

---

## 1. System Requirements

- **Operating System**: macOS Sonoma (14.0+) or macOS Sequoia (15.0+)
- **IDE**: Xcode 15.0 or Xcode 16.0+
- **Languages / SDKs**: Swift 5.9+, iOS 16.0+ SDK
- **Package Manager**: Swift Package Manager (SPM) built into Xcode

---

## 2. Clone the Repository

```bash
git clone https://github.com/ashishverma000007777-sketch/raahi-ios.git
cd raahi-ios
```

---

## 3. Firebase iOS Configuration

The app relies on Firebase for SMS Phone Authentication (matching project `raahi-a3194`).

1. Log into the [Firebase Console](https://console.firebase.google.com/).
2. Select the existing project: **`raahi-a3194`**.
3. Under **Project Settings**, add an **iOS App**:
   - **Bundle Identifier**: `in.raahi.ios` (or your registered bundle id)
   - **App Nickname**: `Raahi iOS`
4. Download the generated **`GoogleService-Info.plist`**.
5. Move this file into:
   ```
   RaahiIOS/Resources/GoogleService-Info.plist
   ```
   *(Note: This file is excluded from git via `.gitignore` to prevent secret exposure).*
6. In Xcode:
   - Ensure `GoogleService-Info.plist` is added to the **RaahiIOS** app target.
   - Under the target's **Info** tab, add the `REVERSED_CLIENT_ID` (from the plist) as an **URL Scheme** for Firebase Phone Auth callback routing.

---

## 4. Opening and Building in Xcode

### Option A: Using Xcode GUI
1. Launch Xcode:
   ```bash
   open RaahiIOS.xcodeproj
   ```
   *(Or open the folder containing `Package.swift`)*
2. Xcode will automatically resolve dependencies (Firebase iOS SDK).
3. Select an iOS 16+ Simulator (e.g., iPhone 15 Pro, iPhone 16) or a connected physical iPhone.
4. Press `Cmd + B` to build, or `Cmd + R` to run.

### Option B: Using Command Line (`xcodebuild`)
```bash
# Build for iOS Simulator
xcodebuild build \
  -project RaahiIOS.xcodeproj \
  -scheme RaahiIOS \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  CODE_SIGNING_ALLOWED=NO

# Run Unit Tests
xcodebuild test \
  -project RaahiIOS.xcodeproj \
  -scheme RaahiIOS \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  CODE_SIGNING_ALLOWED=NO
```

---

## 5. Capabilities & Permissions

The application includes the following privacy keys in `Info.plist`:
- `NSLocationWhenInUseUsageDescription`: Required to locate you for roadside assistance and nearby mechanics.
- `NSLocationAlwaysAndWhenInUseUsageDescription`: Required for helpers actively navigating to a roadside breakdown.
- `NSCameraUsageDescription`: Required for uploading vehicle documents and Aadhaar verification images.
- `NSPhotoLibraryUsageDescription`: Required to select verification photos from the gallery.

---

## 6. Testing

The project includes an extensive unit test suite in `Tests/RaahiIOSTests/`:
- **API Client & Decoding Tests**: Verifies all DTOs and envelope handling.
- **Job Lifecycle Tests**: Validates state transitions, OTP checks, and participant role gating.
- **WebSocket Event Tests**: Validates inbound push event parsing.
- **AI Mechanic Resilience Tests**: Validates that upstream AI errors are properly surfaced with retry actions.

Run tests directly in Xcode with `Cmd + U`.
