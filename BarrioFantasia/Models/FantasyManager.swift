import Foundation
import SwiftData

@Model
public final class FantasyManager {
    @Attribute(.unique) public var id: String
    public var teamName: String
    public var managerName: String
    public var totalPoints: Int
    public var weeklyPoints: Int
    public var rank: Int
    public var budget: Int
    public var rosterPlayerIds: [String]
    public var penalties: Int

    public init(
        id: String = UUID().uuidString,
        teamName: String,
        managerName: String,
        totalPoints: Int = 0,
        weeklyPoints: Int = 0,
        rank: Int = 1,
        budget: Int = 100_000_000,
        rosterPlayerIds: [String] = [],
        penalties: Int = 0
    ) {
        self.id = id
        self.teamName = teamName
        self.managerName = managerName
        self.totalPoints = totalPoints
        self.weeklyPoints = weeklyPoints
        self.rank = rank
        self.budget = budget
        self.rosterPlayerIds = rosterPlayerIds
        self.penalties = penalties
    }
}
