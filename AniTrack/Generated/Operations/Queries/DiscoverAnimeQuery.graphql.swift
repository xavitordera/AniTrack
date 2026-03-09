// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension AniTrackAPI {
  class DiscoverAnimeQuery: GraphQLQuery {
    static let operationName: String = "DiscoverAnime"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query DiscoverAnime($page: Int = 1, $isAdult: Boolean = false, $search: String, $format: [MediaFormat], $status: MediaStatus, $season: MediaSeason, $seasonYear: Int, $genres: [String], $sort: [MediaSort] = [POPULARITY_DESC, SCORE_DESC]) { Page(page: $page, perPage: 20) { __typename pageInfo { __typename hasNextPage } media( type: ANIME season: $season format_in: $format status: $status search: $search seasonYear: $seasonYear genre_in: $genres sort: $sort isAdult: $isAdult ) { __typename ...MediaCard } } }"#,
        fragments: [MediaCard.self]
      ))

    public var page: GraphQLNullable<Int>
    public var isAdult: GraphQLNullable<Bool>
    public var search: GraphQLNullable<String>
    public var format: GraphQLNullable<[GraphQLEnum<MediaFormat>?]>
    public var status: GraphQLNullable<GraphQLEnum<MediaStatus>>
    public var season: GraphQLNullable<GraphQLEnum<MediaSeason>>
    public var seasonYear: GraphQLNullable<Int>
    public var genres: GraphQLNullable<[String?]>
    public var sort: GraphQLNullable<[GraphQLEnum<MediaSort>?]>

    public init(
      page: GraphQLNullable<Int> = 1,
      isAdult: GraphQLNullable<Bool> = false,
      search: GraphQLNullable<String>,
      format: GraphQLNullable<[GraphQLEnum<MediaFormat>?]>,
      status: GraphQLNullable<GraphQLEnum<MediaStatus>>,
      season: GraphQLNullable<GraphQLEnum<MediaSeason>>,
      seasonYear: GraphQLNullable<Int>,
      genres: GraphQLNullable<[String?]>,
      sort: GraphQLNullable<[GraphQLEnum<MediaSort>?]> = [.init(.popularityDesc), .init(.scoreDesc)]
    ) {
      self.page = page
      self.isAdult = isAdult
      self.search = search
      self.format = format
      self.status = status
      self.season = season
      self.seasonYear = seasonYear
      self.genres = genres
      self.sort = sort
    }

    public var __variables: Variables? { [
      "page": page,
      "isAdult": isAdult,
      "search": search,
      "format": format,
      "status": status,
      "season": season,
      "seasonYear": seasonYear,
      "genres": genres,
      "sort": sort
    ] }

    struct Data: AniTrackAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("Page", Page?.self, arguments: [
          "page": .variable("page"),
          "perPage": 20
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        DiscoverAnimeQuery.Data.self
      ] }

      var page: Page? { __data["Page"] }

      /// Page
      ///
      /// Parent Type: `Page`
      struct Page: AniTrackAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Page }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo?.self),
          .field("media", [Medium?]?.self, arguments: [
            "type": "ANIME",
            "season": .variable("season"),
            "format_in": .variable("format"),
            "status": .variable("status"),
            "search": .variable("search"),
            "seasonYear": .variable("seasonYear"),
            "genre_in": .variable("genres"),
            "sort": .variable("sort"),
            "isAdult": .variable("isAdult")
          ]),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          DiscoverAnimeQuery.Data.Page.self
        ] }

        /// The pagination information
        var pageInfo: PageInfo? { __data["pageInfo"] }
        var media: [Medium?]? { __data["media"] }

        /// Page.PageInfo
        ///
        /// Parent Type: `PageInfo`
        struct PageInfo: AniTrackAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.PageInfo }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("hasNextPage", Bool?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            DiscoverAnimeQuery.Data.Page.PageInfo.self
          ] }

          /// If there is another page
          var hasNextPage: Bool? { __data["hasNextPage"] }
        }

        /// Page.Medium
        ///
        /// Parent Type: `Media`
        struct Medium: AniTrackAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Media }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(MediaCard.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            DiscoverAnimeQuery.Data.Page.Medium.self,
            MediaCard.self
          ] }

          /// The id of the media
          var id: Int { __data["id"] }
          /// The official titles of the media in various languages
          var title: Title? { __data["title"] }
          /// Short description of the media's story and characters
          var description: String? { __data["description"] }
          /// The amount of episodes the anime has when complete
          var episodes: Int? { __data["episodes"] }
          /// A weighted average score of all the user's scores of the media
          var averageScore: Int? { __data["averageScore"] }
          /// The genres of the media
          var genres: [String?]? { __data["genres"] }
          /// The banner image of the media
          var bannerImage: String? { __data["bannerImage"] }
          /// The cover images of the media
          var coverImage: CoverImage? { __data["coverImage"] }

          struct Fragments: FragmentContainer {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            var mediaCard: MediaCard { _toFragment() }
          }

          typealias Title = MediaCard.Title

          typealias CoverImage = MediaCard.CoverImage
        }
      }
    }
  }

}