import Foundation
import LocalAuthentication
import SwiftUI

@Observable
@MainActor
public final class BiometricAuthService {
    public static let shared = BiometricAuthService()

    public var isBiometricEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "biometric_lock_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "biometric_lock_enabled") }
    }

    public var isUnlocked: Bool = false

    private init() {
        if !isBiometricEnabled {
            isUnlocked = true
        }
    }

    public var biometricTypeString: String {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "Código del Dispositivo"
        }
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Biometría"
        }
    }

    public func authenticate() async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Cancelar"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            isUnlocked = true
            return true
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Protege las votaciones y estadísticas de tu pandilla de fútbol."
            )
            isUnlocked = success
            if success {
                HapticManager.shared.notification(.success)
            }
            return success
        } catch {
            isUnlocked = false
            HapticManager.shared.notification(.error)
            return false
        }
    }
}
