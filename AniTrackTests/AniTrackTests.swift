import XCTest
@testable import AniTrack

@MainActor
final class AniTrackTests: XCTestCase {
    func testSeasonHelperMapsWinterMonth() {
        let date = makeDate(year: 2026, month: 1, day: 15)
        let value = MediaSeasonHelper.currentSeasonAndYear(date: date)
        XCTAssertEqual(value.season, "WINTER")
        XCTAssertEqual(value.year, 2026)
    }

    func testSeasonHelperMapsSpringMonth() {
        let date = makeDate(year: 2026, month: 4, day: 10)
        let value = MediaSeasonHelper.currentSeasonAndYear(date: date)
        XCTAssertEqual(value.season, "SPRING")
        XCTAssertEqual(value.year, 2026)
    }

    func testSeasonHelperMapsSummerMonth() {
        let date = makeDate(year: 2026, month: 7, day: 8)
        let value = MediaSeasonHelper.currentSeasonAndYear(date: date)
        XCTAssertEqual(value.season, "SUMMER")
        XCTAssertEqual(value.year, 2026)
    }

    func testSeasonHelperMapsFallMonth() {
        let date = makeDate(year: 2026, month: 10, day: 1)
        let value = MediaSeasonHelper.currentSeasonAndYear(date: date)
        XCTAssertEqual(value.season, "FALL")
        XCTAssertEqual(value.year, 2026)
    }

    func testLoadSuccessPopulatesState() async {
        let naruto = makeAnime(id: 1, title: "Naruto", subtitle: "Naruto", genres: ["Action"])
        let haikyuu = makeAnime(id: 2, title: "Haikyu!!", subtitle: "Haikyuu", genres: ["Sports"])
        let feed = HomeFeed(
            featured: naruto,
            trending: [naruto, haikyuu],
            continueWatching: [ContinueWatchingItem(id: 1, anime: naruto, progress: 0.4)],
            recommended: [haikyuu],
            airingToday: [naruto]
        )
        let viewModel = HomeViewModel(repository: MockAnimeRepository(result: .success(feed)))

        await viewModel.load()

        XCTAssertEqual(viewModel.featured?.id, 1)
        XCTAssertEqual(viewModel.popular.count, 2)
        XCTAssertEqual(viewModel.continueWatching.count, 1)
        XCTAssertEqual(viewModel.recommended.count, 1)
        XCTAssertEqual(viewModel.airingToday.count, 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorText)
    }

    func testLoadFailureSetsError() async {
        let viewModel = HomeViewModel(repository: MockAnimeRepository(result: .failure(MockError.failed)))

        await viewModel.load()

        XCTAssertEqual(viewModel.errorText, "Unable to load AniList data right now.")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.popular.isEmpty)
    }

    func testFilteredPopularByCategoryAndSearchText() {
        let naruto = makeAnime(id: 1, title: "Naruto", subtitle: "Shippuden", genres: ["Action"])
        let haikyuu = makeAnime(id: 2, title: "Haikyu!!", subtitle: "Karasuno", genres: ["Sports"])
        let viewModel = HomeViewModel(repository: MockAnimeRepository(result: .failure(MockError.failed)))
        viewModel.popular = [naruto, haikyuu]

        viewModel.selectedCategory = "Sports"
        XCTAssertEqual(viewModel.filteredPopular.map(\.id), [2])

        viewModel.selectedCategory = "All"
        viewModel.searchText = "shippu"
        XCTAssertEqual(viewModel.filteredPopular.map(\.id), [1])
    }

    func testDiscoverLoadInitialSuccess() async {
        let page = DiscoverPage(
            media: [
                makeAnime(id: 10, title: "Chainsaw Man", subtitle: "Chainsaw Man", genres: ["Action"]),
                makeAnime(id: 11, title: "Blue Lock", subtitle: "Blue Lock", genres: ["Sports"])
            ],
            hasNextPage: true
        )
        let viewModel = DiscoverViewModel(
            repository: MockAnimeRepository(
                result: .failure(MockError.failed),
                discoverHandler: { _, _ in page }
            )
        )

        await viewModel.loadInitial()

        XCTAssertEqual(viewModel.items.count, 2)
        XCTAssertTrue(viewModel.items.contains(where: { $0.id == 10 }))
        XCTAssertNil(viewModel.errorText)
        XCTAssertFalse(viewModel.isLoadingInitial)
    }

    func testDiscoverLoadInitialFailureSetsError() async {
        let viewModel = DiscoverViewModel(
            repository: MockAnimeRepository(
                result: .failure(MockError.failed),
                discoverHandler: { _, _ in throw MockError.failed }
            )
        )

        await viewModel.loadInitial()

        XCTAssertTrue(viewModel.items.isEmpty)
        XCTAssertEqual(viewModel.errorText, "Unable to load discover results right now.")
    }

    func testDetailReminderScheduleSuccessSetsMessage() async {
        let detail = makeDetail(id: 99, title: "Spy x Family")
        let airing = AiringScheduleInfo(episode: 11, airingAt: Date().addingTimeInterval(86_400))
        let scheduler = MockReminderScheduler(result: .success(false))
        let viewModel = AnimeDetailViewModel(
            animeID: detail.id,
            repository: MockAnimeRepository(
                result: .failure(MockError.failed),
                detailHandler: { _ in detail },
                nextAiringHandler: { _ in airing }
            ),
            reminderScheduler: scheduler
        )

        await viewModel.load()
        await viewModel.scheduleReminderForNextEpisode()

        XCTAssertEqual(viewModel.reminderMessage, "Reminder set for airing day.")
        XCTAssertNil(viewModel.errorText)
        XCTAssertEqual(scheduler.lastAnimeID, detail.id)
        XCTAssertEqual(scheduler.lastEpisode, airing.episode)
    }

    func testDetailReminderAlreadyScheduledShowsMessage() async {
        let detail = makeDetail(id: 77, title: "Dandadan")
        let airing = AiringScheduleInfo(episode: 5, airingAt: Date().addingTimeInterval(72_000))
        let scheduler = MockReminderScheduler(result: .success(true))
        let viewModel = AnimeDetailViewModel(
            animeID: detail.id,
            repository: MockAnimeRepository(
                result: .failure(MockError.failed),
                detailHandler: { _ in detail },
                nextAiringHandler: { _ in airing }
            ),
            reminderScheduler: scheduler
        )

        await viewModel.load()
        await viewModel.scheduleReminderForNextEpisode()

        XCTAssertEqual(viewModel.reminderMessage, "Reminder already scheduled for this episode.")
        XCTAssertNil(viewModel.errorText)
    }

    func testDetailReminderPermissionDeniedSetsError() async {
        let detail = makeDetail(id: 55, title: "Blue Lock")
        let airing = AiringScheduleInfo(episode: 3, airingAt: Date().addingTimeInterval(43_200))
        let scheduler = MockReminderScheduler(result: .failure(ReminderScheduleError.permissionDenied))
        let viewModel = AnimeDetailViewModel(
            animeID: detail.id,
            repository: MockAnimeRepository(
                result: .failure(MockError.failed),
                detailHandler: { _ in detail },
                nextAiringHandler: { _ in airing }
            ),
            reminderScheduler: scheduler
        )

        await viewModel.load()
        await viewModel.scheduleReminderForNextEpisode()

        XCTAssertEqual(viewModel.errorText, "Allow notifications in Settings to receive airing reminders.")
        XCTAssertNil(viewModel.reminderMessage)
    }

    private func makeAnime(id: Int, title: String, subtitle: String, genres: [String]) -> AnimeMedia {
        AnimeMedia(
            id: id,
            title: title,
            subtitle: subtitle,
            description: "desc",
            genres: genres,
            score: 80,
            episodes: 12,
            bannerImage: nil,
            coverImage: nil
        )
    }

    private func makeDetail(id: Int, title: String) -> AnimeDetail {
        AnimeDetail(
            id: id,
            title: title,
            subtitle: title,
            description: "desc",
            genres: ["Action"],
            studios: [],
            score: 84,
            popularity: 100_000,
            favorites: 20_000,
            episodes: 12,
            duration: 24,
            seasonLabel: "Fall 2025",
            status: "RELEASING",
            format: "TV",
            source: "MANGA",
            trailerURL: nil,
            bannerImage: nil,
            coverImage: nil,
            relations: []
        )
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }
}

private enum MockError: Error {
    case failed
}

private struct MockAnimeRepository: AnimeRepository {
    let result: Result<HomeFeed, Error>
    var discoverHandler: (Int, DiscoverFilters) async throws -> DiscoverPage = { _, _ in
        DiscoverPage(media: [], hasNextPage: false)
    }
    var detailHandler: (Int) async throws -> AnimeDetail = { _ in
        throw MockError.failed
    }
    var nextAiringHandler: (Int) async throws -> AiringScheduleInfo? = { _ in
        nil
    }

    func fetchHomeFeed() async throws -> HomeFeed {
        try result.get()
    }

    func fetchAnimeDetail(id: Int) async throws -> AnimeDetail {
        try await detailHandler(id)
    }

    func fetchDiscover(page: Int, filters: DiscoverFilters) async throws -> DiscoverPage {
        try await discoverHandler(page, filters)
    }

    func fetchNextAiring(mediaID: Int) async throws -> AiringScheduleInfo? {
        try await nextAiringHandler(mediaID)
    }
}

private final class MockReminderScheduler: ReminderScheduling {
    private let result: Result<Bool, Error>
    private(set) var lastAnimeID: Int?
    private(set) var lastEpisode: Int?

    init(result: Result<Bool, Error>) {
        self.result = result
    }

    func scheduleAiringReminder(animeID: Int, animeTitle: String, episode: Int, airingAt: Date) async throws -> Bool {
        lastAnimeID = animeID
        lastEpisode = episode
        return try result.get()
    }
}
