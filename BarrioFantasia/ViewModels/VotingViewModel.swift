import Foundation
import SwiftUI
import SwiftData

public struct PlayerVoteDraft: Identifiable {
    public var id: String { player.id }
    public let player: Player
    public var score: Double
    public var isMvp: Bool
    public var notes: String
}

@Observable
@MainActor
public final class VotingViewModel {
    public let match: Match
    public var drafts: [PlayerVoteDraft] = []
    public var isSubmitting: Bool = false
    public var submissionComplete: Bool = false
    public var errorMessage: String?

    public init(match: Match, allPlayers: [Player]) {
        self.match = match
        let participatingIds = Set(match.signedPlayerIds.isEmpty ? (match.teamAPlayerIds + match.teamBPlayerIds) : match.signedPlayerIds)
        let playersInMatch = allPlayers.filter { participatingIds.contains($0.id) }

        self.drafts = playersInMatch.map { player in
            PlayerVoteDraft(player: player, score: 7.0, isMvp: false, notes: "")
        }
    }

    public func setMvp(playerId: String) {
        for index in drafts.indices {
            drafts[index].isMvp = (drafts[index].player.id == playerId)
        }
        HapticManager.shared.impact(.heavy)
    }

    public func submitVotes(context: ModelContext) {
        isSubmitting = true
        HapticManager.shared.impact(.medium)

        for draft in drafts {
            let vote = MatchVote(
                matchId: match.id,
                voterPlayerId: "current_user",
                targetPlayerId: draft.player.id,
                score: draft.score,
                isMvp: draft.isMvp,
                comment: draft.notes.isEmpty ? nil : draft.notes,
                submittedAt: Date()
            )
            context.insert(vote)
        }

        try? context.save()
        VotingReminderService.shared.cancelVotingReminder(matchId: match.id)

        isSubmitting = false
        submissionComplete = true
        HapticManager.shared.notification(.success)
    }
}
