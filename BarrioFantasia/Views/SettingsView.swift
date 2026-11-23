import SwiftUI
import SwiftData

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var players: [Player]
    @Query private var matches: [Match]
    @Query private var managers: [FantasyManager]

    @State private var serverUrlString: String = APIService.shared.serverURL.absoluteString
    @State private var isCheckingHealth: Bool = false
    @State private var healthStatusMessage: String?
    @State private var isHealthy: Bool?
    @State private var biometricAuth = BiometricAuthService.shared

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("Seguridad & Acceso") {
                    Toggle("Bloquear con \(biometricAuth.biometricTypeString)", isOn: Binding(
                        get: { biometricAuth.isBiometricEnabled },
                        set: { biometricAuth.isBiometricEnabled = $0 }
                    ))
                }

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

                Section("Servidor & Sincronización") {
                    TextField("Dirección del Servidor", text: $serverUrlString)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)

                    Button {
                        checkServer()
                    } label: {
                        HStack {
                            if isCheckingHealth {
                                ProgressView()
                                    .padding(.trailing, 6)
                            }
                            Text("Comprobar Estado de Conexión")
                        }
                    }
                    .disabled(isCheckingHealth)

                    if let msg = healthStatusMessage, let healthy = isHealthy {
                        HStack {
                            Image(systemName: healthy ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundStyle(healthy ? .green : .orange)
                            Text(msg)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

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

                Section("Acerca de") {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0 (Build 1)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Plataforma")
                        Spacer()
                        Text("iOS 17.0+ · Swift 6")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Modo Operativo")
                        Spacer()
                        Text("Offline-First + API Sync")
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
