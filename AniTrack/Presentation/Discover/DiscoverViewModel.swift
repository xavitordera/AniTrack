import Foundation

@MainActor
final class DiscoverViewModel: ObservableObject {
    struct SortOption: Identifiable, Hashable {
        let id: String
        let title: String

        static let all: [SortOption] = [
            SortOption(id: "POPULARITY_DESC", title: "Popular"),
            SortOption(id: "SCORE_DESC", title: "Top Rated"),
            SortOption(id: "TRENDING_DESC", title: "Trending"),
            SortOption(id: "START_DATE_DESC", title: "Newest")
        ]
    }

    @Published var items: [AnimeMedia] = []
    @Published var isLoadingInitial = false
    @Published var isLoadingMore = false
    @Published var errorText: String?

    @Published var searchText = ""
    @Published var selectedGenres: Set<String> = []
    @Published var selectedSeason: String?
    @Published var selectedYear: Int?
    @Published var selectedFormat: String?
    @Published var selectedStatus: String?
    @Published var selectedSort = SortOption.all[0]

    let availableGenres: [String] = ["Action", "Adventure", "Comedy", "Drama", "Fantasy", "Horror", "Mystery", "Psychological", "Romance", "Sci-Fi", "Slice of Life", "Sports", "Supernatural", "Thriller"]
    let availableFormats: [String] = ["TV", "MOVIE", "OVA", "ONA", "SPECIAL"]
    let availableStatuses: [String] = ["FINISHED", "RELEASING", "NOT_YET_RELEASED", "CANCELLED", "HIATUS"]
    let availableSeasons: [String] = ["WINTER", "SPRING", "SUMMER", "FALL"]

    var availableYears: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        return Array((current - 25)...(current + 1)).reversed()
    }

    private let repository: AnimeRepository
    private var currentPage = 1
    private var hasNextPage = true

    init(repository: AnimeRepository) {
        self.repository = repository
    }

    func loadInitial() async {
        guard !isLoadingInitial else { return }
        isLoadingInitial = true
        errorText = nil
        currentPage = 1
        hasNextPage = true

        do {
            let page = try await repository.fetchDiscover(page: currentPage, filters: currentFilters)
            items = page.media
            hasNextPage = page.hasNextPage
        } catch {
            items = []
            errorText = "Unable to load discover results right now."
        }

        isLoadingInitial = false
    }

    func loadMoreIfNeeded(currentItem item: AnimeMedia) async {
        guard hasNextPage, !isLoadingMore, !isLoadingInitial else { return }
        guard let currentIndex = items.firstIndex(where: { $0.id == item.id }) else { return }

        let thresholdIndex = max(items.count - 6, 0)
        guard currentIndex >= thresholdIndex else { return }

        isLoadingMore = true
        do {
            let nextPageNumber = currentPage + 1
            let page = try await repository.fetchDiscover(page: nextPageNumber, filters: currentFilters)
            currentPage = nextPageNumber
            hasNextPage = page.hasNextPage
            mergePageItems(page.media)
        } catch {
            errorText = "Unable to load more titles right now."
        }
        isLoadingMore = false
    }

    func applyFilters() async {
        await loadInitial()
    }

    func clearFilters() {
        selectedGenres = []
        selectedSeason = nil
        selectedYear = nil
        selectedFormat = nil
        selectedStatus = nil
        selectedSort = SortOption.all[0]
    }

    var activeFilterCount: Int {
        var count = 0
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { count += 1 }
        if !selectedGenres.isEmpty { count += 1 }
        if selectedSeason != nil { count += 1 }
        if selectedYear != nil { count += 1 }
        if selectedFormat != nil { count += 1 }
        if selectedStatus != nil { count += 1 }
        if selectedSort.id != SortOption.all[0].id { count += 1 }
        return count
    }

    var currentFilters: DiscoverFilters {
        DiscoverFilters(
            search: searchText,
            genres: selectedGenres.sorted(),
            season: selectedSeason,
            seasonYear: selectedYear,
            format: selectedFormat,
            status: selectedStatus,
            sort: selectedSort.id
        )
    }

    private func mergePageItems(_ newItems: [AnimeMedia]) {
        let existingIDs = Set(items.map(\.id))
        let uniqueItems = newItems.filter { !existingIDs.contains($0.id) }
        items.append(contentsOf: uniqueItems)
    }
}
