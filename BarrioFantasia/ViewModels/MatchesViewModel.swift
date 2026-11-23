import Foundation
import SwiftUI
import SwiftData

public enum MatchFilter: String, CaseIterable, Identifiable {
    case todos = "Todos"
    case convocatorias = "Convocatorias"
    case votaciones = "Votaciones"
    case finalizados = "Finalizados"

    public var id: String { rawValue }
}

@Observable
@MainActor
public final class MatchesViewModel {
    public var selectedFilter: MatchFilter = .todos
    public var isRefreshing: Bool = false
    public var showingCreateSheet: Bool = false

    public init() {}

    public func filteredMatches(from matches: [Match]) -> [Match] {
        let sorted = matches.sorted(by: { $0.date > $1.date })
        switch selectedFilter {
        case .todos:
            return sorted
        case .convocatorias:
            return sorted.filter { $0.status == .convocado }
        case .votaciones:
            return sorted.filter { $0.status == .jugado && $0.isVotingOpen }
        case .finalizados:
            return sorted.filter { $0.status == .cerrado }
        }
    }

    public func toggleSignup(for match: Match, playerId: String) {
        if match.signedPlayerIds.contains(playerId) {
            match.signedPlayerIds.removeAll(where: { $0 == playerId })
            HapticManager.shared.impact(.light)
        } else {
            match.signedPlayerIds.append(playerId)
            HapticManager.shared.notification(.success)
        }
    }
}
