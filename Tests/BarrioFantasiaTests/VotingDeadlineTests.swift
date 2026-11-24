import Testing
import Foundation
@testable import BarrioFantasia

@Suite("Voting Deadline Tests")
struct VotingDeadlineTests {

    @Test("Voting is open within 24 hours of match completion")
    func testVotingOpenWithinWindow() {
        let match = Match(
            title: "Jornada 1",
            status: .jugado,
            playedAt: Date().addingTimeInterval(-3600) // 1 hour ago
        )

        #expect(match.isVotingOpen == true)
        #expect(match.votingDeadline != nil)
        #expect(match.votingRemainingSeconds > 0)
    }

    @Test("Voting is closed after 24 hours have passed")
    func testVotingClosedAfterWindow() {
        let match = Match(
            title: "Jornada Antígua",
            status: .jugado,
            playedAt: Date().addingTimeInterval(-25 * 3600) // 25 hours ago
        )

        #expect(match.isVotingOpen == false)
        #expect(match.votingRemainingSeconds == 0)
    }

    @Test("Voting is closed if match status is not jugado")
    func testVotingClosedIfNotJugado() {
        let match = Match(
            title: "Próximo Encuentro",
            status: .convocado,
            playedAt: Date()
        )

        #expect(match.isVotingOpen == false)
    }
}
