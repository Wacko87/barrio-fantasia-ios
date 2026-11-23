import Foundation
import SwiftData

@Model
public final class MatchVote {
    @Attribute(.unique) public var id: String
    public var matchId: String
    public var voterPlayerId: String
    public var targetPlayerId: String
    public var score: Double
    public var isMvp: Bool
    public var comment: String?
    public var submittedAt: Date

    public init(
        id: String = UUID().uuidString,
        matchId: String,
        voterPlayerId: String,
        targetPlayerId: String,
        score: Double = 6.0,
        isMvp: Bool = false,
        comment: String? = nil,
        submittedAt: Date = Date()
    ) {
        self.id = id
        self.matchId = matchId
        self.voterPlayerId = voterPlayerId
        self.targetPlayerId = targetPlayerId
        self.score = score
        self.isMvp = isMvp
        self.comment = comment
        self.submittedAt = submittedAt
    }
}
