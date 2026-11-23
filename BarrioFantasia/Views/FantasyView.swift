import SwiftUI
import SwiftData

public struct FantasyView: View {
    @Query private var managers: [FantasyManager]
    @Query private var players: [Player]
    @State private var viewModel = FantasyViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    fantasyHeaderCard

                    // Leaderboard Card
                    leaderboardSection

                    // My Team Roster Card
                    myTeamRosterSection
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Liga Fantasy")
        }
    }

    private var fantasyHeaderCard: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.89, green: 0.11, blue: 0.15), Color(red: 0.65, green: 0.05, blue: 0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("LIGA FANTASY BARRIO")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(.white.opacity(0.85))

                    Text("Clasificación General")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundStyle(.white)

                    Text("Jornada 14 disputada · Puntos actualizados")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.75))
                }
                Spacer()
                Image(systemName: "trophy.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tabla de Mánagers")
                .font(.headline)
                .fontWeight(.bold)

            let sorted = viewModel.sortedManagers(from: managers)
            VStack(spacing: 0) {
                ForEach(Array(sorted.enumerated()), id: \.element.id) { index, manager in
                    managerRow(position: index + 1, manager: manager)
                    if index < sorted.count - 1 {
                        Divider()
                            .padding(.leading, 40)
                    }
                }
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func managerRow(position: Int, manager: FantasyManager) -> some View {
        HStack(spacing: 12) {
            Text("\(position)")
                .font(.caption)
                .fontWeight(.black)
                .frame(width: 26, height: 26)
                .background(position == 1 ? Color.yellow.opacity(0.2) : Color(uiColor: .systemFill))
                .foregroundStyle(position == 1 ? Color.orange : Color.secondary)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(manager.teamName)
                        .font(.subheadline)
                        .fontWeight(.bold)

                    if manager.penalties < 0 {
                        Text("\(manager.penalties) pts")
                            .font(.system(size: 9, weight: .black))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.red.opacity(0.15))
                            .foregroundStyle(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                }

                Text("Mánager: \(manager.managerName)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(manager.totalPoints) pts")
                    .font(.subheadline)
                    .fontWeight(.black)
                    .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))

                Text("+\(manager.weeklyPoints) esta jornada")
                    .font(.caption2)
                    .foregroundStyle(.green)
            }
        }
        .padding(14)
    }

    private var myTeamRosterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mi Plantilla Fantasy")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("Presupuesto: 12.5M €")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }

            let myPlayers = players.filter { $0.fantasyTeam == "F.C. Pandilla" }
            LazyVStack(spacing: 10) {
                ForEach(myPlayers) { player in
                    HStack {
                        Text("#\(player.number)")
                            .font(.caption)
                            .fontWeight(.black)
                            .frame(width: 28, height: 28)
                            .background(player.position.badgeColor.opacity(0.15))
                            .foregroundStyle(player.position.badgeColor)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 1) {
                            Text(player.displayName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(player.position.title)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 1) {
                            Text("\(player.marketValue / 1_000_000)M €")
                                .font(.caption)
                                .fontWeight(.bold)
                            Text("Media: \(String(format: "%.1f", player.avgRating))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}
