import Foundation

struct StatsOverview: Equatable {
    let completedAnime: Int
    let episodesWatched: Int
    let minutesWatched: Int
    let averageScore: Double

    var hoursWatched: Double {
        Double(minutesWatched) / 60.0
    }
}

struct StatsCountItem: Identifiable, Equatable {
    let name: String
    let count: Int

    var id: String { name }
}

struct StatsStatusItem: Identifiable, Equatable {
    let status: MediaListStatus
    let count: Int

    var id: String { status.rawValue }

    var title: String {
        status.displayName
    }
}

struct StatsDashboard: Equatable {
    let userName: String
    let overview: StatsOverview
    let genres: [StatsCountItem]
    let studios: [StatsCountItem]
    let statusBreakdown: [StatsStatusItem]
}

protocol StatsService {
    func fetchAnimeStats() async throws -> StatsDashboard
}
