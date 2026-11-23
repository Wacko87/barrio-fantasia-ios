import SwiftUI

public struct BiometricLockOverlay: View {
    @Bindable var biometricAuth: BiometricAuthService

    public init(biometricAuth: BiometricAuthService) {
        self.biometricAuth = biometricAuth
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))

                VStack(spacing: 6) {
                    Text("Barrio de Fantasía")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundStyle(.white)

                    Text("Desbloquea para acceder a las votaciones y estadísticas de tu pandilla.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Button {
                    Task {
                        _ = await biometricAuth.authenticate()
                    }
                } label: {
                    HStack {
                        Image(systemName: "faceid")
                        Text("Desbloquear con \(biometricAuth.biometricTypeString)")
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.89, green: 0.11, blue: 0.15))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .task {
            _ = await biometricAuth.authenticate()
        }
    }
}
