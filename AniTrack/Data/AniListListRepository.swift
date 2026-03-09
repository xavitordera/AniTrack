import Foundation

final class AniListListRepository: MyListRepository {
    private let service: AniListGraphQLService

    init(service: AniListGraphQLService) {
        self.service = service
    }

    func fetchViewer() async throws -> AniListViewer {
        let payload = try await service.execute(
            query: AniListQueries.viewer,
            variables: [:],
            responseType: ViewerResponseDTO.self
        )

        guard let viewer = payload.viewer else {
            throw AniListServiceError.emptyData
        }

        return AniListViewer(id: viewer.id, name: viewer.name)
    }

    func fetchMyListEntries() async throws -> [MediaListEntry] {
        let payload = try await service.execute(
            query: AniListQueries.mediaListCollection,
            variables: ["type": .string("ANIME")],
            responseType: MediaListCollectionResponseDTO.self
        )

        let entries = payload.collection?.lists?.flatMap { list in
            mapList(list)
        } ?? []

        return entries.sorted(by: { order(for: $0.status) < order(for: $1.status) })
    }

    func saveEntry(_ update: MediaListEntryPatch) async throws -> MediaListEntry {
        let variables = variables(from: update)
        let payload = try await service.execute(
            query: AniListQueries.saveMediaListEntry,
            variables: variables,
            responseType: SaveMediaListEntryResponseDTO.self
        )

        guard let dto = payload.saved else {
            throw AniListServiceError.emptyData
        }

        guard let entry = mapEntry(dto, groupName: nil, isCustomList: false) else {
            throw AniListServiceError.emptyData
        }

        return entry
    }

    func deleteEntry(id: Int) async throws -> Bool {
        let payload = try await service.execute(
            query: AniListQueries.deleteMediaListEntry,
            variables: ["id": .int(id)],
            responseType: DeleteMediaListEntryResponseDTO.self
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

    private func mapList(_ list: MediaListDTO) -> [MediaListEntry] {
        let groupName = list.name
        let isCustom = list.isCustomList ?? false
        return (list.entries ?? []).compactMap { mapEntry($0, groupName: groupName, isCustomList: isCustom) }
    }

    private func mapEntry(_ dto: MediaListEntryDTO, groupName: String?, isCustomList: Bool) -> MediaListEntry? {
        guard let rawStatus = dto.status, let status = MediaListStatus(rawValue: rawStatus) else {
            return nil
        }

        let mediaTitle = resolveTitle(romaji: dto.media.title.romaji, english: dto.media.title.english, fallback: dto.media.title.userPreferred ?? "Unknown Title")
        let subtitle = dto.media.title.userPreferred ?? dto.media.title.romaji ?? ""
        let media = AnimeMedia(
            id: dto.media.id,
            title: mediaTitle,
            subtitle: subtitle,
            description: "",
            genres: [],
            score: nil,
            episodes: dto.media.episodes,
            bannerImage: nil,
            coverImage: dto.media.coverImage?.extraLarge ?? dto.media.coverImage?.large
        )

        return MediaListEntry(
            id: dto.id,
            media: media,
            status: status,
            score: dto.score,
            progress: dto.progress,
            startedAt: fuzzyDate(from: dto.startedAt),
            completedAt: fuzzyDate(from: dto.completedAt),
            groupName: groupName,
            isCustomList: isCustomList
        )
    }

    private func fuzzyDate(from dto: FuzzyDateDTO?) -> FuzzyDate? {
        guard let dto else { return nil }
        return FuzzyDate(year: dto.year, month: dto.month, day: dto.day)
    }

    private func variables(from patch: MediaListEntryPatch) -> [String: GraphQLValue] {
        var variables: [String: GraphQLValue] = [
            "mediaId": .int(patch.mediaId)
        ]
        if let id = patch.id {
            variables["id"] = .int(id)
        }
        if let status = patch.status {
            variables["status"] = .string(status.rawValue)
        }
        if let score = patch.score {
            variables["score"] = .double(score)
        }
        if let progress = patch.progress {
            variables["progress"] = .int(progress)
        }
        if let startedAt = patch.startedAt, let object = object(from: startedAt) {
            variables["startedAt"] = object
        }
        if let completedAt = patch.completedAt, let object = object(from: completedAt) {
            variables["completedAt"] = object
        }
        return variables
    }

    private func object(from fuzzy: FuzzyDateInput) -> GraphQLValue? {
        var dictionary: [String: GraphQLValue] = [:]
        if let year = fuzzy.year {
            dictionary["year"] = .int(year)
        }
        if let month = fuzzy.month {
            dictionary["month"] = .int(month)
        }
        if let day = fuzzy.day {
            dictionary["day"] = .int(day)
        }
        return dictionary.isEmpty ? nil : .object(dictionary)
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
