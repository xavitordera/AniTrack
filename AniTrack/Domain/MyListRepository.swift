import Foundation

// sourcery: AutoMockable
protocol MyListRepository {
    func cachedViewer() -> AniListViewer?
    func fetchViewer() async throws -> AniListViewer
    func fetchEntry(mediaID: Int) async throws -> MediaListEntry?
    func fetchMyListEntries() async throws -> [MediaListEntry]
    func saveEntry(_ update: MediaListEntryPatch) async throws -> MediaListEntry
    func deleteEntry(id: Int) async throws -> Bool
    func bulkSave(_ updates: [MediaListEntryPatch]) async throws -> [MediaListEntry]
}
