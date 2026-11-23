import Foundation
import SwiftUI
import SwiftData

@Observable
@MainActor
public final class FantasyViewModel {
    public var selectedManager: FantasyManager?

    public init() {}

    public func sortedManagers(from managers: [FantasyManager]) -> [FantasyManager] {
        managers.sorted(by: { $0.totalPoints > $1.totalPoints })
    }
}
