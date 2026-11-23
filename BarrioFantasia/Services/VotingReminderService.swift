import Foundation
import UserNotifications

public final class VotingReminderService: Sendable {
    public static let shared = VotingReminderService()

    private init() {}

    public func requestAuthorization() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    public func scheduleVotingReminder(matchId: String, matchTitle: String, deadline: Date) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "⏰ ¡Plazo de Votación por Terminar!"
        content.body = "Quedan menos de 2 horas para votar las notas del partido \(matchTitle). Vota para no perder 2 puntos en Fantasy."
        content.sound = .default

        // Trigger 2 hours before deadline
        let triggerDate = deadline.addingTimeInterval(-2 * 3600)
        let interval = triggerDate.timeIntervalSince(Date())

        guard interval > 0 else { return }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(
            identifier: "voting-reminder-\(matchId)",
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    public func cancelVotingReminder(matchId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["voting-reminder-\(matchId)"])
    }
}
