import Foundation

@MainActor
final class MyListViewModel: ObservableObject {
    @Published var viewer: AniListViewer?
    @Published var entries: [MediaListEntry] = []
    @Published var isLoading = false
    @Published var errorText: String?
    @Published var actionMessage: String?
    @Published var selectionMode = false
    @Published var selectedIDs: Set<Int> = []
    @Published var isBulkApplying = false
    @Published var requiresAuthentication = false

    private let repository: MyListRepository

    init(repository: MyListRepository) {
        self.repository = repository
    }

    var groupedEntries: [(status: MediaListStatus, entries: [MediaListEntry])] {
        let grouped = Dictionary(grouping: entries) { $0.status }
        return MediaListStatus.allCases
            .compactMap { status in
                guard let group = grouped[status], !group.isEmpty else { return nil }
                return (status, group)
            }
    }

    func load() async {
        isLoading = true
        errorText = nil
        actionMessage = nil
        requiresAuthentication = false

        do {
            viewer = try await repository.fetchViewer()
            entries = try await repository.fetchMyListEntries()
        } catch {
            handle(error: error, fallbackMessage: "Unable to load your list right now.")
        }

        isLoading = false
    }

    func reload() async {
        await load()
    }

    func toggleSelectionMode() {
        selectionMode.toggle()
        if !selectionMode {
            selectedIDs.removeAll()
        }
    }

    func setSelection(for entry: MediaListEntry) {
        if selectedIDs.contains(entry.id) {
            selectedIDs.remove(entry.id)
        } else {
            selectedIDs.insert(entry.id)
        }
    }

    func isSelected(_ entry: MediaListEntry) -> Bool {
        selectedIDs.contains(entry.id)
    }

    func delete(entry: MediaListEntry) async {
        do {
            let deleted = try await repository.deleteEntry(id: entry.id)
            if deleted {
                entries.removeAll { $0.id == entry.id }
                actionMessage = "Removed \(entry.media.title) from your list."
            }
        } catch {
            handle(error: error, fallbackMessage: "Unable to remove the entry right now.")
        }
    }

    func update(entry: MediaListEntry, with patch: MediaListEntryPatch) async {
        do {
            let updated = try await repository.saveEntry(patch)
            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                entries[index] = updated
                actionMessage = "Saved changes for \(entry.media.title)."
            } else {
                entries.insert(updated, at: 0)
                actionMessage = "Added \(entry.media.title) to your list."
            }
        } catch {
            handle(error: error, fallbackMessage: "Unable to save the entry right now.")
        }
    }

    func applyBulk(patch: MediaListBulkPatch) async {
        guard !selectedIDs.isEmpty else { return }
        isBulkApplying = true
        errorText = nil
        actionMessage = nil

        let updates = entries
            .filter { selectedIDs.contains($0.id) }
            .map { entry -> MediaListEntryPatch in
                var base = MediaListEntryPatch(id: entry.id, mediaId: entry.media.id)
                base.status = patch.status ?? entry.status
                base.progress = patch.progress ?? entry.progress
                base.score = patch.score ?? entry.score
                base.startedAt = patch.startedAt
                base.completedAt = patch.completedAt
                return base
            }

        do {
            let updatedEntries = try await repository.bulkSave(updates)
            for updated in updatedEntries {
                if let index = entries.firstIndex(where: { $0.id == updated.id }) {
                    entries[index] = updated
                }
            }
            actionMessage = "Updated \(updatedEntries.count) entries."
        } catch {
            handle(error: error, fallbackMessage: "Bulk update failed.")
        }

        isBulkApplying = false
        selectedIDs.removeAll()
        selectionMode = false
    }

    private func handle(error: Error, fallbackMessage: String) {
        if let serviceError = error as? AniListServiceError {
            switch serviceError {
            case .unauthorized:
                requiresAuthentication = true
                entries.removeAll()
                errorText = "Session expired. Please sign in again."
                return
            default:
                break
            }
        }
        errorText = fallbackMessage
    }
}
