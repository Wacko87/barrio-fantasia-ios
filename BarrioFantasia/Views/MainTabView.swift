import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab: Int = 0

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            MatchesView()
                .tabItem {
                    Label("Partidos", systemImage: "figure.soccer")
                }
                .tag(0)

            PlayersView()
                .tabItem {
                    Label("Jugadores", systemImage: "person.3.fill")
                }
                .tag(1)

            StandingsView()
                .tabItem {
                    Label("Clasificación", systemImage: "list.number")
                }
                .tag(2)

            FantasyView()
                .tabItem {
                    Label("Fantasy", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(3)

            AchievementsView()
                .tabItem {
                    Label("Logros", systemImage: "trophy.fill")
                }
                .tag(4)
        }
        .tint(Color(red: 0.89, green: 0.11, blue: 0.15)) // Barrio Red Accent
    }
}
