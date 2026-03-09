import Foundation
import ApolloAPI

final class AniListListRepository: MyListRepository {
    private let service: AniListGraphQLService

    init(service: AniListGraphQLService) {
        self.service = service
    }

    func fetchViewer() async throws -> AniListViewer {
        let payload = try await service.fetch(query: AniTrackAPI.ViewerQuery())

        guard let viewer = payload.viewer else {
            throw AniListServiceError.emptyData
        }

        return AniListViewer(id: viewer.id, name: viewer.name)
    }

    func fetchMyListEntries() async throws -> [MediaListEntry] {
        let payload = try await service.fetch(
            query: AniTrackAPI.MediaListCollectionQuery(type: .some(GraphQLEnum(.anime)))
        )

        let entries = payload.collection?.lists?.flatMap { list in mapList(list) } ?? []

        return entries.sorted(by: { order(for: $0.status) < order(for: $1.status) })
    }

    func saveEntry(_ update: MediaListEntryPatch) async throws -> MediaListEntry {
        let payload = try await service.perform(
            mutation: AniTrackAPI.SaveMediaListEntryMutation(
                id: nullable(update.id),
                mediaId: .some(update.mediaId),
                status: nullable(update.status.map { GraphQLEnum(schemaStatus(from: $0)) }),
                score: nullable(update.score),
                progress: nullable(update.progress),
                startedAt: nullable(inputDate(from: update.startedAt)),
                completedAt: nullable(inputDate(from: update.completedAt))
            )
        )

        guard let entry = payload.saved.flatMap({ mapSavedEntry($0) }) else {
            throw AniListServiceError.emptyData
        }

        return entry
    }

    func deleteEntry(id: Int) async throws -> Bool {
        let payload = try await service.perform(
            mutation: AniTrackAPI.DeleteMediaListEntryMutation(id: .some(id))
        )

        return payload.result?.deleted ?? false
    }

    func bulkSave(_ updates: [MediaListEntryPatch]) async throws -> [MediaListEntry] {
        var results: [MediaListEntry] = []
        for update in updates {
            let entry = try await saveEntry(update)
            results.append(entry)
        }
        return results
    }

    // MARK: - Private

    private func mapList(_ list: AniTrackAPI.MediaListCollectionQuery.Data.Collection.List?) -> [MediaListEntry] {
        guard let list else { return [] }
        let groupName = list.name
        let isCustom = list.isCustomList ?? false
        return (list.entries ?? []).compactMap { mapEntry($0, groupName: groupName, isCustomList: isCustom) }
    }

    private func mapEntry(
        _ dto: AniTrackAPI.MediaListCollectionQuery.Data.Collection.List.Entry?,
        groupName: String?,
        isCustomList: Bool
    ) -> MediaListEntry? {
        guard let dto, let status = mapStatus(dto.status) else {
            return nil
        }

        guard let mediaDTO = dto.media else {
            return nil
        }

        let mediaTitle = resolveTitle(
            romaji: mediaDTO.title?.romaji,
            english: mediaDTO.title?.english,
            fallback: mediaDTO.title?.userPreferred ?? "Unknown Title"
        )
        let subtitle = mediaDTO.title?.userPreferred ?? mediaDTO.title?.romaji ?? ""
        let media = AnimeMedia(
            id: mediaDTO.id,
            title: mediaTitle,
            subtitle: subtitle,
            description: "",
            genres: [],
            score: nil,
            episodes: mediaDTO.episodes,
            bannerImage: nil,
            coverImage: mediaDTO.coverImage?.extraLarge ?? mediaDTO.coverImage?.large
        )

        return MediaListEntry(
            id: dto.id,
            media: media,
            status: status,
            score: dto.score,
            progress: dto.progress,
            startedAt: fuzzyDate(year: dto.startedAt?.year, month: dto.startedAt?.month, day: dto.startedAt?.day),
            completedAt: fuzzyDate(year: dto.completedAt?.year, month: dto.completedAt?.month, day: dto.completedAt?.day),
            groupName: groupName,
            isCustomList: isCustomList
        )
    }

    private func mapSavedEntry(_ dto: AniTrackAPI.SaveMediaListEntryMutation.Data.Saved) -> MediaListEntry? {
        guard let status = mapStatus(dto.status), let mediaDTO = dto.media else {
            return nil
        }

        let mediaTitle = resolveTitle(
            romaji: mediaDTO.title?.romaji,
            english: mediaDTO.title?.english,
            fallback: mediaDTO.title?.userPreferred ?? "Unknown Title"
        )
        let subtitle = mediaDTO.title?.userPreferred ?? mediaDTO.title?.romaji ?? ""
        let media = AnimeMedia(
            id: mediaDTO.id,
            title: mediaTitle,
            subtitle: subtitle,
            description: "",
            genres: [],
            score: nil,
            episodes: mediaDTO.episodes,
            bannerImage: nil,
            coverImage: mediaDTO.coverImage?.extraLarge ?? mediaDTO.coverImage?.large
        )

        return MediaListEntry(
            id: dto.id,
            media: media,
            status: status,
            score: dto.score,
            progress: dto.progress,
            startedAt: fuzzyDate(year: dto.startedAt?.year, month: dto.startedAt?.month, day: dto.startedAt?.day),
            completedAt: fuzzyDate(year: dto.completedAt?.year, month: dto.completedAt?.month, day: dto.completedAt?.day),
            groupName: nil,
            isCustomList: false
        )
    }

    private func fuzzyDate(year: Int?, month: Int?, day: Int?) -> FuzzyDate? {
        guard year != nil || month != nil || day != nil else { return nil }
        return FuzzyDate(year: year, month: month, day: day)
    }

    private func inputDate(from fuzzy: FuzzyDateInput?) -> AniTrackAPI.FuzzyDateInput? {
        guard let fuzzy else { return nil }
        return AniTrackAPI.FuzzyDateInput(
            year: nullable(fuzzy.year),
            month: nullable(fuzzy.month),
            day: nullable(fuzzy.day)
        )
    }

    private func nullable<T>(_ value: T?) -> GraphQLNullable<T> {
        value.map(GraphQLNullable.some) ?? .none
    }

    private func mapStatus(_ status: GraphQLEnum<AniTrackAPI.MediaListStatus>?) -> MediaListStatus? {
        switch status?.value {
        case .current:
            return .current
        case .planning:
            return .planning
        case .completed:
            return .completed
        case .paused:
            return .onHold
        case .dropped:
            return .dropped
        case .repeating:
            return .repeating
        case nil:
            return nil
        }
    }

    private func schemaStatus(from status: MediaListStatus) -> AniTrackAPI.MediaListStatus {
        switch status {
        case .current:
            return .current
        case .planning:
            return .planning
        case .completed:
            return .completed
        case .onHold:
            return .paused
        case .dropped:
            return .dropped
        case .repeating:
            return .repeating
        }
    }

    private func order(for status: MediaListStatus) -> Int {
        switch status {
        case .current: return 0
        case .planning: return 1
        case .completed: return 2
        case .onHold: return 3
        case .dropped: return 4
        case .repeating: return 5
        }
    }

    private func resolveTitle(romaji: String?, english: String?, fallback: String) -> String {
        if let english, !english.isEmpty {
            return english
        }
        if let romaji, !romaji.isEmpty {
            return romaji
        }
        return fallback
    }
}
