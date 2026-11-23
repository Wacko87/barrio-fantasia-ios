import Foundation
import SwiftUI
import SwiftData

@Observable
@MainActor
public final class StandingsViewModel {
    public var standings: [StandingsRow] = []

    public init() {
        self.standings = [
            StandingsRow(id: "t1", name: "Equipo Rojo (Pistoleros)", played: 14, won: 9, drawn: 2, lost: 3, goalsFor: 48, goalsAgainst: 32, points: 29, form: ["V", "V", "E", "V", "D"]),
            StandingsRow(id: "t2", name: "Equipo Blanco (Magos)", played: 14, won: 8, drawn: 3, lost: 3, goalsFor: 44, goalsAgainst: 30, points: 27, form: ["V", "D", "V", "E", "V"]),
            StandingsRow(id: "t3", name: "Equipo Azul (Muralla)", played: 14, won: 6, drawn: 2, lost: 6, goalsFor: 36, goalsAgainst: 38, points: 20, form: ["D", "V", "D", "V", "D"]),
            StandingsRow(id: "t4", name: "Equipo Verde (Tiki-Taka)", played: 14, won: 3, drawn: 1, lost: 10, goalsFor: 28, goalsAgainst: 56, points: 10, form: ["D", "D", "D", "E", "D"])
        ]
    }
}
