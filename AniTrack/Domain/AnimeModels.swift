import Foundation

struct AnimeMedia: Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let description: String
    let genres: [String]
    let score: Int?
    let episodes: Int?
    let bannerImage: String?
    let coverImage: String?
}

enum HomeTrackingPrimaryAction: Hashable {
    case incrementEpisode
    case markComplete
    case viewDetails
}

struct HomeTrackingItem: Identifiable, Hashable {
    let media: AnimeMedia
    let listEntryID: Int
    let status: MediaListStatus
    let watchedEpisodes: Int
    let totalEpisodes: Int?
    let nextAiringEpisode: Int?
    let nextAiringDate: Date?

    var id: Int { media.id }

    var primaryAction: HomeTrackingPrimaryAction {
        guard let totalEpisodes, totalEpisodes > 0 else {
            return .viewDetails
        }
        if watchedEpisodes >= totalEpisodes {
            return .markComplete
        }
        return .incrementEpisode
    }

    var primaryActionLabel: String {
        switch primaryAction {
        case .incrementEpisode:
            return "+1 Episode"
        case .markComplete:
            return "Mark Complete"
        case .viewDetails:
            return "View Details"
        }
    }

    var progressLabel: String {
        if let totalEpisodes, totalEpisodes > 0 {
            return "\(watchedEpisodes)/\(totalEpisodes) watched"
        }
        return "\(watchedEpisodes) eps watched"
    }

    var supportingText: String {
        if let nextAiringEpisode, let nextAiringDate {
            let relativeText = nextAiringDate.formatted(.relative(presentation: .named))
            return "Episode \(nextAiringEpisode) airs \(relativeText)"
        }
        if let nextAiringEpisode {
            return "Next: Episode \(nextAiringEpisode)"
        }
        if let totalEpisodes, totalEpisodes > 0, watchedEpisodes >= totalEpisodes {
            return "Ready to mark complete"
        }

        let nextEpisode = max(1, watchedEpisodes + 1)
        let prefix = status == .repeating ? "Rewatching" : "Next"
        return "\(prefix): Episode \(nextEpisode)"
    }

    var progressFraction: Double? {
        guard let totalEpisodes, totalEpisodes > 0 else { return nil }
        let boundedProgress = min(max(watchedEpisodes, 0), totalEpisodes)
        return Double(boundedProgress) / Double(totalEpisodes)
    }
}

struct HomeFeed {
    let featured: AnimeMedia?
    let trending: [AnimeMedia]
    let recommended: [AnimeMedia]
    let airingToday: [AnimeMedia]
}

struct AnimeDetail: Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let description: String
    let genres: [String]
    let studios: [String]
    let score: Int?
    let popularity: Int?
    let favorites: Int?
    let episodes: Int?
    let duration: Int?
    let seasonLabel: String
    let status: String
    let format: String
    let source: String
    let trailerURL: URL?
    let bannerImage: String?
    let coverImage: String?
    let relations: [AnimeRelation]
}

struct AnimeRelation: Identifiable, Hashable {
    let id: Int
    let title: String
    let relationType: String
    let format: String
    let score: Int?
    let coverImage: String?
}

struct DiscoverFilters: Equatable {
    var search: String = ""
    var genres: [String] = []
    var season: String?
    var seasonYear: Int?
    var format: String?
    var status: String?
    var sort: String = "POPULARITY_DESC"
}

struct DiscoverPage {
    let media: [AnimeMedia]
    let hasNextPage: Bool
}

struct AiringScheduleInfo: Equatable {
    let episode: Int
    let airingAt: Date
}
