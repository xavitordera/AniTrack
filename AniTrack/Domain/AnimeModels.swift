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

struct ContinueWatchingItem: Identifiable, Hashable {
    let id: Int
    let anime: AnimeMedia
    let progress: Double
}

struct HomeFeed {
    let featured: AnimeMedia?
    let trending: [AnimeMedia]
    let continueWatching: [ContinueWatchingItem]
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
