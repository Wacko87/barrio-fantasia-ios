import Foundation
import SwiftUI
import SwiftData

public enum PlayerPosition: String, CaseIterable, Codable, Sendable {
    case por = "POR"
    case def = "DEF"
    case med = "MED"
    case del = "DEL"

    public var title: String {
        let isSpanish = (Locale.preferredLanguages.first ?? "en").hasPrefix("es")
        let locale = Locale(identifier: isSpanish ? "es" : "en")
        switch self {
        case .por: return String(localized: "Portero", locale: locale)
        case .def: return String(localized: "Defensa", locale: locale)
        case .med: return String(localized: "Centrocampista", locale: locale)
        case .del: return String(localized: "Delantero", locale: locale)
        }
    }

    public var badgeColor: Color {
        switch self {
        case .por: return Color(red: 0.12, green: 0.31, blue: 0.64) // #1F4FA3
        case .def: return Color(red: 0.12, green: 0.48, blue: 0.27) // #1E7B45
        case .med: return Color(red: 0.72, green: 0.47, blue: 0.04) // #B7790B
        case .del: return Color(red: 0.84, green: 0.07, blue: 0.12) // #D7131F
        }
    }
}

@Model
public final class Player {
    @Attribute(.unique) public var id: String
    public var name: String
    public var nickname: String
    public var number: Int
    public var positionRaw: String
    public var avatarUrl: String?
    public var matchesPlayed: Int
    public var goals: Int
    public var assists: Int
    public var mvpCount: Int
    public var avgRating: Double
    public var marketValue: Int
    public var fantasyTeam: String?

    public var position: PlayerPosition {
        get { PlayerPosition(rawValue: positionRaw) ?? .med }
        set { positionRaw = newValue.rawValue }
    }

    public var displayName: String {
        nickname.isEmpty ? name : nickname
    }

    public init(
        id: String = UUID().uuidString,
        name: String,
        nickname: String = "",
        number: Int,
        position: PlayerPosition = .med,
        avatarUrl: String? = nil,
        matchesPlayed: Int = 0,
        goals: Int = 0,
        assists: Int = 0,
        mvpCount: Int = 0,
        avgRating: Double = 6.0,
        marketValue: Int = 10_000_000,
        fantasyTeam: String? = nil
    ) {
        self.id = id
        self.name = name
        self.nickname = nickname
        self.number = number
        self.positionRaw = position.rawValue
        self.avatarUrl = avatarUrl
        self.matchesPlayed = matchesPlayed
        self.goals = goals
        self.assists = assists
        self.mvpCount = mvpCount
        self.avgRating = avgRating
        self.marketValue = marketValue
        self.fantasyTeam = fantasyTeam
    }
}
