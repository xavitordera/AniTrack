import Foundation

final class AniListStatsService: StatsService {
    private let service: AniListGraphQLService

    init(service: AniListGraphQLService) {
        self.service = service
    }

    func fetchAnimeStats() async throws -> StatsDashboard {
        let payload = try await service.fetch(query: AniTrackAPI.UserAnimeStatisticsQuery())
        guard let viewer = payload.viewer else {
            throw AniListServiceError.emptyData
        }

        var fallbackEntries: [AniTrackAPI.UserAnimeStatisticsFallbackQuery.Data.MediaListCollection.List.Entry] = []
        let animeStats = viewer.statistics?.anime

        if needsFallback(for: animeStats) {
            let fallback = try await service.fetch(
                query: AniTrackAPI.UserAnimeStatisticsFallbackQuery(userId: .some(viewer.id))
            )
            fallbackEntries = flattenEntries(from: fallback)
        }

        return mapDashboard(
            userName: viewer.name,
            animeStats: animeStats,
            fallbackEntries: fallbackEntries
        )
    }

    private func needsFallback(
        for stats: AniTrackAPI.UserAnimeStatisticsQuery.Data.Viewer.Statistics.Anime?
    ) -> Bool {
        guard let stats else { return true }
        return stats.meanScore <= 0
            || (stats.genres ?? []).isEmpty
            || (stats.studios ?? []).isEmpty
            || (stats.statuses ?? []).isEmpty
    }

    private func flattenEntries(
        from fallback: AniTrackAPI.UserAnimeStatisticsFallbackQuery.Data
    ) -> [AniTrackAPI.UserAnimeStatisticsFallbackQuery.Data.MediaListCollection.List.Entry] {
        (fallback.mediaListCollection?.lists ?? [])
            .flatMap { list -> [AniTrackAPI.UserAnimeStatisticsFallbackQuery.Data.MediaListCollection.List.Entry] in
                guard let list else { return [] }
                return (list.entries ?? []).compactMap { $0 }
            }
    }

    private func mapDashboard(
        userName: String,
        animeStats: AniTrackAPI.UserAnimeStatisticsQuery.Data.Viewer.Statistics.Anime?,
        fallbackEntries: [AniTrackAPI.UserAnimeStatisticsFallbackQuery.Data.MediaListCollection.List.Entry]
    ) -> StatsDashboard {
        let fallbackSummary = fallbackSummary(from: fallbackEntries)

        let builtInStatusItems = (animeStats?.statuses ?? [])
            .compactMap { item -> StatsStatusItem? in
                guard let item,
                      let rawStatus = item.status?.rawValue,
                      let status = MediaListStatus(rawValue: rawStatus) else {
                    return nil
                }
                return StatsStatusItem(status: status, count: item.count)
            }

        let statusBreakdown = normalizedStatusBreakdown(
            builtInStatus: builtInStatusItems,
            fallback: fallbackSummary.statusBreakdown
        )

        let completedCount = statusBreakdown.first(where: { $0.status == .completed })?.count
            ?? fallbackSummary.completedAnime

        let overview = StatsOverview(
            completedAnime: completedCount,
            episodesWatched: animeStats?.episodesWatched ?? fallbackSummary.episodesWatched,
            minutesWatched: animeStats?.minutesWatched ?? fallbackSummary.minutesWatched,
            averageScore: (animeStats?.meanScore ?? 0) > 0 ? (animeStats?.meanScore ?? 0) : fallbackSummary.averageScore
        )

        let genres = mapGenres(from: animeStats?.genres, fallback: fallbackSummary.genres)
        let studios = mapStudios(from: animeStats?.studios, fallback: fallbackSummary.studios)

        return StatsDashboard(
            userName: userName,
            overview: overview,
            genres: genres,
            studios: studios,
            statusBreakdown: statusBreakdown
        )
    }

    private func mapGenres(
        from builtIn: [AniTrackAPI.UserAnimeStatisticsQuery.Data.Viewer.Statistics.Anime.Genre?]?,
        fallback: [StatsCountItem]
    ) -> [StatsCountItem] {
        let items = (builtIn ?? []).compactMap { item -> StatsCountItem? in
            guard let item,
                  let genre = item.genre?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !genre.isEmpty else {
                return nil
            }
            return StatsCountItem(name: genre, count: item.count)
        }

        if !items.isEmpty {
            return items.sorted(by: { $0.count > $1.count })
        }

        return fallback
    }

    private func mapStudios(
        from builtIn: [AniTrackAPI.UserAnimeStatisticsQuery.Data.Viewer.Statistics.Anime.Studio?]?,
        fallback: [StatsCountItem]
    ) -> [StatsCountItem] {
        let items = (builtIn ?? []).compactMap { item -> StatsCountItem? in
            guard let item,
                  let name = item.studio?.name.trimmingCharacters(in: .whitespacesAndNewlines),
                  !name.isEmpty else {
                return nil
            }
            return StatsCountItem(name: name, count: item.count)
        }

        if !items.isEmpty {
            return Array(items.sorted(by: { $0.count > $1.count }).prefix(5))
        }

        return Array(fallback.prefix(5))
    }

    private func normalizedStatusBreakdown(
        builtInStatus: [StatsStatusItem],
        fallback: [StatsStatusItem]
    ) -> [StatsStatusItem] {
        let preferredOrder: [MediaListStatus] = [.current, .completed, .planning, .dropped, .onHold]
        let source = builtInStatus.isEmpty ? fallback : builtInStatus
        let byStatus = Dictionary(uniqueKeysWithValues: source.map { ($0.status, $0.count) })

        return preferredOrder.map { status in
            StatsStatusItem(status: status, count: byStatus[status] ?? 0)
        }
    }

    private func fallbackSummary(
        from entries: [AniTrackAPI.UserAnimeStatisticsFallbackQuery.Data.MediaListCollection.List.Entry]
    ) -> (
        completedAnime: Int,
        episodesWatched: Int,
        minutesWatched: Int,
        averageScore: Double,
        genres: [StatsCountItem],
        studios: [StatsCountItem],
        statusBreakdown: [StatsStatusItem]
    ) {
        var completed = 0
        var episodesWatched = 0
        var minutesWatched = 0
        var scores: [Double] = []

        var genreCount: [String: Int] = [:]
        var studioCount: [String: Int] = [:]
        var statusCount: [MediaListStatus: Int] = [:]

        for entry in entries {
            guard let rawStatus = entry.status?.rawValue,
                  let status = MediaListStatus(rawValue: rawStatus) else {
                continue
            }

            statusCount[status, default: 0] += 1
            if status == .completed {
                completed += 1
            }

            let progress = max(entry.progress ?? 0, 0)
            episodesWatched += progress

            let duration = max(entry.media?.duration ?? 0, 0)
            minutesWatched += progress * duration

            if let score = entry.score, score > 0 {
                scores.append(score)
            }

            let uniqueGenres = Set((entry.media?.genres ?? []).compactMap { $0 })
            for genre in uniqueGenres where !genre.isEmpty {
                genreCount[genre, default: 0] += 1
            }

            let uniqueStudios = Set((entry.media?.studios?.nodes ?? []).compactMap { $0?.name })
            for studio in uniqueStudios where !studio.isEmpty {
                studioCount[studio, default: 0] += 1
            }
        }

        let averageScore = scores.isEmpty ? 0 : scores.reduce(0, +) / Double(scores.count)

        let genres = genreCount
            .map { StatsCountItem(name: $0.key, count: $0.value) }
            .sorted(by: { $0.count > $1.count })

        let studios = studioCount
            .map { StatsCountItem(name: $0.key, count: $0.value) }
            .sorted(by: { $0.count > $1.count })

        let breakdown = statusCount
            .map { StatsStatusItem(status: $0.key, count: $0.value) }

        return (completed, episodesWatched, minutesWatched, averageScore, genres, studios, breakdown)
    }
}
