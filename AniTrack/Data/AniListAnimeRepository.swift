import Foundation
import ApolloAPI

final class AniListAnimeRepository: AnimeRepository {
    private let service: AniListGraphQLService

    init(service: AniListGraphQLService = AniListGraphQLService()) {
        self.service = service
    }

    func fetchHomeFeed() async throws -> HomeFeed {
        let seasonData = MediaSeasonHelper.currentSeasonAndYear()
        let query = AniTrackAPI.HomeFeedQuery(
            page: .some(1),
            perPage: .some(12),
            season: .some(GraphQLEnum(rawValue: seasonData.season)),
            seasonYear: .some(seasonData.year)
        )
        let payload = try await service.fetch(query: query)

        let trending = mapMediaCards(payload.trending?.media?.compactMap { $0?.fragments.mediaCard })
        let seasonPopular = mapMediaCards(payload.seasonPopular?.media?.compactMap { $0?.fragments.mediaCard })
        let recommended = mapMediaCards(payload.recommended?.media?.compactMap { $0?.fragments.mediaCard })
        let airing = mapMediaCards(payload.airing?.media?.compactMap { $0?.fragments.mediaCard })

        let featured = trending.first ?? seasonPopular.first
        return HomeFeed(
            featured: featured,
            trending: seasonPopular,
            recommended: recommended,
            airingToday: airing
        )
    }

    func fetchAnimeDetail(id: Int) async throws -> AnimeDetail {
        let payload = try await service.fetch(query: AniTrackAPI.AnimeDetailQuery(id: id))
        guard let media = payload.page?.media?.compactMap({ $0 }).first else {
            throw AniListServiceError.emptyData
        }

        let title = resolveTitle(english: media.title?.english, romaji: media.title?.romaji, fallback: "Unknown Title")
        let subtitle = media.title?.native ?? media.title?.romaji ?? ""
        let studios = (media.studios?.nodes ?? [])
            .compactMap { $0?.name.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let relations = mapRelations(media.relations?.edges, currentID: media.id)
        let seasonLabel = "\(readable(media.season?.rawValue)) \(media.seasonYear.map(String.init) ?? "")".trimmingCharacters(in: .whitespaces)

        return AnimeDetail(
            id: media.id,
            title: title,
            subtitle: subtitle,
            description: cleanDescription(media.description),
            genres: media.genres?.compactMap { $0 } ?? [],
            studios: studios,
            score: media.averageScore,
            popularity: media.popularity,
            favorites: media.favourites,
            episodes: media.episodes,
            duration: media.duration,
            seasonLabel: seasonLabel,
            status: readable(media.status?.rawValue),
            format: readable(media.format?.rawValue),
            source: readable(media.source?.rawValue),
            trailerURL: trailerURL(from: media.trailer),
            bannerImage: media.bannerImage,
            coverImage: media.coverImage?.extraLarge ?? media.coverImage?.large,
            relations: relations
        )
    }

    func fetchDiscover(page: Int, filters: DiscoverFilters) async throws -> DiscoverPage {
        let search = filters.search.trimmingCharacters(in: .whitespacesAndNewlines)
        let query = AniTrackAPI.DiscoverAnimeQuery(
            page: .some(max(1, page)),
            isAdult: .some(false),
            search: search.isEmpty ? .none : .some(search),
            format: filters.format.map { .some([GraphQLEnum(rawValue: $0)]) } ?? .none,
            status: filters.status.map { .some(GraphQLEnum(rawValue: $0)) } ?? .none,
            season: filters.season.map { .some(GraphQLEnum(rawValue: $0)) } ?? .none,
            seasonYear: filters.seasonYear.map(GraphQLNullable.some) ?? .none,
            genres: filters.genres.isEmpty ? .none : .some(filters.genres.map { Optional($0) }),
            sort: .some([GraphQLEnum(rawValue: filters.sort)])
        )
        let payload = try await service.fetch(query: query)

        return DiscoverPage(
            media: mapMediaCards(payload.page?.media?.compactMap { $0?.fragments.mediaCard }),
            hasNextPage: payload.page?.pageInfo?.hasNextPage ?? false
        )
    }

    func fetchNextAiring(mediaID: Int) async throws -> AiringScheduleInfo? {
        let payload = try await service.fetch(query: AniTrackAPI.NextAiringQuery(mediaId: .some(mediaID)))
        guard let schedule = payload.airingSchedule else {
            return nil
        }

        return AiringScheduleInfo(
            episode: schedule.episode,
            airingAt: Date(timeIntervalSince1970: TimeInterval(schedule.airingAt))
        )
    }

    private func mapMediaCards(_ mediaList: [AniTrackAPI.MediaCard]?) -> [AnimeMedia] {
        (mediaList ?? []).map { card in
            let resolvedTitle = resolveTitle(
                english: card.title?.english,
                romaji: card.title?.romaji,
                fallback: "Unknown Title"
            )
            let cleanedDescription = cleanDescription(card.description)

            return AnimeMedia(
                id: card.id,
                title: resolvedTitle,
                subtitle: card.title?.romaji ?? "",
                description: cleanedDescription,
                genres: card.genres?.compactMap { $0 } ?? [],
                score: card.averageScore,
                episodes: card.episodes,
                bannerImage: card.bannerImage,
                coverImage: card.coverImage?.large
            )
        }
    }

    private func resolveTitle(english: String?, romaji: String?, fallback: String) -> String {
        let title = english?.trimmingCharacters(in: .whitespacesAndNewlines)
        let backup = romaji?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (title?.isEmpty == false ? title : backup) ?? fallback
    }

    private func cleanDescription(_ description: String?) -> String {
        guard let description, !description.isEmpty else {
            return "No synopsis available."
        }

        let noHTML = description.replacingOccurrences(
            of: "<[^>]+>",
            with: " ",
            options: .regularExpression
        )
        let noBreaks = noHTML.replacingOccurrences(of: "\n", with: " ")
        let collapsed = noBreaks.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )
        let trimmed = collapsed.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "No synopsis available." : trimmed
    }

    private func readable(_ raw: String?) -> String {
        guard let raw, !raw.isEmpty else { return "Unknown" }
        return raw
            .lowercased()
            .split(separator: "_")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    private func trailerURL(from trailer: AniTrackAPI.AnimeDetailQuery.Data.Page.Medium.Trailer?) -> URL? {
        guard let trailer, let id = trailer.id, let site = trailer.site?.lowercased() else { return nil }

        if site.contains("youtube") {
            return URL(string: "https://www.youtube.com/watch?v=\(id)")
        }
        if site.contains("dailymotion") {
            return URL(string: "https://www.dailymotion.com/video/\(id)")
        }
        return nil
    }

    private func mapRelations(_ edges: [AniTrackAPI.AnimeDetailQuery.Data.Page.Medium.Relations.Edge?]?, currentID: Int) -> [AnimeRelation] {
        var seen: Set<Int> = []

        return (edges ?? []).compactMap { edge in
            guard let edge, let node = edge.node else { return nil }
            guard node.id != currentID else { return nil }
            guard node.type?.rawValue == "ANIME" else { return nil }
            guard !seen.contains(node.id) else { return nil }

            seen.insert(node.id)
            return AnimeRelation(
                id: node.id,
                title: resolveTitle(english: node.title?.english, romaji: node.title?.romaji, fallback: "Unknown Title"),
                relationType: readable(edge.relationType?.rawValue),
                format: readable(node.format?.rawValue),
                score: node.averageScore,
                coverImage: node.coverImage?.extraLarge ?? node.coverImage?.large
            )
        }
    }
}
