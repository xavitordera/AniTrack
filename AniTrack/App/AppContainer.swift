import Foundation

final class AppContainer {
    let authStore = AniListAuthStore()
    let graphQLService: AniListGraphQLService
    let animeRepository: AnimeRepository
    let listRepository: MyListRepository

    init() {
        self.graphQLService = AniListGraphQLService(tokenProvider: { [weak authStore] in
            authStore?.accessToken
        })
        self.animeRepository = AniListAnimeRepository(service: graphQLService)
        self.listRepository = AniListListRepository(service: graphQLService)
    }
}
