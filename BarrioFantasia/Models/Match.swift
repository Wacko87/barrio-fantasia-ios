import Foundation
import SwiftUI
import SwiftData

public enum MatchFormat: String, CaseIterable, Codable, Sendable {
    case f6 = "Fútbol 6"
    case f7 = "Fútbol 7"
}

public enum MatchStatus: String, CaseIterable, Codable, Sendable {
    case convocado = "convocado"
    case enJuego = "enJuego"
    case jugado = "jugado"
    case cerrado = "cerrado"

    public var title: String {
        let isSpanish = (Locale.preferredLanguages.first ?? "en").hasPrefix("es")
        let locale = Locale(identifier: isSpanish ? "es" : "en")
        switch self {
        case .convocado: return String(localized: "Convocatoria Abierta", locale: locale)
        case .enJuego: return String(localized: "En Juego", locale: locale)
        case .jugado: return String(localized: "Votación Abierta", locale: locale)
        case .cerrado: return String(localized: "Finalizado", locale: locale)
        }
    }

    public var badgeColor: Color {
        switch self {
        case .convocado: return Color.blue
        case .enJuego: return Color.orange
        case .jugado: return Color.green
        case .cerrado: return Color.secondary
        }
    }
}

@Model
public final class Match {
    @Attribute(.unique) public var id: String
    public var title: String
    public var date: Date
    public var location: String
    public var formatRaw: String
    public var statusRaw: String
    public var playedAt: Date?
    public var scoreTeamA: Int
    public var scoreTeamB: Int
    public var signedPlayerIds: [String]
    public var teamAPlayerIds: [String]
    public var teamBPlayerIds: [String]

    public var format: MatchFormat {
        get { MatchFormat(rawValue: formatRaw) ?? .f7 }
        set { formatRaw = newValue.rawValue }
    }

    public var status: MatchStatus {
        get { MatchStatus(rawValue: statusRaw) ?? .convocado }
        set { statusRaw = newValue.rawValue }
    }

    public var isVotingOpen: Bool {
        guard status == .jugado, let played = playedAt else { return false }
        // 24 hours voting window
        return Date().timeIntervalSince(played) < 24 * 3600
    }

    public var votingDeadline: Date? {
        guard let played = playedAt else { return nil }
        return played.addingTimeInterval(24 * 3600)
    }

    public var votingRemainingSeconds: TimeInterval {
        guard let deadline = votingDeadline else { return 0 }
        return max(0, deadline.timeIntervalSince(Date()))
    }

    public init(
        id: String = UUID().uuidString,
        title: String,
        date: Date = Date(),
        location: String = "Pabellón Municipal",
        format: MatchFormat = .f7,
        status: MatchStatus = .convocado,
        playedAt: Date? = nil,
        scoreTeamA: Int = 0,
        scoreTeamB: Int = 0,
        signedPlayerIds: [String] = [],
        teamAPlayerIds: [String] = [],
        teamBPlayerIds: [String] = []
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.location = location
        self.formatRaw = format.rawValue
        self.statusRaw = status.rawValue
        self.playedAt = playedAt
        self.scoreTeamA = scoreTeamA
        self.scoreTeamB = scoreTeamB
        self.signedPlayerIds = signedPlayerIds
        self.teamAPlayerIds = teamAPlayerIds
        self.teamBPlayerIds = teamBPlayerIds
    }
}
