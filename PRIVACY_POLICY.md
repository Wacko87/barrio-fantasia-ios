# Privacy Policy - Barrio Fantasía iOS

**Last Updated:** November 2026

## Overview
Barrio Fantasía is committed to respecting and protecting the privacy of all community members. This privacy policy describes how our native iOS application handles your personal information in compliance with Apple's App Store Review Guidelines (Guideline 5.1.1).

---

## 1. Information We Collect and Process
Barrio Fantasía operates primarily under an **Offline-First & Local-First Architecture**:

- **Account Data:** If you sign in, your display name, email, and authentication credentials are used solely to identify your league participation and calculate fantasy match results.
- **Biometric Authentication (Face ID / Touch ID):** Used exclusively for fast on-device authentication via Apple LocalAuthentication framework. Your biometric templates never leave the Secure Enclave of your Apple device.
- **Tokens and Credentials:** Stored securely inside the native Apple Keychain (`kSecClassGenericPassword`), protected by hardware-backed encryption.
- **Local Cache:** League data, player stats, and offline rosters are stored locally on your device via SwiftData / UserDefaults.

---

## 2. Information We Do NOT Collect
- **Zero Third-Party Trackers:** We do not embed third-party advertising SDKs, data brokers, or behavioral analytics trackers.
- **No Background Location Tracking:** We do not track your location or GPS coordinates.
- **No Sale of Personal Data:** We never sell, rent, monetize, or trade any personal information.

---

## 3. Network Communications and Security
All communications between Barrio Fantasía iOS and our backend APIs are conducted through strict **HTTPS (TLS 1.3)** connections with:
- Strict CORS validation.
- Rate limiting protection.
- Defense against unauthorized resource access.

---

## 4. Data Retention and Account Deletion
You maintain full ownership of your data:
- You can sign out at any time from the app settings, which wipes local keychain tokens and cached user sessions from the device.
- You can request complete deletion of your account and associated match history by contacting the league administrator or via the app's profile settings.

---

## 5. Contact Information
If you have any questions or feedback regarding this policy or data practices, you can reach out via GitHub:
- **Repository:** [https://github.com/Wacko87/barrio-fantasia-ios](https://github.com/Wacko87/barrio-fantasia-ios)
