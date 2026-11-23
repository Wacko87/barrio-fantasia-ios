import SwiftUI
import SwiftData

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var players: [Player]
    @Query private var matches: [Match]
    @Query private var managers: [FantasyManager]

    @State private var appleAuth = AppleAuthService.shared
    @State private var serverUrlString: String = APIService.shared.serverURL.absoluteString
    @State private var isCheckingHealth: Bool = false
    @State private var healthStatusMessage: String?
    @State private var isHealthy: Bool?
    @State private var biometricAuth = BiometricAuthService.shared
    @State private var showingInviteSheet: Bool = false
    @State private var showAdvancedServerSettings: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                // Section 1: User Profile & Apple ID
                Section("Cuenta de Jugador") {
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 38))
                            .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(appleAuth.userDisplayName)
                                .font(.headline)
                                .fontWeight(.bold)
                            if let email = appleAuth.userEmail {
                                Text(email)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Perfil Local de Pandilla")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)

                    if appleAuth.isAuthenticated {
                        Button(role: .destructive) {
                            appleAuth.signOut()
                        } label: {
                            Text("Cerrar Sesión de Apple")
                        }
                    }
                }

                // Section 2: League Sharing & Onboarding
                Section("Gestión de la Pandilla") {
                    Button {
                        showingInviteSheet = true
                        HapticManager.shared.impact(.light)
                    } label: {
                        HStack {
                            Image(systemName: "qrcode")
                                .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                            Text("Invitar Compañeros (Código y QR)")
                                .fontWeight(.semibold)
                        }
                    }

                    HStack {
                        Text("Código de Pandilla")
                        Spacer()
                        Text(InviteCodeService.shared.currentLeagueCode)
                            .font(.system(.subheadline, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                    }
                }

                // Section 3: Security & Biometrics
                Section("Seguridad & Acceso") {
                    Toggle("Bloquear con \(biometricAuth.biometricTypeString)", isOn: Binding(
                        get: { biometricAuth.isBiometricEnabled },
                        set: { biometricAuth.isBiometricEnabled = $0 }
                    ))
                }

                // Section 4: Backup
                Section("Copia de Seguridad de la Liga") {
                    let json = VaultBackupService.shared.exportBackupJSON(players: players, matches: matches, managers: managers)
                    let doc = LeagueBackupDocument(jsonString: json)

                    ShareLink(item: doc, preview: SharePreview("Copia de Seguridad Barrio Fantasía", image: Image(systemName: "arrow.down.doc.fill"))) {
                        Label("Exportar Bóveda de Liga (JSON)", systemImage: "square.and.arrow.up")
                    }

                    Text("Exporta todos los jugadores, actas de partidos y clasificación Fantasy en un archivo JSON portátil.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // Section 5: Notifications
                Section("Notificaciones de Votación") {
                    Button {
                        Task {
                            let granted = await VotingReminderService.shared.requestAuthorization()
                            if granted {
                                HapticManager.shared.notification(.success)
                            }
                        }
                    } label: {
                        Label("Activar Avisos de 24h Restantes", systemImage: "bell.badge.fill")
                    }
                    Text("Recibe un aviso preventivo 2 horas antes de que venza el plazo de votación para evitar penalizaciones en la Fantasy.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // Section 6: Advanced Server Settings (Collapsible, for developers only)
                Section {
                    DisclosureGroup("Ajustes Avanzados de Servidor", isExpanded: $showAdvancedServerSettings) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Solo necesario si utilizas un servidor propio self-hosted.")
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            TextField("URL del Servidor", text: $serverUrlString)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .keyboardType(.URL)

                            Button {
                                checkServer()
                            } label: {
                                HStack {
                                    if isCheckingHealth {
                                        ProgressView().padding(.trailing, 6)
                                    }
                                    Text("Comprobar Conexión")
                                }
                            }
                            .disabled(isCheckingHealth)

                            if let msg = healthStatusMessage, let healthy = isHealthy {
                                HStack {
                                    Image(systemName: healthy ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                        .foregroundStyle(healthy ? .green : .orange)
                                    Text(msg).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }

                // Section 7: About
                Section("Acerca de") {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0 (Build 1)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Modo de Operación")
                        Spacer()
                        Text("Autónomo Offline-First")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        APIService.shared.setServerURL(serverUrlString)
                        HapticManager.shared.impact(.medium)
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingInviteSheet) {
                LeagueInviteSheet()
            }
        }
    }

    private func checkServer() {
        isCheckingHealth = true
        healthStatusMessage = nil
        Task {
            APIService.shared.setServerURL(serverUrlString)
            let ok = await APIService.shared.checkHealth()
            isHealthy = ok
            healthStatusMessage = ok ? "Servidor en línea y respondiendo." : "No se pudo conectar con el servidor."
            isCheckingHealth = false
            if ok {
                HapticManager.shared.notification(.success)
            } else {
                HapticManager.shared.notification(.warning)
            }
        }
    }
}
