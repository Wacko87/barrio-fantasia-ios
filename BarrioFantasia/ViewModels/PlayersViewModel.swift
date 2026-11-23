import Foundation
import SwiftUI
import SwiftData

public enum PlayerSortOption: String, CaseIterable, Identifiable {
    case rating = "rating"
    case goals = "goals"
    case assists = "assists"
    case matches = "matches"
    case marketValue = "marketValue"

    public var id: String { rawValue }

    public var localizedTitle: String {
        let isSpanish = (Locale.preferredLanguages.first ?? "en").hasPrefix("es")
        let locale = Locale(identifier: isSpanish ? "es" : "en")
        switch self {
        case .rating: return String(localized: "Nota Media", locale: locale)
        case .goals: return String(localized: "Goles Anotados", locale: locale)
        case .assists: return String(localized: "Asistencias", locale: locale)
        case .matches: return String(localized: "Partidos Jugados", locale: locale)
        case .marketValue: return String(localized: "Valor de Mercado", locale: locale)
        }
    }
}

@Observable
@MainActor
public final class PlayersViewModel {
    public var selectedPosition: PlayerPosition? = nil
    public var sortOption: PlayerSortOption = .rating
    public var searchQuery: String = ""

    public init() {}

    public func filteredPlayers(from players: [Player]) -> [Player] {
        var list = players

        if let pos = selectedPosition {
            list = list.filter { $0.position == pos }
        }

        if !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let q = searchQuery.lowercased()
            list = list.filter {
                $0.name.lowercased().contains(q) || $0.nickname.lowercased().contains(q)
            }
        }

        switch sortOption {
        case .rating:
            return list.sorted(by: { $0.avgRating > $1.avgRating })
        case .goals:
            return list.sorted(by: { $0.goals > $1.goals })
        case .assists:
            return list.sorted(by: { $0.assists > $1.assists })
        case .matches:
            return list.sorted(by: { $0.matchesPlayed > $1.matchesPlayed })
        case .marketValue:
            return list.sorted(by: { $0.marketValue > $1.marketValue })
        }
    }
}
