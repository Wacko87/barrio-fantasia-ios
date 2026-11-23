import SwiftUI
import SwiftData

public struct PlayersView: View {
    @Query private var players: [Player]
    @State private var viewModel = PlayersViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Position filter chips
                    positionFilterBar

                    // Sorting picker
                    HStack {
                        Text("Ordenar:")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Picker("Ordenar", selection: $viewModel.sortOption) {
                            ForEach(PlayerSortOption.allCases) { opt in
                                Text(opt.localizedTitle).tag(opt)
                            }
                        }
                        .pickerStyle(.menu)

                        Spacer()

                        Text("\(viewModel.filteredPlayers(from: players).count) jugadores")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    // Players Grid / List
                    let list = viewModel.filteredPlayers(from: players)
                    LazyVStack(spacing: 12) {
                        ForEach(list) { player in
                            NavigationLink(value: player) {
                                PlayerRowCard(player: player)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .navigationDestination(for: Player.self) { player in
                        PlayerDetailView(player: player)
                    }
                }
                .padding(.vertical, 8)
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Buscar por nombre o apodo...")
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Jugadores")
        }
    }

    private var positionFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                positionChip(title: "TODOS", isSelected: viewModel.selectedPosition == nil, color: Color(red: 0.89, green: 0.11, blue: 0.15)) {
                    viewModel.selectedPosition = nil
                    HapticManager.shared.selection()
                }

                ForEach(PlayerPosition.allCases, id: \.self) { pos in
                    positionChip(title: pos.rawValue, isSelected: viewModel.selectedPosition == pos, color: pos.badgeColor) {
                        viewModel.selectedPosition = pos
                        HapticManager.shared.selection()
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func positionChip(title: String, isSelected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color(uiColor: .secondarySystemGroupedBackground))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(isSelected ? 0.15 : 0.03), radius: 3, x: 0, y: 1)
        }
    }
}

public struct PlayerRowCard: View {
    let player: Player

    public var body: some View {
        HStack(spacing: 14) {
            // Number badge
            Text("#\(player.number)")
                .font(.subheadline)
                .fontWeight(.black)
                .frame(width: 40, height: 40)
                .background(player.position.badgeColor.opacity(0.15))
                .foregroundStyle(player.position.badgeColor)
                .clipShape(Circle())

            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(player.displayName)
                        .font(.headline)
                        .fontWeight(.bold)

                    Text(player.position.rawValue)
                        .font(.system(size: 9, weight: .heavy))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(player.position.badgeColor.opacity(0.15))
                        .foregroundStyle(player.position.badgeColor)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }

                HStack(spacing: 12) {
                    Label("\(player.goals)", systemImage: "soccerball")
                    Label("\(player.assists)", systemImage: "arrowshape.turn.up.right.fill")
                    Label("\(player.matchesPlayed) PJ", systemImage: "figure.run")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Rating & Market Value
            VStack(alignment: .trailing, spacing: 3) {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", player.avgRating))
                        .font(.subheadline)
                        .fontWeight(.black)
                }

                Text("\(player.marketValue / 1_000_000)M €")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
