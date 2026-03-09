import Foundation

protocol MyListRepository {
    func cachedViewer() -> AniListViewer?
    func fetchViewer() async throws -> AniListViewer
    func fetchMyListEntries() async throws -> [MediaListEntry]
    func saveEntry(_ update: MediaListEntryPatch) async throws -> MediaListEntry
    func deleteEntry(id: Int) async throws -> Bool
    func bulkSave(_ updates: [MediaListEntryPatch]) async throws -> [MediaListEntry]
}
