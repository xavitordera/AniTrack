import Foundation

final class AppContainer {
    let animeRepository: AnimeRepository

    init(animeRepository: AnimeRepository = AniListAnimeRepository()) {
        self.animeRepository = animeRepository
    }
}
