import Foundation

final class AniListAnimeRepository: AnimeRepository {
    private let service: AniListGraphQLService

    init(service: AniListGraphQLService = AniListGraphQLService()) {
        self.service = service
    }

    func fetchHomeFeed() async throws -> HomeFeed {
        let seasonData = MediaSeasonHelper.currentSeasonAndYear()
        let variables: [String: GraphQLValue] = [
            "page": .int(1),
            "perPage": .int(12),
            "season": .string(seasonData.season),
            "seasonYear": .int(seasonData.year)
        ]

        let payload = try await service.execute(
            query: AniListQueries.homeFeed,
            variables: variables,
            responseType: HomeFeedResponseDTO.self
        )

        let trending = mapMediaList(payload.trending.media)
        let seasonPopular = mapMediaList(payload.seasonPopular.media)
        let recommended = mapMediaList(payload.recommended.media)
        let airing = mapMediaList(payload.airing.media)

        let featured = trending.first ?? seasonPopular.first
        let continueWatching = Array(seasonPopular.prefix(3)).enumerated().map { index, anime in
            let defaultProgress = [0.36, 0.58, 0.79]
            return ContinueWatchingItem(
                id: anime.id,
                anime: anime,
                progress: defaultProgress[min(index, defaultProgress.count - 1)]
            )
        }

        return HomeFeed(
            featured: featured,
            trending: seasonPopular,
            continueWatching: continueWatching,
            recommended: recommended,
            airingToday: airing
        )
    }

    func fetchAnimeDetail(id: Int) async throws -> AnimeDetail {
        let payload = try await service.execute(
            query: AniListQueries.animeDetail,
            variables: [
                "page": .int(1),
                "id": .int(id),
                "type": .string("ANIME"),
                "isAdult": .bool(false)
            ],
            responseType: AnimeDetailResponseDTO.self
        )

        guard let dto = payload.page.media?.compactMap({ $0 }).first else {
            throw AniListServiceError.emptyData
        }

        let title = resolveTitle(english: dto.title?.english, romaji: dto.title?.romaji, fallback: "Unknown Title")
        let subtitle = dto.title?.native ?? dto.title?.romaji ?? ""
        let studios = (dto.studios?.nodes ?? [])
            .compactMap { $0?.name?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let relations = mapRelations(dto.relations?.edges, currentID: dto.id)
        let seasonLabel = "\(dto.season?.capitalized ?? "Unknown") \(dto.seasonYear.map(String.init) ?? "")".trimmingCharacters(in: .whitespaces)

        return AnimeDetail(
            id: dto.id,
            title: title,
            subtitle: subtitle,
            description: cleanDescription(dto.description),
            genres: dto.genres ?? [],
            studios: studios,
            score: dto.averageScore,
            popularity: dto.popularity,
            favorites: dto.favourites,
            episodes: dto.episodes,
            duration: dto.duration,
            seasonLabel: seasonLabel,
            status: readable(dto.status),
            format: readable(dto.format),
            source: readable(dto.source),
            trailerURL: trailerURL(from: dto.trailer),
            bannerImage: dto.bannerImage,
            coverImage: dto.coverImage?.extraLarge ?? dto.coverImage?.large,
            relations: relations
        )
    }

    func fetchDiscover(page: Int, filters: DiscoverFilters) async throws -> DiscoverPage {
        var variables: [String: GraphQLValue] = [
            "page": .int(max(1, page)),
            "type": .string("ANIME"),
            "isAdult": .bool(false),
            "sort": .array([.string(filters.sort)])
        ]

        let search = filters.search.trimmingCharacters(in: .whitespacesAndNewlines)
        if !search.isEmpty {
            variables["search"] = .string(search)
        }
        if let season = filters.season {
            variables["season"] = .string(season)
        }
        if let seasonYear = filters.seasonYear {
            variables["seasonYear"] = .int(seasonYear)
        }
        if let format = filters.format {
            variables["format"] = .array([.string(format)])
        }
        if let status = filters.status {
            variables["status"] = .string(status)
        }
        if !filters.genres.isEmpty {
            variables["genres"] = .array(filters.genres.map { .string($0) })
        }

        let payload = try await service.execute(
            query: AniListQueries.discoverAnime,
            variables: variables,
            responseType: DiscoverResponseDTO.self
        )

        return DiscoverPage(
            media: mapMediaList(payload.page.media),
            hasNextPage: payload.page.pageInfo?.hasNextPage ?? false
        )
    }

    func fetchNextAiring(mediaID: Int) async throws -> AiringScheduleInfo? {
        let payload = try await service.execute(
            query: AniListQueries.nextAiring,
            variables: ["mediaId": .int(mediaID)],
            responseType: NextAiringResponseDTO.self
        )

        guard
            let schedule = payload.airingSchedule,
            let episode = schedule.episode,
            let airingAt = schedule.airingAt
        else {
            return nil
        }

        return AiringScheduleInfo(
            episode: episode,
            airingAt: Date(timeIntervalSince1970: TimeInterval(airingAt))
        )
    }

    private func mapMediaList(_ mediaList: [MediaDTO?]?) -> [AnimeMedia] {
        (mediaList ?? []).compactMap { dto in
            guard let dto else { return nil }
            let resolvedTitle = resolveTitle(
                english: dto.title.english,
                romaji: dto.title.romaji,
                fallback: "Unknown Title"
            )
            let cleanedDescription = cleanDescription(dto.description)

            return AnimeMedia(
                id: dto.id,
                title: resolvedTitle,
                subtitle: dto.title.romaji ?? "",
                description: cleanedDescription,
                genres: dto.genres ?? [],
                score: dto.averageScore,
                episodes: dto.episodes,
                bannerImage: dto.bannerImage,
                coverImage: dto.coverImage?.extraLarge ?? dto.coverImage?.large
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

    private func trailerURL(from trailer: MediaTrailerDTO?) -> URL? {
        guard let trailer, let id = trailer.id, let site = trailer.site?.lowercased() else { return nil }

        if site.contains("youtube") {
            return URL(string: "https://www.youtube.com/watch?v=\(id)")
        }
        if site.contains("dailymotion") {
            return URL(string: "https://www.dailymotion.com/video/\(id)")
        }
        return nil
    }

    private func mapRelations(_ edges: [MediaRelationEdgeDTO?]?, currentID: Int) -> [AnimeRelation] {
        var seen: Set<Int> = []

        return (edges ?? []).compactMap { edge in
            guard let edge, let node = edge.node else { return nil }
            guard node.id != currentID else { return nil }
            guard (node.type ?? "ANIME") == "ANIME" else { return nil }
            guard !seen.contains(node.id) else { return nil }

            seen.insert(node.id)
            return AnimeRelation(
                id: node.id,
                title: resolveTitle(english: node.title?.english, romaji: node.title?.romaji, fallback: "Unknown Title"),
                relationType: readable(edge.relationType),
                format: readable(node.format),
                score: node.averageScore,
                coverImage: node.coverImage?.extraLarge ?? node.coverImage?.large
            )
        }
    }
}
