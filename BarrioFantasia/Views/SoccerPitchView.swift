import SwiftUI

public struct SoccerPitchView: View {
    let players: [Player]
    let teamName: String
    let teamColor: Color
    @State private var selectedPlayer: Player?

    public init(players: [Player], teamName: String, teamColor: Color = Color(red: 0.89, green: 0.11, blue: 0.15)) {
        self.players = players
        self.teamName = teamName
        self.teamColor = teamColor
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Pitch Canvas
            ZStack {
                // Pitch Grass
                pitchBackground

                // Field Lines
                pitchLines

                // Player Formations
                pitchPlayersOverlay
            }
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.3), lineWidth: 1.5))

            // Selected Player Callout
            if let player = selectedPlayer {
                HStack(spacing: 10) {
                    Text("#\(player.number)")
                        .font(.caption)
                        .fontWeight(.black)
                        .frame(width: 28, height: 28)
                        .background(player.position.badgeColor)
                        .foregroundStyle(.white)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 1) {
                        Text(player.displayName)
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text("\(player.position.title) · Nota media: \(String(format: "%.1f", player.avgRating))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(player.marketValue, format: .currency(code: "EUR").precision(.fractionLength(0)))
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundStyle(teamColor)
                }
                .padding(10)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }

    private var pitchBackground: some View {
        GeometryReader { geo in
            ZStack {
                // Base Green
                Color(red: 0.12, green: 0.50, blue: 0.22)

                // Alternating Lawn Stripes
                VStack(spacing: 0) {
                    ForEach(0..<6) { i in
                        Rectangle()
                            .fill(i % 2 == 0 ? Color.white.opacity(0.06) : Color.clear)
                            .frame(height: geo.size.height / 6)
                    }
                }
            }
        }
    }

    private var pitchLines: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            Path { path in
                // Boundary Lines
                path.addRect(CGRect(x: 12, y: 12, width: w - 24, height: h - 24))

                // Halfway Line
                path.move(to: CGPoint(x: 12, y: h / 2))
                path.addLine(to: CGPoint(x: w - 12, y: h / 2))

                // Center Circle
                path.addEllipse(in: CGRect(x: w / 2 - 35, y: h / 2 - 35, width: 70, height: 70))

                // Penalty Area (Top)
                path.addRect(CGRect(x: w / 2 - 60, y: 12, width: 120, height: 45))

                // Penalty Area (Bottom)
                path.addRect(CGRect(x: w / 2 - 60, y: h - 57, width: 120, height: 45))
            }
            .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
        }
    }

    private var pitchPlayersOverlay: some View {
        VStack {
            // Forwards
            HStack(spacing: 24) {
                ForEach(players.filter { $0.position == .del }) { p in
                    playerPin(p)
                }
            }
            .frame(maxHeight: .infinity)

            // Midfielders
            HStack(spacing: 20) {
                ForEach(players.filter { $0.position == .med }) { p in
                    playerPin(p)
                }
            }
            .frame(maxHeight: .infinity)

            // Defenders
            HStack(spacing: 24) {
                ForEach(players.filter { $0.position == .def }) { p in
                    playerPin(p)
                }
            }
            .frame(maxHeight: .infinity)

            // Goalkeeper
            HStack {
                ForEach(players.filter { $0.position == .por }) { p in
                    playerPin(p)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.vertical, 16)
    }

    private func playerPin(_ player: Player) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedPlayer = player
            }
            HapticManager.shared.impact(.light)
        } label: {
            VStack(spacing: 2) {
                ZStack {
                    Circle()
                        .fill(player.position.badgeColor)
                        .frame(width: 30, height: 30)
                        .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 2)

                    Text("#\(player.number)")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(.white)
                }

                Text(player.displayName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}
