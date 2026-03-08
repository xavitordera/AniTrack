import Foundation

struct HomeFeedResponseDTO: Decodable {
    let trending: MediaPageDTO
    let seasonPopular: MediaPageDTO
    let recommended: MediaPageDTO
    let airing: MediaPageDTO
}

struct MediaPageDTO: Decodable {
    let media: [MediaDTO?]?
}

struct MediaDTO: Decodable {
    let id: Int
    let title: MediaTitleDTO
    let description: String?
    let episodes: Int?
    let averageScore: Int?
    let genres: [String]?
    let bannerImage: String?
    let coverImage: MediaCoverImageDTO?
}

struct MediaTitleDTO: Decodable {
    let romaji: String?
    let english: String?
}

struct MediaCoverImageDTO: Decodable {
    let large: String?
    let extraLarge: String?
}

struct AnimeDetailResponseDTO: Decodable {
    let page: MediaDetailPageDTO

    enum CodingKeys: String, CodingKey {
        case page = "Page"
    }
}

struct MediaDetailPageDTO: Decodable {
    let media: [MediaDetailDTO?]?
}

struct MediaDetailDTO: Decodable {
    let id: Int
    let title: MediaDetailTitleDTO?
    let description: String?
    let episodes: Int?
    let duration: Int?
    let averageScore: Int?
    let popularity: Int?
    let favourites: Int?
    let status: String?
    let season: String?
    let seasonYear: Int?
    let format: String?
    let source: String?
    let genres: [String]?
    let bannerImage: String?
    let coverImage: MediaCoverImageDTO?
    let trailer: MediaTrailerDTO?
    let studios: MediaStudiosDTO?
    let relations: MediaRelationsDTO?
}

struct MediaDetailTitleDTO: Decodable {
    let romaji: String?
    let english: String?
    let native: String?
}

struct MediaTrailerDTO: Decodable {
    let site: String?
    let id: String?
}

struct MediaStudiosDTO: Decodable {
    let nodes: [MediaStudioNodeDTO?]?
}

struct MediaStudioNodeDTO: Decodable {
    let name: String?
}

struct MediaRelationsDTO: Decodable {
    let edges: [MediaRelationEdgeDTO?]?
}

struct MediaRelationEdgeDTO: Decodable {
    let relationType: String?
    let node: MediaRelationNodeDTO?
}

struct MediaRelationNodeDTO: Decodable {
    let id: Int
    let type: String?
    let format: String?
    let averageScore: Int?
    let title: MediaTitleDTO?
    let coverImage: MediaCoverImageDTO?
}

struct DiscoverResponseDTO: Decodable {
    let page: DiscoverPageDTO

    enum CodingKeys: String, CodingKey {
        case page = "Page"
    }
}

struct DiscoverPageDTO: Decodable {
    let pageInfo: DiscoverPageInfoDTO?
    let media: [MediaDTO?]?
}

struct DiscoverPageInfoDTO: Decodable {
    let hasNextPage: Bool?
}

struct NextAiringResponseDTO: Decodable {
    let airingSchedule: NextAiringDTO?

    enum CodingKeys: String, CodingKey {
        case airingSchedule = "AiringSchedule"
    }
}

struct NextAiringDTO: Decodable {
    let episode: Int?
    let airingAt: Int?
}
