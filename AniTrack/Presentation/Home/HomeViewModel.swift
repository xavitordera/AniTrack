import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory = "All"
    @Published var categories = ["All", "Action", "Adventure", "Fantasy", "Sci-Fi", "Romance", "Sports"]

    @Published var featured: AnimeMedia?
    @Published var popular: [AnimeMedia] = []
    @Published var continueTracking: [HomeTrackingItem] = []
    @Published var recommended: [AnimeMedia] = []
    @Published var airingToday: [AnimeMedia] = []

    @Published var isLoading = false
    @Published var errorText: String?
    @Published private(set) var trackedIDs: Set<Int> = []
    @Published private(set) var updatingTrackedIDs: Set<Int> = []
    @Published private(set) var updatingTrackingIDs: Set<Int> = []

    private let repository: AnimeRepository
    private let listRepository: MyListRepository
    private let authStore: AniListAuthStore
    private var trackingEntries: [MediaListEntry] = []
    private var nextAiringByMediaID: [Int: AiringScheduleInfo] = [:]

    init(repository: AnimeRepository, listRepository: MyListRepository, authStore: AniListAuthStore) {
        self.repository = repository
        self.listRepository = listRepository
        self.authStore = authStore
    }

    func load() async {
        isLoading = true
        errorText = nil

        do {
            let feed = try await repository.fetchHomeFeed()
            featured = feed.featured
            popular = feed.trending
            recommended = feed.recommended
            airingToday = feed.airingToday
            await refreshTrackingState()
        } catch {
            errorText = "Unable to load AniList data right now."
        }

        isLoading = false
    }

    func isTracked(_ mediaID: Int) -> Bool {
        trackedIDs.contains(mediaID)
    }

    func isUpdating(_ mediaID: Int) -> Bool {
        updatingTrackedIDs.contains(mediaID)
    }

    func isUpdatingTracking(_ mediaID: Int) -> Bool {
        updatingTrackingIDs.contains(mediaID)
    }

    var isSignedIn: Bool {
        authStore.accessToken != nil
    }

    var shouldShowTrackingPrompt: Bool {
        !isSignedIn || continueTracking.isEmpty
    }

    func toggleTracked(for anime: AnimeMedia) async {
        guard authStore.accessToken != nil else {
            errorText = "Sign in to AniList to save shows to your list."
            return
        }

        updatingTrackedIDs.insert(anime.id)
        defer { updatingTrackedIDs.remove(anime.id) }

        do {
            if let existingEntry = try await listRepository.fetchEntry(mediaID: anime.id) {
                let deleted = try await listRepository.deleteEntry(id: existingEntry.id)
                if deleted {
                    trackedIDs.remove(anime.id)
                }
            } else {
                var patch = MediaListEntryPatch(mediaId: anime.id)
                patch.status = .planning
                _ = try await listRepository.saveEntry(patch)
                trackedIDs.insert(anime.id)
            }
        } catch {
            if let serviceError = error as? AniListServiceError {
                switch serviceError {
                case .unauthorized:
                    errorText = "Your AniList session expired. Please sign in again."
                case .graphQLErrors(let messages):
                    errorText = messages.first ?? "Couldn't update your list right now."
                default:
                    errorText = "Couldn't update your list right now."
                }
            } else {
                errorText = "Couldn't update your list right now."
            }
        }
    }

    func browseTrendingCTA() {
        selectedCategory = "All"
        searchText = ""
    }

    func performPrimaryTrackingAction(for item: HomeTrackingItem) async {
        guard authStore.accessToken != nil else {
            errorText = "Sign in to AniList to update your watch progress."
            return
        }

        guard item.primaryAction != .viewDetails else {
            return
        }

        updatingTrackingIDs.insert(item.id)
        defer { updatingTrackingIDs.remove(item.id) }

        var patch = MediaListEntryPatch(id: item.listEntryID, mediaId: item.media.id)
        patch.status = item.status

        switch item.primaryAction {
        case .incrementEpisode:
            patch.progress = item.watchedEpisodes + 1
        case .markComplete:
            patch.progress = item.totalEpisodes ?? item.watchedEpisodes
            patch.status = .completed
        case .viewDetails:
            break
        }

        do {
            let updatedEntry = try await listRepository.saveEntry(patch)
            updateTrackingEntry(updatedEntry)
        } catch {
            if let serviceError = error as? AniListServiceError {
                switch serviceError {
                case .unauthorized:
                    errorText = "Your AniList session expired. Please sign in again."
                case .graphQLErrors(let messages):
                    errorText = messages.first ?? "Couldn't update your watch progress right now."
                default:
                    errorText = "Couldn't update your watch progress right now."
                }
            } else {
                errorText = "Couldn't update your watch progress right now."
            }
        }
    }

    var filteredPopular: [AnimeMedia] {
        popular.filter { anime in
            let matchesCategory = selectedCategory == "All" || anime.genres.contains {
                $0.caseInsensitiveCompare(selectedCategory) == .orderedSame
            }
            let matchesSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || anime.title.localizedCaseInsensitiveContains(searchText)
            || anime.subtitle.localizedCaseInsensitiveContains(searchText)

            return matchesCategory && matchesSearch
        }
    }

    private func refreshTrackingState() async {
        guard authStore.accessToken != nil else {
            trackedIDs = []
            trackingEntries = []
            nextAiringByMediaID = [:]
            continueTracking = []
            return
        }

        do {
            let entries = try await listRepository.fetchMyListEntries()
            trackedIDs = Set(entries.map(\.media.id))
            trackingEntries = entries.filter { $0.status == .current || $0.status == .repeating }
            await enrichTrackingEntries()
            continueTracking = makeTrackingItems()
        } catch {
            trackedIDs = []
            trackingEntries = []
            nextAiringByMediaID = [:]
            continueTracking = []
        }
    }

    private func enrichTrackingEntries() async {
        let candidateIDs = Array(
            trackingEntries
                .sorted(by: sortTrackingEntries(_:_:))
                .prefix(6)
                .map(\.media.id)
        )
        nextAiringByMediaID = [:]

        await withTaskGroup(of: (Int, AiringScheduleInfo?).self) { group in
            for mediaID in candidateIDs {
                group.addTask { [repository] in
                    let airing = try? await repository.fetchNextAiring(mediaID: mediaID)
                    return (mediaID, airing)
                }
            }

            for await (mediaID, airing) in group {
                if let airing {
                    nextAiringByMediaID[mediaID] = airing
                }
            }
        }
    }

    private func makeTrackingItems() -> [HomeTrackingItem] {
        trackingEntries
            .map { entry in
                let nextAiring = nextAiringByMediaID[entry.media.id]
                return HomeTrackingItem(
                    media: entry.media,
                    listEntryID: entry.id,
                    status: entry.status,
                    watchedEpisodes: max(entry.progress ?? 0, 0),
                    totalEpisodes: entry.media.episodes,
                    nextAiringEpisode: nextAiring?.episode,
                    nextAiringDate: nextAiring?.airingAt
                )
            }
            .sorted(by: sortTrackingItems(_:_:))
            .prefix(6)
            .map { $0 }
    }

    private func updateTrackingEntry(_ updatedEntry: MediaListEntry) {
        trackedIDs.insert(updatedEntry.media.id)

        if let index = trackingEntries.firstIndex(where: { $0.id == updatedEntry.id }) {
            if updatedEntry.status == .current || updatedEntry.status == .repeating {
                trackingEntries[index] = updatedEntry
            } else {
                trackingEntries.remove(at: index)
            }
        } else if updatedEntry.status == .current || updatedEntry.status == .repeating {
            trackingEntries.append(updatedEntry)
        }

        continueTracking = makeTrackingItems()
    }

    private func sortTrackingEntries(_ lhs: MediaListEntry, _ rhs: MediaListEntry) -> Bool {
        let lhsKnown = hasKnownRemainingEpisodes(lhs)
        let rhsKnown = hasKnownRemainingEpisodes(rhs)
        if lhsKnown != rhsKnown {
            return lhsKnown && !rhsKnown
        }

        let lhsProgress = lhs.progress ?? 0
        let rhsProgress = rhs.progress ?? 0
        if lhsProgress != rhsProgress {
            return lhsProgress > rhsProgress
        }

        return lhs.media.title.localizedCaseInsensitiveCompare(rhs.media.title) == .orderedAscending
    }

    private func sortTrackingItems(_ lhs: HomeTrackingItem, _ rhs: HomeTrackingItem) -> Bool {
        let lhsPriority = trackingPriority(for: lhs)
        let rhsPriority = trackingPriority(for: rhs)
        if lhsPriority != rhsPriority {
            return lhsPriority < rhsPriority
        }

        if let lhsDate = lhs.nextAiringDate, let rhsDate = rhs.nextAiringDate, lhsDate != rhsDate {
            return lhsDate < rhsDate
        }

        if lhs.watchedEpisodes != rhs.watchedEpisodes {
            return lhs.watchedEpisodes > rhs.watchedEpisodes
        }

        return lhs.media.title.localizedCaseInsensitiveCompare(rhs.media.title) == .orderedAscending
    }

    private func trackingPriority(for item: HomeTrackingItem) -> Int {
        if let totalEpisodes = item.totalEpisodes, totalEpisodes > 0, item.watchedEpisodes < totalEpisodes {
            return 0
        }
        if item.nextAiringDate != nil {
            return 1
        }
        if item.watchedEpisodes > 0 {
            return 2
        }
        return 3
    }

    private func hasKnownRemainingEpisodes(_ entry: MediaListEntry) -> Bool {
        guard let totalEpisodes = entry.media.episodes, totalEpisodes > 0 else { return false }
        return (entry.progress ?? 0) < totalEpisodes
    }
}
