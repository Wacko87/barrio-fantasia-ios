import SwiftUI

public struct StandingsView: View {
    @State private var viewModel = StandingsViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header Card
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Temporada 2026/2027")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                            Text("Clasificación de Equipos")
                                .font(.title3)
                                .fontWeight(.black)
                        }
                        Spacer()
                        Image(systemName: "shield.checkered")
                            .font(.title)
                            .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)

                    // Standings Table Card
                    VStack(spacing: 0) {
                        // Table Header
                        HStack(spacing: 8) {
                            Text("#")
                                .frame(width: 24, alignment: .leading)
                            Text("Equipo")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("PJ")
                                .frame(width: 26, alignment: .center)
                            Text("DG")
                                .frame(width: 30, alignment: .center)
                            Text("PTS")
                                .frame(width: 36, alignment: .trailing)
                        }
                        .font(.caption2)
                        .fontWeight(.heavy)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))

                        Divider()

                        // Table Rows
                        ForEach(Array(viewModel.standings.enumerated()), id: \.element.id) { index, row in
                            standingsRowView(position: index + 1, row: row)
                            if index < viewModel.standings.count - 1 {
                                Divider()
                                    .padding(.leading, 40)
                            }
                        }
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    // Form Legend
                    formLegendSection
                }
                .padding(.vertical, 12)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Clasificación")
        }
    }

    private func standingsRowView(position: Int, row: StandingsRow) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                // Position indicator
                Text("\(position)")
                    .font(.caption)
                    .fontWeight(.black)
                    .frame(width: 24, height: 24)
                    .background(positionColor(position).opacity(0.15))
                    .foregroundStyle(positionColor(position))
                    .clipShape(Circle())

                // Team Name
                VStack(alignment: .leading, spacing: 2) {
                    Text(row.name)
                        .font(.subheadline)
                        .fontWeight(.bold)

                    // Form chips
                    HStack(spacing: 3) {
                        ForEach(Array(row.form.prefix(5).enumerated()), id: \.offset) { _, result in
                            formChip(result)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Matches Played
                Text("\(row.played)")
                    .font(.caption)
                    .frame(width: 26, alignment: .center)
                    .foregroundStyle(.secondary)

                // Goal Diff
                Text("\(row.goalDifference > 0 ? "+\(row.goalDifference)" : "\(row.goalDifference)")")
                    .font(.caption)
                    .frame(width: 30, alignment: .center)
                    .foregroundStyle(row.goalDifference >= 0 ? .green : .red)

                // Points
                Text("\(row.points)")
                    .font(.subheadline)
                    .fontWeight(.black)
                    .frame(width: 36, alignment: .trailing)
                    .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func formChip(_ result: String) -> some View {
        let (color, text) = formProperties(result)
        return Text(text)
            .font(.system(size: 8, weight: .black))
            .frame(width: 14, height: 14)
            .background(color)
            .foregroundStyle(.white)
            .clipShape(Circle())
    }

    private func formProperties(_ result: String) -> (Color, String) {
        switch result.uppercased() {
        case "V": return (.green, "V")
        case "E": return (.orange, "E")
        default: return (.red, "D")
        }
    }

    private func positionColor(_ pos: Int) -> Color {
        switch pos {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .secondary
        }
    }

    private var formLegendSection: some View {
        HStack(spacing: 16) {
            Label("V = Victoria", systemImage: "circle.fill")
                .foregroundStyle(.green)
            Label("E = Empate", systemImage: "circle.fill")
                .foregroundStyle(.orange)
            Label("D = Derrota", systemImage: "circle.fill")
                .foregroundStyle(.red)
        }
        .font(.caption2)
        .padding(.horizontal)
    }
}
