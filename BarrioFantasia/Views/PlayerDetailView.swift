import SwiftUI

public struct PlayerDetailView: View {
    let player: Player

    public init(player: Player) {
        self.player = player
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero Player Card
                heroPlayerCard

                // Stat Summary Grid
                statsGridSection

                // Fantasy & Market Section
                fantasyMarketSection
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(player.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroPlayerCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(player.position.badgeColor.opacity(0.12))
                    .frame(width: 90, height: 90)

                Text("#\(player.number)")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(player.position.badgeColor)
            }

            VStack(spacing: 4) {
                Text(player.displayName)
                    .font(.title2)
                    .fontWeight(.black)

                if !player.nickname.isEmpty && player.name != player.nickname {
                    Text(player.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(player.position.title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(player.position.badgeColor.opacity(0.15))
                    .foregroundStyle(player.position.badgeColor)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var statsGridSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Estadísticas de Temporada")
                .font(.headline)
                .fontWeight(.bold)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statBox(title: "Partidos Jugados", value: "\(player.matchesPlayed)", icon: "figure.run", color: .blue)
                statBox(title: "Goles Anotados", value: "\(player.goals)", icon: "soccerball", color: Color(red: 0.89, green: 0.11, blue: 0.15))
                statBox(title: "Asistencias", value: "\(player.assists)", icon: "arrowshape.turn.up.right.fill", color: .green)
                statBox(title: "Galardones MVP", value: "\(player.mvpCount)", icon: "trophy.fill", color: .yellow)
                statBox(title: "Nota Media", value: String(format: "%.1f", player.avgRating), icon: "star.fill", color: .orange)
                statBox(title: "Goles / Partido", value: player.matchesPlayed > 0 ? String(format: "%.2f", Double(player.goals) / Double(player.matchesPlayed)) : "0.0", icon: "chart.bar.fill", color: .purple)
            }
        }
    }

    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Spacer()
            }

            Text(value)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var fantasyMarketSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ficha Fantasy")
                .font(.headline)
                .fontWeight(.bold)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Valor de Mercado")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(player.marketValue, format: .currency(code: "EUR").precision(.fractionLength(0)))
                        .font(.title3)
                        .fontWeight(.black)
                        .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                }

                Spacer()

                if let team = player.fantasyTeam {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Equipo Fantasy")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(team)
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                }
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
