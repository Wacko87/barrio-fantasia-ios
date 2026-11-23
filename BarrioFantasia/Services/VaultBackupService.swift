import Foundation
import SwiftUI
import SwiftData

public struct LeagueBackupDocument: Transferable {
    public let jsonString: String

    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { item in
            Data(item.jsonString.utf8)
        }
        .suggestedFileName { _ in
            "Copia_Seguridad_Barrio_Fantasia_\(Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")).json"
        }
    }
}

public final class VaultBackupService: Sendable {
    public static let shared = VaultBackupService()

    private init() {}

    public func exportBackupJSON(players: [Player], matches: [Match], managers: [FantasyManager]) -> String {
        let payload: [String: Any] = [
            "version": "1.0.0",
            "exportedAt": ISO8601DateFormatter().string(from: Date()),
            "playersCount": players.count,
            "matchesCount": matches.count,
            "managersCount": managers.count,
            "players": players.map { [
                "id": $0.id,
                "name": $0.name,
                "nickname": $0.nickname,
                "number": $0.number,
                "position": $0.position.rawValue,
                "goals": $0.goals,
                "assists": $0.assists,
                "avgRating": $0.avgRating,
                "marketValue": $0.marketValue
            ]},
            "matches": matches.map { [
                "id": $0.id,
                "title": $0.title,
                "date": ISO8601DateFormatter().string(from: $0.date),
                "location": $0.location,
                "status": $0.status.rawValue,
                "scoreTeamA": $0.scoreTeamA,
                "scoreTeamB": $0.scoreTeamB
            ]},
            "fantasyManagers": managers.map { [
                "id": $0.id,
                "teamName": $0.teamName,
                "managerName": $0.managerName,
                "totalPoints": $0.totalPoints,
                "rank": $0.rank
            ]}
        ]

        if let data = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return "{}"
    }
}
