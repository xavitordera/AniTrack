import Foundation

protocol AnimeRepository {
    func fetchHomeFeed() async throws -> HomeFeed
    func fetchAnimeDetail(id: Int) async throws -> AnimeDetail
    func fetchDiscover(page: Int, filters: DiscoverFilters) async throws -> DiscoverPage
    func fetchNextAiring(mediaID: Int) async throws -> AiringScheduleInfo?
}
