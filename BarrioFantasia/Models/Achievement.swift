import Foundation
import SwiftData

@Model
public final class Achievement {
    @Attribute(.unique) public var id: String
    public var title: String
    public var details: String
    public var iconName: String
    public var category: String
    public var isUnlocked: Bool
    public var currentProgress: Double
    public var targetProgress: Double

    public var progressPercent: Double {
        guard targetProgress > 0 else { return 0 }
        return min(1.0, currentProgress / targetProgress)
    }

    public init(
        id: String = UUID().uuidString,
        title: String,
        details: String,
        iconName: String,
        category: String = "General",
        isUnlocked: Bool = false,
        currentProgress: Double = 0,
        targetProgress: Double = 1.0
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.iconName = iconName
        self.category = category
        self.isUnlocked = isUnlocked
        self.currentProgress = currentProgress
        self.targetProgress = targetProgress
    }
}
