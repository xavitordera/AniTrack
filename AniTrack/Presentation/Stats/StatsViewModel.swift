import Foundation

@MainActor
final class StatsViewModel: ObservableObject {
    @Published private(set) var isLoggedIn = false
    @Published private(set) var isLoading = false
    @Published private(set) var dashboard: StatsDashboard?
    @Published var errorText: String?

    private let service: StatsService

    init(service: StatsService) {
        self.service = service
    }

    func syncAuthentication(isAuthenticated: Bool) {
        isLoggedIn = isAuthenticated

        guard isAuthenticated else {
            reset()
            return
        }

        if dashboard == nil && !isLoading {
            Task { await load() }
        }
    }

    func load() async {
        guard isLoggedIn else { return }

        isLoading = true
        errorText = nil

        do {
            dashboard = try await service.fetchAnimeStats()
        } catch {
            dashboard = nil
            handle(error: error)
        }

        isLoading = false
    }

    private func reset() {
        isLoading = false
        dashboard = nil
        errorText = nil
    }

    private func handle(error: Error) {
        if let serviceError = error as? AniListServiceError,
           case .unauthorized = serviceError {
            errorText = "Session expired. Please sign in again."
            return
        }

        errorText = "Unable to load your AniList stats right now."
    }
}
