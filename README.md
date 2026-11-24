# Barrio de Fantasía (iOS Native)

<p align="center">
  <img src="BarrioFantasia/Assets.xcassets/AppIcon.appiconset/AppIcon.png" width="128" height="128" alt="Barrio Fantasia App Icon" style="border-radius: 28px; box-shadow: 0 10px 25px rgba(0,0,0,0.3);" />
</p>

<p align="center">
  <strong>Native iOS application for neighborhood soccer leagues, match call-ups, 24-hour peer ratings, interactive 2D pitch formations, and Fantasy management.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17.0%2B-blue.svg?style=for-the-badge&logo=apple" alt="iOS 17.0+" />
  <img src="https://img.shields.io/badge/Swift-6.0-F05138.svg?style=for-the-badge&logo=swift&logoColor=white" alt="Swift 6.0" />
  <img src="https://img.shields.io/badge/Swift_Testing-Passed-success.svg?style=for-the-badge&logo=apple" alt="Swift Testing" />
  <a href="https://github.com/Wacko87/barrio-fantasia-ios/actions"><img src="https://img.shields.io/github/actions/workflow/status/Wacko87/barrio-fantasia-ios/ci.yml?branch=main&label=CI&style=for-the-badge&logo=githubactions&logoColor=white" alt="CI Status" /></a>
  <img src="https://img.shields.io/badge/App_Store-Ready-green.svg?style=for-the-badge&logo=appstore" alt="App Store Ready" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-lightgrey.svg?style=for-the-badge" alt="License MIT" /></a>
</p>

---

## ⚽ Highlights

- **Bilingual Internationalization (String Catalogs)**: Automatically presents the UI in **Spanish** for Spanish-speaking devices and seamlessly falls back to **English** for any other device language worldwide.
- **24-Hour Peer Rating System**: Fair-play matchday ratings (1.0 to 10.0 scale) and unanimous MVP election. Includes preventive local notifications 2 hours prior to deadline to avoid -2 pts Fantasy penalties.
- **2D Interactive Tactical Pitch (`SoccerPitchView`)**: Geometric lawn pitch rendered with turf cut stripes, boundary markings, and dynamic player nodes positioned by tactical role (GK, DEF, MID, FWD) with haptic feedback.
- **Performance Analytics (Swift Charts)**: Catmull-Rom historical rating curves with reference `RuleMark` lines indicating career average ratings.
- **Official Match Report PDF Export (`MatchReportPDFService`)**: A4 formatted editorial match sheets with lineups, scoreboard, and ratings table generated natively with `PDFKit` and shareable via `ShareLink`.
- **Zero-Friction Onboarding & Social Sign-In**:
  - **Sign in with Apple** (`AuthenticationServices`): Instant 1-tap sign-in with Face ID.
  - **Google Sign-In**: Clean web-authenticated OAuth session (`ASWebAuthenticationSession`) without heavy third-party SDK bloat.
  - **Squad QR Invites & Short Codes**: Quick 6-character squad join code (e.g. `BF-87X9`) and high-resolution QR code generator (`CIQRCodeGenerator`).
  - **Deep Linking**: `barriofantasia://join?code=XYZ` support for 1-click WhatsApp/iMessage invitation links.
- **Biometric Security (Face ID / Touch ID)**: Optional `LocalAuthentication` vault protection for private votes and lineup tactical sheets.
- **Hardware Keychain Storage & Strict ATS**: User credentials secured via Apple Keychain (`kSecClassGenericPassword` + `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`) and App Transport Security strictly enforced (`NSAllowsArbitraryLoads: false`).
- **Full Vault JSON Backup (`VaultBackupService`)**: Export and backup player statistics and matchday archives via standard `Transferable` representations.
- **Companion Backend Integration**: Built to work offline-first or in synchronization with the hardened [Barrio de Fantasía Web & API Server](https://github.com/Wacko87/barrio-fantasia).

---

## 📱 Screenshots

<p align="center">
  <img src="screenshot_simulator.png" width="300" alt="Barrio Fantasia iOS Simulator (Spanish)" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="screenshot_simulator_fallback_en.png" width="300" alt="Barrio Fantasia iOS Simulator (English Fallback)" />
</p>

---

## 🏛️ Technical Architecture

| Layer | Implementation | Description |
|---|---|---|
| **Language** | Swift 6.0 | Strict concurrency checking, `@MainActor` isolation, `Sendable` domain models. |
| **UI Framework** | SwiftUI (iOS 17+) | Declarative views with `@Observable` ViewModels and `@Environment(\.locale)` dynamic injection. |
| **Persistence** | SwiftData | Clean schema models (`Player`, `Match`, `MatchVote`, `FantasyManager`, `Achievement`). |
| **Data Visualizations** | Swift Charts | Native `LineMark`, `PointMark`, and `RuleMark` statistical graphing. |
| **Authentication** | Apple & Google OAuth | Native `SignInWithAppleButton` + `ASWebAuthenticationSession`. |
| **Security & Tokens** | Apple Keychain | Encrypted keychain service (`KeychainService`) in hardware Secure Enclave. |
| **System Frameworks** | Apple Native | `PDFKit`, `TipKit`, `LocalAuthentication`, `UserNotifications`, `CoreImage`. |
| **Single Source of Truth** | [XcodeGen](https://github.com/yonaskolb/XcodeGen) | `project.yml` defines targets, schemes, and build settings deterministically. |

> [!NOTE]
> **Single Source of Truth:** `project.yml` is the canonical declaration of this project. Any configuration change (build flags, targets, resources) should be modified in `project.yml`, and `xcodegen generate` runs automatically on CI to synthesize the `.xcodeproj`.

---

## 🧪 Automated Testing (Apple Swift Testing)

The test target `BarrioFantasiaTests` utilizes Apple's modern **Swift Testing** framework (`@Suite`, `@Test`, `#expect`):

```bash
# Run unit tests on iOS Simulator
xcodebuild test \
  -project BarrioFantasia.xcodeproj \
  -scheme BarrioFantasia \
  -destination "platform=iOS Simulator,name=iPhone 18 Pro"
```

Key test suites covered:
- **`FantasyLogicTests`**: Manager ranking by total points descending, player position parsing, nickname display logic.
- **`VotingDeadlineTests`**: 24-hour peer rating expiration window, remaining seconds countdown, and status enforcement.
- **`KeychainServiceTests`**: Lifecycle testing of secure token storage and fallback handling.

---

## 🛠️ Building & Running

### Requirements
- macOS 14.5+ (Apple Silicon recommended)
- Xcode 16.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Quick Setup

```bash
# 1. Clone the repository
git clone https://github.com/Wacko87/barrio-fantasia-ios.git
cd barrio-fantasia-ios

# 2. Generate the Xcode project from project.yml
xcodegen generate

# 3. Open in Xcode
open BarrioFantasia.xcodeproj
```

### CLI Build & Simulator Execution

```bash
# Build with xcodebuild
xcodebuild -project BarrioFantasia.xcodeproj \
           -scheme BarrioFantasia \
           -destination "platform=iOS Simulator,name=iPhone 18 Pro" \
           clean build

# Run in Spanish
xcrun simctl launch booted com.barriofantasia.app -AppleLanguages '(es)' -AppleLocale 'es_ES'

# Run in English (or test automatic non-Spanish fallback)
xcrun simctl launch booted com.barriofantasia.app -AppleLanguages '(en)' -AppleLocale 'en_US'
```

---

## 🛡️ Privacy & App Store Compliance

- **Privacy Policy**: Read our comprehensive [Privacy Policy](PRIVACY_POLICY.md) compliant with App Store Guideline 5.1.1.
- **Zero Tracking**: `NSPrivacyTracking: false` declared in `PrivacyInfo.xcprivacy`.
- **Required-Reason APIs**: Documented `CA92.1` reason for `UserDefaults` storage.
- **Permissions**: Clear, localized usage descriptions for `NSFaceIDUsageDescription` and `NSPhotoLibraryUsageDescription` in `InfoPlist.xcstrings`.
- **App Store Review Guideline 2.1**: Full offline autonomy with pre-loaded demo rosters and match records via `DemoDataLoader` — Apple reviewers can test 100% of the app without backend credentials.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
