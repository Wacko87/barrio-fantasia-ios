import SwiftUI
import SwiftData
import TipKit

@main
struct BarrioFantasiaApp: App {
    let container: ModelContainer
    @State private var biometricAuth = BiometricAuthService.shared
    @AppStorage("has_completed_onboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showingOnboarding: Bool = false

    private var effectiveLocale: Locale {
        let preferred = Locale.preferredLanguages.first ?? "en"
        if preferred.hasPrefix("es") {
            return Locale(identifier: "es")
        } else {
            return Locale(identifier: "en")
        }
    }

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

                if !hasCompletedOnboarding {
                    OnboardingFlowView(isPresented: $showingOnboarding)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if biometricAuth.isBiometricEnabled && !biometricAuth.isUnlocked {
                    BiometricLockOverlay(biometricAuth: biometricAuth)
                }
            }
            .onOpenURL { url in
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                   let code = components.queryItems?.first(where: { $0.name == "code" })?.value {
                    _ = InviteCodeService.shared.validateAndJoin(code: code)
                }
            }
            .environment(\.locale, effectiveLocale)
        }
        .modelContainer(container)
    }
}
