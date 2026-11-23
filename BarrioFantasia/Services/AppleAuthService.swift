import Foundation
import AuthenticationServices
import SwiftUI

@Observable
@MainActor
public final class AppleAuthService: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    public static let shared = AppleAuthService()

    public var isAuthenticated: Bool = false
    public var userIdentifier: String?
    public var userDisplayName: String = "Jugador"
    public var userEmail: String?

    private override init() {
        super.init()
        // Migrate legacy UserDefaults tokens to secure Keychain
        KeychainService.shared.migrateFromUserDefaultsIfNeeded(key: "apple_user_id")
        KeychainService.shared.migrateFromUserDefaultsIfNeeded(key: "apple_user_name")
        KeychainService.shared.migrateFromUserDefaultsIfNeeded(key: "apple_user_email")

        if let id = KeychainService.shared.get(key: "apple_user_id"), !id.isEmpty {
            self.userIdentifier = id
            self.isAuthenticated = true
            self.userDisplayName = KeychainService.shared.get(key: "apple_user_name") ?? "Jugador"
            self.userEmail = KeychainService.shared.get(key: "apple_user_email")
        }
    }

    public func handleAuthorization(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userId = appleIDCredential.user
                self.userIdentifier = userId
                self.isAuthenticated = true

                if let fullName = appleIDCredential.fullName {
                    let given = fullName.givenName ?? ""
                    let family = fullName.familyName ?? ""
                    let combined = "\(given) \(family)".trimmingCharacters(in: .whitespacesAndNewlines)
                    if !combined.isEmpty {
                        self.userDisplayName = combined
                        KeychainService.shared.save(key: "apple_user_name", value: combined)
                    }
                }

                if let email = appleIDCredential.email {
                    self.userEmail = email
                    KeychainService.shared.save(key: "apple_user_email", value: email)
                }

                KeychainService.shared.save(key: "apple_user_id", value: userId)
                HapticManager.shared.notification(.success)
            }
        case .failure(let error):
            print("Sign in with Apple error: \(error.localizedDescription)")
            HapticManager.shared.notification(.error)
        }
    }

    public func signOut() {
        KeychainService.shared.delete(key: "apple_user_id")
        KeychainService.shared.delete(key: "apple_user_name")
        KeychainService.shared.delete(key: "apple_user_email")
        self.userIdentifier = nil
        self.isAuthenticated = false
        self.userDisplayName = "Jugador"
        self.userEmail = nil
        HapticManager.shared.impact(.medium)
    }

    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }
}
