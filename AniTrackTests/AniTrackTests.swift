import XCTest
import Apollo
@testable import AniTrack

@MainActor
final class AniTrackTests: XCTestCase {
    override func setUp() {
        super.setUp()
        AniListAuthStore().clear()
    }

    override func tearDown() {
        AniListAuthStore().clear()
        super.tearDown()
    }

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
        let viewModel = HomeViewModel(
            repository: MockAnimeRepository(result: .success(feed)),
            listRepository: MockListRepository(),
            authStore: AniListAuthStore()
        )

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
        let viewModel = HomeViewModel(
            repository: MockAnimeRepository(result: .failure(MockError.failed)),
            listRepository: MockListRepository(),
            authStore: AniListAuthStore()
        )

        await viewModel.load()

        XCTAssertEqual(viewModel.errorText, "Unable to load AniList data right now.")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.popular.isEmpty)
    }

    func testFilteredPopularByCategoryAndSearchText() {
        let naruto = makeAnime(id: 1, title: "Naruto", subtitle: "Shippuden", genres: ["Action"])
        let haikyuu = makeAnime(id: 2, title: "Haikyu!!", subtitle: "Karasuno", genres: ["Sports"])
        let viewModel = HomeViewModel(
            repository: MockAnimeRepository(result: .failure(MockError.failed)),
            listRepository: MockListRepository(),
            authStore: AniListAuthStore()
        )
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

    func testHomeLoadRefreshesTrackedIDsWhenAuthenticated() async {
        let anime = makeAnime(id: 1, title: "Naruto", subtitle: "Naruto", genres: ["Action"])
        let feed = HomeFeed(featured: anime, trending: [anime], continueWatching: [], recommended: [], airingToday: [])
        let authStore = AniListAuthStore()
        authStore.updateToken("token", expiresIn: nil)
        let listRepository = MockListRepository(entries: [makeListEntry(id: 999, mediaID: 1, title: "Naruto")])
        let viewModel = HomeViewModel(
            repository: MockAnimeRepository(result: .success(feed)),
            listRepository: listRepository,
            authStore: authStore
        )

        await viewModel.load()

        XCTAssertTrue(viewModel.isTracked(1))
    }

    func testHomeToggleTrackedRequiresAuthentication() async {
        let anime = makeAnime(id: 1, title: "Naruto", subtitle: "Naruto", genres: ["Action"])
        let viewModel = HomeViewModel(
            repository: MockAnimeRepository(result: .failure(MockError.failed)),
            listRepository: MockListRepository(),
            authStore: AniListAuthStore()
        )

        await viewModel.toggleTracked(for: anime)

        XCTAssertEqual(viewModel.errorText, "Sign in to AniList to save shows to your list.")
    }

    func testHomeToggleTrackedAddsPlanningEntry() async {
        let anime = makeAnime(id: 2, title: "Bleach", subtitle: "Bleach", genres: ["Action"])
        let authStore = AniListAuthStore()
        authStore.updateToken("token", expiresIn: nil)
        let savedEntry = makeListEntry(id: 200, mediaID: 2, title: "Bleach", status: .planning)
        let listRepository = MockListRepository(entryByMediaID: [:], saveResult: savedEntry)
        let viewModel = HomeViewModel(
            repository: MockAnimeRepository(result: .failure(MockError.failed)),
            listRepository: listRepository,
            authStore: authStore
        )

        await viewModel.toggleTracked(for: anime)

        XCTAssertTrue(viewModel.isTracked(2))
        XCTAssertEqual(listRepository.lastSavedPatch?.status, .planning)
        XCTAssertEqual(listRepository.lastSavedPatch?.mediaId, 2)
    }

    func testHomeToggleTrackedDeletesExistingEntry() async {
        let anime = makeAnime(id: 3, title: "One Piece", subtitle: "One Piece", genres: ["Adventure"])
        let authStore = AniListAuthStore()
        authStore.updateToken("token", expiresIn: nil)
        let existingEntry = makeListEntry(id: 303, mediaID: 3, title: "One Piece")
        let listRepository = MockListRepository(entryByMediaID: [3: existingEntry])
        let viewModel = HomeViewModel(
            repository: MockAnimeRepository(result: .failure(MockError.failed)),
            listRepository: listRepository,
            authStore: authStore
        )

        await viewModel.toggleTracked(for: anime)

        XCTAssertFalse(viewModel.isTracked(3))
        XCTAssertEqual(listRepository.deletedIDs, [303])
    }

    func testHomeToggleTrackedSurfacesGraphQLErrorMessage() async {
        let anime = makeAnime(id: 4, title: "Solo Leveling", subtitle: "Solo Leveling", genres: ["Action"])
        let authStore = AniListAuthStore()
        authStore.updateToken("token", expiresIn: nil)
        let listRepository = MockListRepository(error: AniListServiceError.graphQLErrors(["AniList rejected the mutation"]))
        let viewModel = HomeViewModel(
            repository: MockAnimeRepository(result: .failure(MockError.failed)),
            listRepository: listRepository,
            authStore: authStore
        )

        await viewModel.toggleTracked(for: anime)

        XCTAssertEqual(viewModel.errorText, "AniList rejected the mutation")
        XCTAssertFalse(viewModel.isUpdating(4))
    }

    func testDetailReminderScheduleSuccessSetsMessage() async {
        let detail = makeDetail(id: 99, title: "Spy x Family")
        let airing = AiringScheduleInfo(episode: 11, airingAt: Date().addingTimeInterval(86_400))
        let scheduler = MockReminderScheduler(result: .success(false))
        let authStore = AniListAuthStore()
        let viewModel = AnimeDetailViewModel(
            animeID: detail.id,
            repository: MockAnimeRepository(
                result: .failure(MockError.failed),
                detailHandler: { _ in detail },
                nextAiringHandler: { _ in airing }
            ),
            listRepository: MockListRepository(),
            authStore: authStore,
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
        let authStore = AniListAuthStore()
        let viewModel = AnimeDetailViewModel(
            animeID: detail.id,
            repository: MockAnimeRepository(
                result: .failure(MockError.failed),
                detailHandler: { _ in detail },
                nextAiringHandler: { _ in airing }
            ),
            listRepository: MockListRepository(),
            authStore: authStore,
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
        let authStore = AniListAuthStore()
        let viewModel = AnimeDetailViewModel(
            animeID: detail.id,
            repository: MockAnimeRepository(
                result: .failure(MockError.failed),
                detailHandler: { _ in detail },
                nextAiringHandler: { _ in airing }
            ),
            listRepository: MockListRepository(),
            authStore: authStore,
            reminderScheduler: scheduler
        )

        await viewModel.load()
        await viewModel.scheduleReminderForNextEpisode()

        XCTAssertEqual(viewModel.errorText, "Allow notifications in Settings to receive airing reminders.")
        XCTAssertNil(viewModel.reminderMessage)
    }

    func testDetailLoadsWhenNextAiringFails() async {
        let detail = makeDetail(id: 42, title: "Frieren")
        let authStore = AniListAuthStore()
        let viewModel = AnimeDetailViewModel(
            animeID: detail.id,
            repository: MockAnimeRepository(
                result: .failure(MockError.failed),
                detailHandler: { _ in detail },
                nextAiringHandler: { _ in throw MockError.failed }
            ),
            listRepository: MockListRepository(),
            authStore: authStore
        )

        await viewModel.load()

        XCTAssertEqual(viewModel.detail?.id, detail.id)
        XCTAssertNil(viewModel.errorText)
        XCTAssertNil(viewModel.nextAiring)
    }

    func testDetailLoadReflectsTrackedEntry() async {
        let detail = makeDetail(id: 42, title: "Frieren")
        let authStore = AniListAuthStore()
        authStore.updateToken("token", expiresIn: nil)
        let listRepository = MockListRepository(entryByMediaID: [42: makeListEntry(id: 11, mediaID: 42, title: "Frieren")])
        let viewModel = AnimeDetailViewModel(
            animeID: detail.id,
            repository: MockAnimeRepository(
                result: .failure(MockError.failed),
                detailHandler: { _ in detail }
            ),
            listRepository: listRepository,
            authStore: authStore
        )

        await viewModel.load()

        XCTAssertTrue(viewModel.isTracked)
    }

    func testDetailToggleTrackedRequiresAuthentication() async {
        let viewModel = AnimeDetailViewModel(
            animeID: 42,
            repository: MockAnimeRepository(result: .failure(MockError.failed)),
            listRepository: MockListRepository(),
            authStore: AniListAuthStore()
        )

        await viewModel.toggleTracked()

        XCTAssertEqual(viewModel.errorText, "Sign in to AniList to save shows to your list.")
    }

    func testDetailToggleTrackedSavesPlanningEntry() async {
        let detail = makeDetail(id: 44, title: "Mob Psycho 100")
        let authStore = AniListAuthStore()
        authStore.updateToken("token", expiresIn: nil)
        let savedEntry = makeListEntry(id: 444, mediaID: 44, title: "Mob Psycho 100", status: .planning)
        let listRepository = MockListRepository(entryByMediaID: [:], saveResult: savedEntry)
        let viewModel = AnimeDetailViewModel(
            animeID: detail.id,
            repository: MockAnimeRepository(result: .failure(MockError.failed), detailHandler: { _ in detail }),
            listRepository: listRepository,
            authStore: authStore
        )

        await viewModel.load()
        await viewModel.toggleTracked()

        XCTAssertTrue(viewModel.isTracked)
        XCTAssertEqual(viewModel.reminderMessage, "Added to My List.")
        XCTAssertEqual(listRepository.lastSavedPatch?.status, .planning)
    }

    func testDetailToggleTrackedDeletesExistingEntry() async {
        let detail = makeDetail(id: 45, title: "Dungeon Meshi")
        let authStore = AniListAuthStore()
        authStore.updateToken("token", expiresIn: nil)
        let existingEntry = makeListEntry(id: 545, mediaID: 45, title: "Dungeon Meshi")
        let listRepository = MockListRepository(entryByMediaID: [45: existingEntry])
        let viewModel = AnimeDetailViewModel(
            animeID: detail.id,
            repository: MockAnimeRepository(result: .failure(MockError.failed), detailHandler: { _ in detail }),
            listRepository: listRepository,
            authStore: authStore
        )

        await viewModel.load()
        await viewModel.toggleTracked()

        XCTAssertFalse(viewModel.isTracked)
        XCTAssertEqual(listRepository.deletedIDs, [545])
        XCTAssertNil(viewModel.reminderMessage)
    }

    func testMyListLoadUsesCachedViewerWhenAvailable() async {
        let cachedViewer = AniListViewer(id: 10, name: "xav")
        let entry = makeListEntry(id: 1, mediaID: 1, title: "Naruto")
        let repository = MockListRepository(cachedViewer: cachedViewer, entries: [entry])
        let viewModel = MyListViewModel(repository: repository)

        await viewModel.load()

        XCTAssertEqual(viewModel.viewer?.id, 10)
        XCTAssertEqual(viewModel.entries.count, 1)
        XCTAssertEqual(repository.fetchViewerCallCount, 0)
    }

    func testMyListLoadUnauthorizedRequiresAuthentication() async {
        let repository = MockListRepository(error: AniListServiceError.unauthorized)
        let viewModel = MyListViewModel(repository: repository)

        await viewModel.load()

        XCTAssertTrue(viewModel.requiresAuthentication)
        XCTAssertEqual(viewModel.errorText, "Session expired. Please sign in again.")
        XCTAssertTrue(viewModel.entries.isEmpty)
    }

    func testMyListDeleteRemovesEntryAndSetsMessage() async {
        let entry = makeListEntry(id: 1, mediaID: 1, title: "Naruto")
        let repository = MockListRepository(cachedViewer: AniListViewer(id: 10, name: "xav"), entries: [entry])
        let viewModel = MyListViewModel(repository: repository)
        viewModel.entries = [entry]

        await viewModel.delete(entry: entry)

        XCTAssertTrue(viewModel.entries.isEmpty)
        XCTAssertEqual(viewModel.actionMessage, "Removed Naruto from your list.")
        XCTAssertEqual(repository.deletedIDs, [1])
    }

    func testMyListUpdateReplacesExistingEntry() async {
        let oldEntry = makeListEntry(id: 1, mediaID: 1, title: "Naruto", status: .planning)
        let updatedEntry = makeListEntry(id: 1, mediaID: 1, title: "Naruto", status: .current)
        let repository = MockListRepository(saveResult: updatedEntry)
        let viewModel = MyListViewModel(repository: repository)
        viewModel.entries = [oldEntry]
        var patch = MediaListEntryPatch(id: 1, mediaId: 1)
        patch.status = .current

        await viewModel.update(entry: oldEntry, with: patch)

        XCTAssertEqual(viewModel.entries.first?.status, .current)
        XCTAssertEqual(viewModel.actionMessage, "Saved changes for Naruto.")
    }

    func testMyListApplyBulkUpdatesEntriesAndClearsSelection() async {
        let first = makeListEntry(id: 1, mediaID: 1, title: "Naruto", status: .planning)
        let second = makeListEntry(id: 2, mediaID: 2, title: "Bleach", status: .planning)
        let updatedFirst = makeListEntry(id: 1, mediaID: 1, title: "Naruto", status: .completed)
        let updatedSecond = makeListEntry(id: 2, mediaID: 2, title: "Bleach", status: .completed)
        let repository = MockListRepository(bulkResult: [updatedFirst, updatedSecond])
        let viewModel = MyListViewModel(repository: repository)
        viewModel.entries = [first, second]
        viewModel.selectionMode = true
        viewModel.selectedIDs = [1, 2]
        var patch = MediaListBulkPatch()
        patch.status = .completed

        await viewModel.applyBulk(patch: patch)

        XCTAssertEqual(viewModel.entries.map(\.status), [.completed, .completed])
        XCTAssertEqual(viewModel.actionMessage, "Updated 2 entries.")
        XCTAssertFalse(viewModel.selectionMode)
        XCTAssertTrue(viewModel.selectedIDs.isEmpty)
        XCTAssertFalse(viewModel.isBulkApplying)
    }

    func testAniListListRepositoryFetchViewerPersistsViewer() async throws {
        let authStore = AniListAuthStore()
        authStore.updateToken("token", expiresIn: nil)
        let service = MockGraphQLService()
        service.viewerData = try makeViewerData(id: 7, name: "xavitordera")
        let repository = AniListListRepository(service: service, authStore: authStore)

        let viewer = try await repository.fetchViewer()

        XCTAssertEqual(viewer.id, 7)
        XCTAssertEqual(authStore.viewer?.id, 7)
        XCTAssertEqual(authStore.viewer?.name, "xavitordera")
    }

    func testAniListListRepositoryFetchMyListEntriesMapsCollection() async throws {
        let authStore = AniListAuthStore()
        authStore.updateToken("token", expiresIn: nil)
        let service = MockGraphQLService()
        service.viewerData = try makeViewerData(id: 7, name: "xav")
        service.mediaListCollectionData = try makeMediaListCollectionData()
        let repository = AniListListRepository(service: service, authStore: authStore)

        let entries = try await repository.fetchMyListEntries()

        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.media.id, 42)
        XCTAssertEqual(entries.first?.status, .current)
    }

    func testAniListListRepositoryFetchEntryUsesCachedViewerID() async throws {
        let authStore = AniListAuthStore()
        authStore.updateToken("token", expiresIn: nil)
        authStore.updateViewer(id: 7, name: "xav")
        let service = MockGraphQLService()
        service.mediaListEntryData = try makeMediaListEntryData(mediaID: 42, entryID: 55, status: "PLANNING")
        let repository = AniListListRepository(service: service, authStore: authStore)

        let entry = try await repository.fetchEntry(mediaID: 42)

        XCTAssertEqual(entry?.id, 55)
        XCTAssertEqual(entry?.media.id, 42)
        XCTAssertEqual(entry?.status, .planning)
        XCTAssertEqual(service.viewerFetchCount, 0)
        XCTAssertEqual(service.lastMediaListEntryMediaID, 42)
    }

    func testAniListListRepositoryDeleteEntryMapsMutationResult() async throws {
        let authStore = AniListAuthStore()
        authStore.updateToken("token", expiresIn: nil)
        let service = MockGraphQLService()
        service.deleteMediaListEntryData = try makeDeleteMediaListEntryData(deleted: true)
        let repository = AniListListRepository(service: service, authStore: authStore)

        let deleted = try await repository.deleteEntry(id: 999)

        XCTAssertTrue(deleted)
        XCTAssertEqual(service.lastDeletedEntryID, 999)
    }

    func testAniListListRepositorySaveEntryFallsBackToFetchEntryWhenMutationPayloadIncomplete() async throws {
        let authStore = AniListAuthStore()
        authStore.updateToken("token", expiresIn: nil)
        authStore.updateViewer(id: 7, name: "xav")
        let service = MockGraphQLService()
        service.saveMediaListEntryData = try makeIncompleteSaveMutationData(id: 55)
        service.mediaListEntryData = try makeMediaListEntryData(mediaID: 42, entryID: 55, status: "PLANNING")
        let repository = AniListListRepository(service: service, authStore: authStore)
        var patch = MediaListEntryPatch(mediaId: 42)
        patch.status = .planning

        let entry = try await repository.saveEntry(patch)

        XCTAssertEqual(entry.id, 55)
        XCTAssertEqual(entry.media.id, 42)
        XCTAssertEqual(entry.status, .planning)
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

    private func makeListEntry(id: Int, mediaID: Int, title: String, status: MediaListStatus = .current) -> MediaListEntry {
        let anime = makeAnime(id: mediaID, title: title, subtitle: title, genres: ["Action"])
        return MediaListEntry(
            id: id,
            media: anime,
            status: status,
            score: 80,
            progress: 4,
            startedAt: FuzzyDate(year: 2024, month: 10, day: 1),
            completedAt: nil,
            groupName: "Watching",
            isCustomList: false
        )
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }

    private func makeViewerData(id: Int, name: String) throws -> AniTrackAPI.ViewerQuery.Data {
        try AniTrackAPI.ViewerQuery.Data(data: [
            "viewer": [
                "__typename": "User",
                "id": id,
                "name": name
            ]
        ])
    }

    private func makeMediaListCollectionData() throws -> AniTrackAPI.MediaListCollectionQuery.Data {
        try AniTrackAPI.MediaListCollectionQuery.Data(data: [
            "collection": [
                "__typename": "MediaListCollection",
                "lists": [[
                    "__typename": "MediaListGroup",
                    "name": "Watching",
                    "isCustomList": false,
                    "entries": [[
                        "__typename": "MediaList",
                        "id": 55,
                        "status": "CURRENT",
                        "score": 80.0,
                        "progress": 4,
                        "startedAt": [
                            "__typename": "FuzzyDate",
                            "year": 2024,
                            "month": 10,
                            "day": 1
                        ],
                        "completedAt": NSNull(),
                        "media": [
                            "__typename": "Media",
                            "id": 42,
                            "episodes": 12,
                            "title": [
                                "__typename": "MediaTitle",
                                "romaji": "Frieren",
                                "english": "Frieren",
                                "userPreferred": "Frieren"
                            ],
                            "coverImage": [
                                "__typename": "MediaCoverImage",
                                "large": "large",
                                "extraLarge": "xl"
                            ]
                        ]
                    ]]
                ]]
            ]
        ])
    }

    private func makeMediaListEntryData(mediaID: Int, entryID: Int, status: String) throws -> AniTrackAPI.MediaListEntryQuery.Data {
        try AniTrackAPI.MediaListEntryQuery.Data(data: [
            "entry": [
                "__typename": "MediaList",
                "id": entryID,
                "status": status,
                "score": 90.0,
                "progress": 1,
                "startedAt": NSNull(),
                "completedAt": NSNull(),
                "media": [
                    "__typename": "Media",
                    "id": mediaID,
                    "episodes": 24,
                    "title": [
                        "__typename": "MediaTitle",
                        "romaji": "Mob Psycho 100",
                        "english": "Mob Psycho 100",
                        "userPreferred": "Mob Psycho 100"
                    ],
                    "coverImage": [
                        "__typename": "MediaCoverImage",
                        "large": "large",
                        "extraLarge": "xl"
                    ]
                ]
            ]
        ])
    }

    private func makeIncompleteSaveMutationData(id: Int) throws -> AniTrackAPI.SaveMediaListEntryMutation.Data {
        try AniTrackAPI.SaveMediaListEntryMutation.Data(data: [
            "saved": [
                "__typename": "MediaList",
                "id": id,
                "status": "PLANNING",
                "score": NSNull(),
                "progress": NSNull(),
                "startedAt": NSNull(),
                "completedAt": NSNull(),
                "media": NSNull()
            ]
        ])
    }

    private func makeDeleteMediaListEntryData(deleted: Bool) throws -> AniTrackAPI.DeleteMediaListEntryMutation.Data {
        try AniTrackAPI.DeleteMediaListEntryMutation.Data(data: [
            "result": [
                "__typename": "Deleted",
                "deleted": deleted
            ]
        ])
    }
}

private enum MockError: Error {
    case failed
}

private final class MockGraphQLService: AniListGraphQLServing {
    var viewerData: AniTrackAPI.ViewerQuery.Data?
    var mediaListCollectionData: AniTrackAPI.MediaListCollectionQuery.Data?
    var mediaListEntryData: AniTrackAPI.MediaListEntryQuery.Data?
    var saveMediaListEntryData: AniTrackAPI.SaveMediaListEntryMutation.Data?
    var deleteMediaListEntryData: AniTrackAPI.DeleteMediaListEntryMutation.Data?
    private(set) var viewerFetchCount = 0
    private(set) var lastMediaListEntryMediaID: Int?
    private(set) var lastDeletedEntryID: Int?

    func fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy) async throws -> Query.Data {
        switch query {
        case is AniTrackAPI.ViewerQuery:
            viewerFetchCount += 1
            return viewerData as! Query.Data
        case let query as AniTrackAPI.MediaListCollectionQuery:
            _ = query
            return mediaListCollectionData as! Query.Data
        case let query as AniTrackAPI.MediaListEntryQuery:
            if case let .some(mediaID) = query.mediaId {
                lastMediaListEntryMediaID = mediaID
            } else {
                lastMediaListEntryMediaID = nil
            }
            return mediaListEntryData as! Query.Data
        default:
            throw MockError.failed
        }
    }

    func perform<Mutation: GraphQLMutation>(mutation: Mutation, publishResultToStore: Bool) async throws -> Mutation.Data {
        switch mutation {
        case is AniTrackAPI.SaveMediaListEntryMutation:
            return saveMediaListEntryData as! Mutation.Data
        case let mutation as AniTrackAPI.DeleteMediaListEntryMutation:
            if case let .some(id) = mutation.id {
                lastDeletedEntryID = id
            } else {
                lastDeletedEntryID = nil
            }
            return deleteMediaListEntryData as! Mutation.Data
        default:
            throw MockError.failed
        }
    }
}
