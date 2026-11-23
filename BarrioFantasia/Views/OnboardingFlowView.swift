import SwiftUI
import AuthenticationServices

public struct OnboardingFlowView: View {
    @Binding var isPresented: Bool
    @State private var appleAuth = AppleAuthService.shared
    @State private var googleAuth = GoogleAuthService.shared
    @State private var showingJoinAlert: Bool = false
    @State private var inviteCodeInput: String = ""
    @State private var joinError: String?

    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    public var body: some View {
        ZStack {
            // Dark Athletic Background
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.08, blue: 0.08), Color(red: 0.02, green: 0.02, blue: 0.02)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Brand Emblem
                VStack(spacing: 12) {
                    Image("logo", bundle: .main)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
                        .shadow(color: Color.red.opacity(0.4), radius: 16, x: 0, y: 6)

                    VStack(spacing: 4) {
                        Text("BARRIO DE FANTASÍA")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Partidos, Votaciones 24h & Liga Fantasy")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                Spacer()

                // Actions Container
                VStack(spacing: 12) {
                    // Sign in with Apple Button
                    SignInWithAppleButton(.continue) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        appleAuth.handleAuthorization(result: result)
                        if appleAuth.isAuthenticated {
                            completeOnboarding()
                        }
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Sign in with Google Button
                    Button {
                        Task {
                            let ok = await googleAuth.signInWithGoogle()
                            if ok {
                                completeOnboarding()
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "envelope.badge.shield.half.filled")
                                .font(.body)
                                .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                            Text("Continuar con Google")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .foregroundStyle(Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)

                    // Option 1: Create New Pandilla
                    Button {
                        completeOnboarding()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Crear Mi Nueva Pandilla")
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.89, green: 0.11, blue: 0.15))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)

                    // Option 2: Join with Code
                    Button {
                        showingJoinAlert = true
                        HapticManager.shared.impact(.light)
                    } label: {
                        HStack {
                            Image(systemName: "qrcode")
                            Text("Tengo un Código de Invitación")
                        }
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(Color.white.opacity(0.12))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)

                    // Option 3: Quick Demo Exploration
                    Button {
                        completeOnboarding()
                    } label: {
                        Text("Explorar Liga de Prueba")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.top, 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .alert("Unirme a Pandilla", isPresented: $showingJoinAlert) {
            TextField("Ej: BF-87X9", text: $inviteCodeInput)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
            Button("Unirme") {
                if InviteCodeService.shared.validateAndJoin(code: inviteCodeInput) {
                    HapticManager.shared.notification(.success)
                    completeOnboarding()
                } else {
                    HapticManager.shared.notification(.error)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Introduce el código de 4 a 6 caracteres compartido por el organizador de tu pandilla.")
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "has_completed_onboarding")
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isPresented = false
        }
        HapticManager.shared.notification(.success)
    }
}
