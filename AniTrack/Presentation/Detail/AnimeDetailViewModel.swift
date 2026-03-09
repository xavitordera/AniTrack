import Foundation

@MainActor
final class AnimeDetailViewModel: ObservableObject {
    @Published var detail: AnimeDetail?
    @Published var nextAiring: AiringScheduleInfo?
    @Published var countdownText: String?
    @Published var isLoading = false
    @Published var errorText: String?
    @Published var reminderMessage: String?
    @Published var isSchedulingReminder = false
    @Published var isTracked = false

    private let animeID: Int
    private let repository: AnimeRepository
    private let reminderScheduler: ReminderScheduling
    private var countdownTask: Task<Void, Never>?

    init(
        animeID: Int,
        repository: AnimeRepository,
        reminderScheduler: ReminderScheduling = LocalNotificationScheduler()
    ) {
        self.animeID = animeID
        self.repository = repository
        self.reminderScheduler = reminderScheduler
    }

    func load() async {
        guard detail == nil else { return }
        isLoading = true
        errorText = nil

        do {
            detail = try await repository.fetchAnimeDetail(id: animeID)
        } catch {
            errorText = "Unable to load anime details right now."
            isLoading = false
            return
        }

        do {
            nextAiring = try await repository.fetchNextAiring(mediaID: animeID)
        } catch {
            nextAiring = nil
        }
        startCountdownIfNeeded()

        isLoading = false
    }

    func toggleTracked() {
        isTracked.toggle()
    }

    func scheduleReminderForNextEpisode() async {
        guard let detail, let nextAiring else {
            errorText = "No upcoming episode available for reminder."
            return
        }

        isSchedulingReminder = true
        reminderMessage = nil

        do {
            let alreadyExists = try await reminderScheduler.scheduleAiringReminder(
                animeID: detail.id,
                animeTitle: detail.title,
                episode: nextAiring.episode,
                airingAt: nextAiring.airingAt
            )
            reminderMessage = alreadyExists
                ? "Reminder already scheduled for this episode."
                : "Reminder set for airing day."
        } catch ReminderScheduleError.permissionDenied {
            errorText = "Allow notifications in Settings to receive airing reminders."
        } catch ReminderScheduleError.noFutureDate {
            errorText = "This episode is no longer upcoming."
        } catch {
            errorText = "Couldn't schedule reminder right now."
        }

        isSchedulingReminder = false
    }

    private func startCountdownIfNeeded() {
        countdownTask?.cancel()
        guard let nextAiring else {
            countdownText = nil
            return
        }

        countdownText = Self.countdownString(until: nextAiring.airingAt)
        countdownTask = Task { @MainActor in
            while !Task.isCancelled {
                countdownText = Self.countdownString(until: nextAiring.airingAt)
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    private static func countdownString(until date: Date) -> String {
        let remaining = max(0, Int(date.timeIntervalSinceNow))
        let days = remaining / 86_400
        let hours = (remaining % 86_400) / 3_600
        let minutes = (remaining % 3_600) / 60
        let seconds = remaining % 60

        if days > 0 {
            return "\(days)d \(hours)h \(minutes)m"
        }
        if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        }
        return "\(minutes)m \(seconds)s"
    }

    deinit {
        countdownTask?.cancel()
    }
}
