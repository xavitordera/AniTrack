// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension AniTrackAPI {
  class HomeFeedQuery: GraphQLQuery {
    static let operationName: String = "HomeFeed"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query HomeFeed($page: Int, $perPage: Int, $season: MediaSeason, $seasonYear: Int) { trending: Page(page: $page, perPage: $perPage) { __typename media(type: ANIME, sort: TRENDING_DESC, isAdult: false) { __typename ...MediaCard } } seasonPopular: Page(page: $page, perPage: $perPage) { __typename media( type: ANIME sort: POPULARITY_DESC season: $season seasonYear: $seasonYear isAdult: false ) { __typename ...MediaCard } } recommended: Page(page: 1, perPage: 12) { __typename media(type: ANIME, sort: SCORE_DESC, isAdult: false) { __typename ...MediaCard } } airing: Page(page: 1, perPage: 8) { __typename media(type: ANIME, sort: POPULARITY_DESC, status: RELEASING, isAdult: false) { __typename ...MediaCard } } }"#,
        fragments: [MediaCard.self]
      ))

    public var page: GraphQLNullable<Int>
    public var perPage: GraphQLNullable<Int>
    public var season: GraphQLNullable<GraphQLEnum<MediaSeason>>
    public var seasonYear: GraphQLNullable<Int>

    public init(
      page: GraphQLNullable<Int>,
      perPage: GraphQLNullable<Int>,
      season: GraphQLNullable<GraphQLEnum<MediaSeason>>,
      seasonYear: GraphQLNullable<Int>
    ) {
      self.page = page
      self.perPage = perPage
      self.season = season
      self.seasonYear = seasonYear
    }

    public var __variables: Variables? { [
      "page": page,
      "perPage": perPage,
      "season": season,
      "seasonYear": seasonYear
    ] }

    struct Data: AniTrackAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("Page", alias: "trending", Trending?.self, arguments: [
          "page": .variable("page"),
          "perPage": .variable("perPage")
        ]),
        .field("Page", alias: "seasonPopular", SeasonPopular?.self, arguments: [
          "page": .variable("page"),
          "perPage": .variable("perPage")
        ]),
        .field("Page", alias: "recommended", Recommended?.self, arguments: [
          "page": 1,
          "perPage": 12
        ]),
        .field("Page", alias: "airing", Airing?.self, arguments: [
          "page": 1,
          "perPage": 8
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        HomeFeedQuery.Data.self
      ] }

      var trending: Trending? { __data["trending"] }
      var seasonPopular: SeasonPopular? { __data["seasonPopular"] }
      var recommended: Recommended? { __data["recommended"] }
      var airing: Airing? { __data["airing"] }

      /// Trending
      ///
      /// Parent Type: `Page`
      struct Trending: AniTrackAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Page }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("media", [Medium?]?.self, arguments: [
            "type": "ANIME",
            "sort": "TRENDING_DESC",
            "isAdult": false
          ]),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          HomeFeedQuery.Data.Trending.self
        ] }

        var media: [Medium?]? { __data["media"] }

        /// Trending.Medium
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
            HomeFeedQuery.Data.Trending.Medium.self,
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

      /// SeasonPopular
      ///
      /// Parent Type: `Page`
      struct SeasonPopular: AniTrackAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Page }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("media", [Medium?]?.self, arguments: [
            "type": "ANIME",
            "sort": "POPULARITY_DESC",
            "season": .variable("season"),
            "seasonYear": .variable("seasonYear"),
            "isAdult": false
          ]),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          HomeFeedQuery.Data.SeasonPopular.self
        ] }

        var media: [Medium?]? { __data["media"] }

        /// SeasonPopular.Medium
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
            HomeFeedQuery.Data.SeasonPopular.Medium.self,
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

      /// Recommended
      ///
      /// Parent Type: `Page`
      struct Recommended: AniTrackAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Page }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("media", [Medium?]?.self, arguments: [
            "type": "ANIME",
            "sort": "SCORE_DESC",
            "isAdult": false
          ]),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          HomeFeedQuery.Data.Recommended.self
        ] }

        var media: [Medium?]? { __data["media"] }

        /// Recommended.Medium
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
            HomeFeedQuery.Data.Recommended.Medium.self,
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

      /// Airing
      ///
      /// Parent Type: `Page`
      struct Airing: AniTrackAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Page }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("media", [Medium?]?.self, arguments: [
            "type": "ANIME",
            "sort": "POPULARITY_DESC",
            "status": "RELEASING",
            "isAdult": false
          ]),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          HomeFeedQuery.Data.Airing.self
        ] }

        var media: [Medium?]? { __data["media"] }

        /// Airing.Medium
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
            HomeFeedQuery.Data.Airing.Medium.self,
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