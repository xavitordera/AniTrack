import Foundation

struct AniListViewer: Hashable {
    let id: Int
    let name: String?
}

enum MediaListStatus: String, CaseIterable, Codable {
    case planning = "PLANNING"
    case current = "CURRENT"
    case completed = "COMPLETED"
    case onHold = "PAUSED"
    case dropped = "DROPPED"
    case repeating = "REPEATING"

    var displayName: String {
        switch self {
        case .planning: return "Planning"
        case .current: return "Watching"
        case .completed: return "Completed"
        case .onHold: return "On Hold"
        case .dropped: return "Dropped"
        case .repeating: return "Rewatching"
        }
    }
}

struct FuzzyDate: Hashable {
    let year: Int?
    let month: Int?
    let day: Int?

    var localizedDescription: String {
        guard let year else { return "" }
        let components = [
            month.map { String(format: "%02d", $0) },
            day.map { String(format: "%02d", $0) }
        ].compactMap { $0 }
        let datePart = components.joined(separator: "-")
        return datePart.isEmpty ? ""
            : "\(year)-\(datePart)"
    }
}

struct FuzzyDateInput {
    let year: Int?
    let month: Int?
    let day: Int?
}

struct MediaListEntry: Identifiable, Hashable {
    let id: Int
    let media: AnimeMedia
    let status: MediaListStatus
    let score: Double?
    let progress: Int?
    let startedAt: FuzzyDate?
    let completedAt: FuzzyDate?
    let groupName: String?
    let isCustomList: Bool

    var displaySubtitle: String {
        let highlights = Array(media.genres.prefix(2))
        if !highlights.isEmpty {
            return highlights.joined(separator: " • ")
        }
        return media.subtitle
    }
}

struct MediaListEntryPatch {
    let id: Int?
    let mediaId: Int
    var status: MediaListStatus?
    var score: Double?
    var progress: Int?
    var startedAt: FuzzyDateInput?
    var completedAt: FuzzyDateInput?

    init(id: Int? = nil, mediaId: Int) {
        self.id = id
        self.mediaId = mediaId
    }
}

struct MediaListBulkPatch {
    var status: MediaListStatus?
    var progress: Int?
    var score: Double?
    var startedAt: FuzzyDateInput?
    var completedAt: FuzzyDateInput?
}
