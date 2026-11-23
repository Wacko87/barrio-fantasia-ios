import SwiftUI
import SwiftData
import TipKit

@main
struct BarrioFantasiaApp: App {
    let container: ModelContainer
    @State private var biometricAuth = BiometricAuthService.shared

    init() {
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])

        do {
            let schema = Schema([
                Player.self,
                Match.self,
                MatchVote.self,
                FantasyManager.self,
                Achievement.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .task {
                        DemoDataLoader.loadSampleDataIfNeeded(context: container.mainContext)
                    }

                if biometricAuth.isBiometricEnabled && !biometricAuth.isUnlocked {
                    BiometricLockOverlay(biometricAuth: biometricAuth)
                }
            }
        }
        .modelContainer(container)
    }
}
