import SwiftUI
import SwiftData

public struct MatchDetailView: View {
    let match: Match
    @Query private var allPlayers: [Player]
    @State private var showingVotingSheet: Bool = false
    @State private var selectedTeamPitch: Int = 0 // 0: Equipo A, 1: Equipo B
    @State private var pdfDocument: MatchPDFDocument?

    public init(match: Match) {
        self.match = match
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Scoreboard
                scoreboardSection

                // 24h Voting Callout if open
                if match.isVotingOpen {
                    votingCalloutSection
                }

                // Interactive Tactical Pitch
                tacticalPitchSection

                // Teams Lineup Section
                teamsSection
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(match.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let doc = pdfDocument {
                    ShareLink(item: doc, preview: SharePreview(match.title, image: Image(systemName: "doc.text.fill"))) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                    }
                    .accessibilityLabel("Exportar y compartir acta oficial en PDF")
                }
            }
        }
        .task(id: match.id) {
            await preparePDFDocument()
        }
        .sheet(isPresented: $showingVotingSheet) {
            MatchVotingView(match: match, allPlayers: allPlayers)
        }
    }

    @MainActor
    private func preparePDFDocument() async {
        let teamAPlayers = allPlayers.filter { match.teamAPlayerIds.contains($0.id) }
            .map { PlayerReportSnapshot(number: $0.number, displayName: $0.displayName, position: $0.position.rawValue, avgRating: $0.avgRating) }
        let teamBPlayers = allPlayers.filter { match.teamBPlayerIds.contains($0.id) }
            .map { PlayerReportSnapshot(number: $0.number, displayName: $0.displayName, position: $0.position.rawValue, avgRating: $0.avgRating) }

        let snapshot = MatchReportSnapshot(
            title: match.title,
            date: match.date,
            location: match.location,
            format: match.format.rawValue,
            scoreTeamA: match.scoreTeamA,
            scoreTeamB: match.scoreTeamB,
            teamA: teamAPlayers,
            teamB: teamBPlayers
        )

        let data = await MatchReportPDFService.shared.generateReport(from: snapshot)
        self.pdfDocument = MatchPDFDocument(pdfData: data, title: match.title)
    }

    private var scoreboardSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text(match.format.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(match.status.title)
                    .font(.caption2)
                    .fontWeight(.heavy)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(match.status.badgeColor.opacity(0.15))
                    .foregroundStyle(match.status.badgeColor)
                    .clipShape(Capsule())
            }

            if match.status == .jugado || match.status == .cerrado {
                HStack(spacing: 30) {
                    VStack {
                        Text("EQUIPO A")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        Text("\(match.scoreTeamA)")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                    }

                    Text("—")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundStyle(.tertiary)

                    VStack {
                        Text("EQUIPO B")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        Text("\(match.scoreTeamB)")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                }
            }

            Divider()

            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text(match.date.formatted(date: .long, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(.secondary)
                Text(match.location)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var votingCalloutSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "timer")
                    .font(.title2)
                    .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                VStack(alignment: .leading, spacing: 2) {
                    Text("VOTACIÓN DE JUGADORES ACTIVA")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                    Text("Califica las notas de todos tus compañeros (1-10) y elige al MVP. Evita la penalización de -2 pts en Fantasy.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                showingVotingSheet = true
                HapticManager.shared.impact(.medium)
            } label: {
                HStack {
                    Image(systemName: "star.fill")
                    Text("Abrir Papeleta de Votación")
                }
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color(red: 0.89, green: 0.11, blue: 0.15))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(Color(red: 0.89, green: 0.11, blue: 0.15).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var tacticalPitchSection: some View {
        let teamAPlayers = allPlayers.filter { match.teamAPlayerIds.contains($0.id) }
        let teamBPlayers = allPlayers.filter { match.teamBPlayerIds.contains($0.id) }

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pizarra Táctica 2D")
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                Picker("Equipo", selection: $selectedTeamPitch) {
                    Text("Equipo A").tag(0)
                    Text("Equipo B").tag(1)
                }
                .pickerStyle(.segmented)
                .frame(width: 170)
            }

            if selectedTeamPitch == 0 {
                SoccerPitchView(players: teamAPlayers, teamName: "Equipo A", teamColor: Color(red: 0.89, green: 0.11, blue: 0.15))
            } else {
                SoccerPitchView(players: teamBPlayers, teamName: "Equipo B", teamColor: Color.blue)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var teamsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Alineaciones")
                .font(.title3)
                .fontWeight(.bold)

            let teamAPlayers = allPlayers.filter { match.teamAPlayerIds.contains($0.id) }
            let teamBPlayers = allPlayers.filter { match.teamBPlayerIds.contains($0.id) }

            VStack(alignment: .leading, spacing: 10) {
                Text("Equipo A (\(teamAPlayers.count))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))

                ForEach(teamAPlayers) { player in
                    playerRow(player)
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 10) {
                Text("Equipo B (\(teamBPlayers.count))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                ForEach(teamBPlayers) { player in
                    playerRow(player)
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func playerRow(_ player: Player) -> some View {
        HStack {
            Text("#\(player.number)")
                .font(.caption)
                .fontWeight(.black)
                .frame(width: 30, height: 30)
                .background(Color(uiColor: .systemFill))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(player.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(player.name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(player.position.rawValue)
                .font(.caption2)
                .fontWeight(.heavy)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(player.position.badgeColor.opacity(0.15))
                .foregroundStyle(player.position.badgeColor)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}
