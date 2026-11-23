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
        let savedId = UserDefaults.standard.string(forKey: "apple_user_id")
        if let id = savedId, !id.isEmpty {
            self.userIdentifier = id
            self.isAuthenticated = true
            self.userDisplayName = UserDefaults.standard.string(forKey: "apple_user_name") ?? "Jugador"
            self.userEmail = UserDefaults.standard.string(forKey: "apple_user_email")
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
                        UserDefaults.standard.set(combined, forKey: "apple_user_name")
                    }
                }

                if let email = appleIDCredential.email {
                    self.userEmail = email
                    UserDefaults.standard.set(email, forKey: "apple_user_email")
                }

                UserDefaults.standard.set(userId, forKey: "apple_user_id")
                HapticManager.shared.notification(.success)
            }
        case .failure(let error):
            print("Sign in with Apple error: \(error.localizedDescription)")
            HapticManager.shared.notification(.error)
        }
    }

    public func signOut() {
        UserDefaults.standard.removeObject(forKey: "apple_user_id")
        UserDefaults.standard.removeObject(forKey: "apple_user_name")
        UserDefaults.standard.removeObject(forKey: "apple_user_email")
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
