import Foundation

enum AniListQueries {
    static let homeFeed = """
    query HomeFeed($page: Int, $perPage: Int, $season: MediaSeason, $seasonYear: Int) {
      trending: Page(page: $page, perPage: $perPage) {
        media(type: ANIME, sort: TRENDING_DESC, isAdult: false) {
          ...MediaCard
        }
      }
      seasonPopular: Page(page: $page, perPage: $perPage) {
        media(type: ANIME, sort: POPULARITY_DESC, season: $season, seasonYear: $seasonYear, isAdult: false) {
          ...MediaCard
        }
      }
      recommended: Page(page: 1, perPage: 12) {
        media(type: ANIME, sort: SCORE_DESC, isAdult: false) {
          ...MediaCard
        }
      }
      airing: Page(page: 1, perPage: 8) {
        media(type: ANIME, sort: POPULARITY_DESC, status: RELEASING, isAdult: false) {
          ...MediaCard
        }
      }
    }

    fragment MediaCard on Media {
      id
      title {
        romaji
        english
      }
      description(asHtml: false)
      episodes
      averageScore
      genres
      bannerImage
      coverImage {
        large
      }
    }
    """

    static let animeDetail = """
    query (
      $page: Int = 1
      $id: Int
      $type: MediaType = ANIME
      $isAdult: Boolean = false
      $sort: [MediaSort] = [POPULARITY_DESC, SCORE_DESC]
    ) {
      Page(page: $page, perPage: 1) {
        media(
          id: $id
          type: $type
          sort: $sort
          isAdult: $isAdult
        ) {
          id
          title {
            romaji
            english
            native
          }
          description(asHtml: false)
          episodes
          duration
          averageScore
          popularity
          favourites
          status
          season
          seasonYear
          format
          source
          genres
          bannerImage
          coverImage {
            extraLarge
            large
          }
          trailer {
            site
            id
          }
          studios {
            nodes {
              name
            }
          }
          relations {
            edges {
              relationType(version: 2)
              node {
                id
                type
                format
                averageScore
                title {
                  romaji
                  english
                }
                coverImage {
                  extraLarge
                  large
                }
              }
            }
          }
        }
      }
    }
    """

    static let discoverAnime = """
    query DiscoverAnime(
      $page: Int = 1
      $type: MediaType = ANIME
      $isAdult: Boolean = false
      $search: String
      $format: [MediaFormat]
      $status: MediaStatus
      $season: MediaSeason
      $seasonYear: Int
      $genres: [String]
      $sort: [MediaSort] = [POPULARITY_DESC, SCORE_DESC]
    ) {
      Page(page: $page, perPage: 20) {
        pageInfo {
          hasNextPage
        }
        media(
          type: $type
          season: $season
          format_in: $format
          status: $status
          search: $search
          seasonYear: $seasonYear
          genre_in: $genres
          sort: $sort
          isAdult: $isAdult
        ) {
          ...MediaCard
        }
      }
    }

    fragment MediaCard on Media {
      id
      title {
        romaji
        english
      }
      description(asHtml: false)
      episodes
      averageScore
      genres
      bannerImage
      coverImage {
        large
      }
    }
    """

    static let nextAiring = """
    query NextAiring($mediaId: Int) {
      AiringSchedule(mediaId: $mediaId, notYetAired: true) {
        episode
        airingAt
      }
    }
    """
}

enum MediaSeasonHelper {
    static func currentSeasonAndYear(date: Date = Date()) -> (season: String, year: Int) {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)

        switch month {
        case 12, 1, 2:
            return ("WINTER", year)
        case 3, 4, 5:
            return ("SPRING", year)
        case 6, 7, 8:
            return ("SUMMER", year)
        default:
            return ("FALL", year)
        }
    }
}
