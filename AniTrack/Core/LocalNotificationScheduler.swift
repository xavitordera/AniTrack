import Foundation
import UserNotifications

enum ReminderScheduleError: Error {
    case permissionDenied
    case noFutureDate
}

// sourcery: AutoMockable
protocol ReminderScheduling {
    /// Returns true when a reminder for the same episode already exists.
    func scheduleAiringReminder(animeID: Int, animeTitle: String, episode: Int, airingAt: Date) async throws -> Bool
}

final class LocalNotificationScheduler {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    /// Returns true when a reminder for the same episode already exists.
    func scheduleAiringReminder(animeID: Int, animeTitle: String, episode: Int, airingAt: Date) async throws -> Bool {
        guard airingAt.timeIntervalSinceNow > 0 else {
            throw ReminderScheduleError.noFutureDate
        }

        guard try await ensureAuthorization() else {
            throw ReminderScheduleError.permissionDenied
        }

        let identifier = "airing-\(animeID)-ep\(episode)"
        let pending = await pendingRequestIdentifiers()
        if pending.contains(identifier) {
            return true
        }

        let reminderDate = reminderDateForAiringDay(airingAt: airingAt)
        var date = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        date.second = 0

        let content = UNMutableNotificationContent()
        content.title = "Episode \(episode) airs today"
        content.body = "\(animeTitle) has a new episode today."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try await add(request)
        return false
    }

    private func ensureAuthorization() async throws -> Bool {
        let settings = await notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return try await requestAuthorization()
        default:
            return false
        }
    }

    private func reminderDateForAiringDay(airingAt: Date) -> Date {
        let calendar = Calendar.current
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: airingAt)
        let preferred = calendar.date(from: DateComponents(
            year: dayComponents.year,
            month: dayComponents.month,
            day: dayComponents.day,
            hour: 9,
            minute: 0
        )) ?? airingAt

        let now = Date()
        if preferred > now {
            return preferred
        }

        // If it's already airing day and 9:00 has passed, notify shortly instead.
        if calendar.isDate(now, inSameDayAs: airingAt) {
            return now.addingTimeInterval(120)
        }

        return preferred
    }

    private func requestAuthorization() async throws -> Bool {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    private func notificationSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }

    private func pendingRequestIdentifiers() async -> Set<String> {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: Set(requests.map(\.identifier)))
            }
        }
    }

    private func add(_ request: UNNotificationRequest) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            center.add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}

extension LocalNotificationScheduler: ReminderScheduling {}
