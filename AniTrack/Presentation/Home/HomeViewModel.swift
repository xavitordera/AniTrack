import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory = "All"
    @Published var categories = ["All", "Action", "Adventure", "Fantasy", "Sci-Fi", "Romance", "Sports"]

    @Published var featured: AnimeMedia?
    @Published var popular: [AnimeMedia] = []
    @Published var continueWatching: [ContinueWatchingItem] = []
    @Published var recommended: [AnimeMedia] = []
    @Published var airingToday: [AnimeMedia] = []

    @Published var isLoading = false
    @Published var errorText: String?
    @Published private(set) var trackedIDs: Set<Int> = []
    @Published private(set) var updatingTrackedIDs: Set<Int> = []

    private let repository: AnimeRepository
    private let listRepository: MyListRepository
    private let authStore: AniListAuthStore

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
            continueWatching = feed.continueWatching
            recommended = feed.recommended
            airingToday = feed.airingToday
            await refreshTrackedIDs()
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

    private func refreshTrackedIDs() async {
        guard authStore.accessToken != nil else {
            trackedIDs = []
            return
        }

        do {
            let entries = try await listRepository.fetchMyListEntries()
            trackedIDs = Set(entries.map(\.media.id))
        } catch {
            trackedIDs = []
        }
    }
}
