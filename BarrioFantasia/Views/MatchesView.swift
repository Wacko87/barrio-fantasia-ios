import SwiftUI
import SwiftData
import TipKit

public struct MatchesView: View {
    @Query private var matches: [Match]
    @Query private var players: [Player]
    @State private var viewModel = MatchesViewModel()
    @State private var showingSettings: Bool = false
    @State private var votingMatch: Match? = nil
    private let votingTip = VotingDeadlineTip()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header Brand Card
                    headerBrandSection

                    // Contextual TipKit Tip
                    TipView(votingTip)
                        .padding(.horizontal)

                    // Segmented Filter
                    Picker("Filtro", selection: $viewModel.selectedFilter) {
                        ForEach(MatchFilter.allCases) { filter in
                            Text(filter.localizedTitle).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Matches List
                    let filtered = viewModel.filteredMatches(from: matches)
                    if filtered.isEmpty {
                        emptyStateView
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(filtered) { match in
                                NavigationLink(value: match) {
                                    MatchCardView(match: match, onVoteTap: {
                                        votingMatch = match
                                    }, onSignupTap: {
                                        viewModel.toggleSignup(for: match, playerId: "p2")
                                    })
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .navigationDestination(for: Match.self) { match in
                            MatchDetailView(match: match)
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Partidos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                        HapticManager.shared.impact(.light)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                    }
                    .accessibilityLabel("Ajustes del servidor y notificaciones")
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(item: $votingMatch) { match in
                MatchVotingView(match: match, allPlayers: players)
            }
        }
    }

    private var headerBrandSection: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.1), Color(red: 0.05, green: 0.05, blue: 0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            HStack(spacing: 14) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1.5))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("BARRIO DE FANTASÍA")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text("OFICIAL")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 0.89, green: 0.11, blue: 0.15))
                            .clipShape(Capsule())
                    }

                    Text("Liga de Fútbol & Votaciones 24h")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.soccer")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No hay partidos en esta categoría")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

public struct MatchCardView: View {
    let match: Match
    let onVoteTap: () -> Void
    let onSignupTap: () -> Void

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top Bar
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
                    .padding(.vertical, 3)
                    .background(match.status.badgeColor.opacity(0.15))
                    .foregroundStyle(match.status.badgeColor)
                    .clipShape(Capsule())
            }

            // Title & Location
            VStack(alignment: .leading, spacing: 4) {
                Text(match.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption2)
                    Text(match.location)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            // Score or Signups
            if match.status == .jugado || match.status == .cerrado {
                HStack(spacing: 20) {
                    Spacer()
                    VStack {
                        Text("Equipo A")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("\(match.scoreTeamA)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                    }

                    Text("VS")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(.tertiary)

                    VStack {
                        Text("Equipo B")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("\(match.scoreTeamB)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            } else {
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundStyle(.secondary)
                    Text("\(match.signedPlayerIds.count) convocados")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()

                    Button {
                        onSignupTap()
                    } label: {
                        let isSigned = match.signedPlayerIds.contains("p2")
                        Text(isSigned ? "Apuntado ✓" : "Apuntarme")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isSigned ? Color.green : Color(red: 0.89, green: 0.11, blue: 0.15))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            // 24h Voting Banner
            if match.isVotingOpen {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                        Text("Plazo de votación 24h activo")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                        Spacer()
                    }

                    Button {
                        onVoteTap()
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Votar Jugadores y MVP")
                        }
                        .font(.caption)
                        .fontWeight(.heavy)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.89, green: 0.11, blue: 0.15))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
                .padding(10)
                .background(Color(red: 0.89, green: 0.11, blue: 0.15).opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
