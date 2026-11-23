import SwiftUI
import SwiftData
import TipKit

@main
struct BarrioFantasiaApp: App {
    let container: ModelContainer

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
            MainTabView()
                .task {
                    DemoDataLoader.loadSampleDataIfNeeded(context: container.mainContext)
                }
        }
        .modelContainer(container)
    }
}
