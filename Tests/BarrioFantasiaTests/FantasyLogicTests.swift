import Testing
import Foundation
@testable import BarrioFantasia

@Suite("Fantasy Logic Tests")
struct FantasyLogicTests {

    @Test("Managers are sorted by totalPoints in descending order")
    @MainActor
    func testManagerSorting() {
        let viewModel = FantasyViewModel()
        let manager1 = FantasyManager(teamName: "Galácticos FC", managerName: "Carlos", totalPoints: 120)
        let manager2 = FantasyManager(teamName: "Rayo Vallecano", managerName: "Oscar", totalPoints: 250)
        let manager3 = FantasyManager(teamName: "La Máquina", managerName: "David", totalPoints: 180)

        let sorted = viewModel.sortedManagers(from: [manager1, manager2, manager3])

        #expect(sorted.count == 3)
        #expect(sorted[0].managerName == "Oscar")
        #expect(sorted[1].managerName == "David")
        #expect(sorted[2].managerName == "Carlos")
        #expect(sorted[0].totalPoints == 250)
        #expect(sorted[2].totalPoints == 120)
    }

    @Test("Player position parsing and default fallback")
    func testPlayerPosition() {
        let striker = Player(name: "Paco", number: 9, position: .del)
        #expect(striker.position == .del)
        #expect(striker.positionRaw == "DEL")

        let unknownPos = Player(name: "Test Player", number: 10, position: .med)
        unknownPos.positionRaw = "INVALID_POS"
        #expect(unknownPos.position == .med)
    }

    @Test("Player display name prefers nickname if present")
    func testPlayerDisplayName() {
        let playerWithNickname = Player(name: "Alejandro Ruiz", nickname: "Alex", number: 7)
        #expect(playerWithNickname.displayName == "Alex")

        let playerWithoutNickname = Player(name: "Marcos Torres", nickname: "", number: 4)
        #expect(playerWithoutNickname.displayName == "Marcos Torres")
    }
}
