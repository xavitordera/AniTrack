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

    private let repository: AnimeRepository

    init(repository: AnimeRepository) {
        self.repository = repository
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
        } catch {
            errorText = "Unable to load AniList data right now."
        }

        isLoading = false
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
}
