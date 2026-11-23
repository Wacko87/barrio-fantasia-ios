import Foundation

public struct StandingsRow: Identifiable, Codable, Sendable {
    public var id: String
    public var name: String
    public var played: Int
    public var won: Int
    public var drawn: Int
    public var lost: Int
    public var goalsFor: Int
    public var goalsAgainst: Int
    public var points: Int
    public var form: [String]

    public var goalDifference: Int {
        goalsFor - goalsAgainst
    }

    public init(
        id: String = UUID().uuidString,
        name: String,
        played: Int = 0,
        won: Int = 0,
        drawn: Int = 0,
        lost: Int = 0,
        goalsFor: Int = 0,
        goalsAgainst: Int = 0,
        points: Int = 0,
        form: [String] = ["V", "E", "D"]
    ) {
        self.id = id
        self.name = name
        self.played = played
        self.won = won
        self.drawn = drawn
        self.lost = lost
        self.goalsFor = goalsFor
        self.goalsAgainst = goalsAgainst
        self.points = points
        self.form = form
    }
}
