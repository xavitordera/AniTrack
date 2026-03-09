// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension AniTrackAPI {
  class AnimeDetailQuery: GraphQLQuery {
    static let operationName: String = "AnimeDetail"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query AnimeDetail($id: Int!, $isAdult: Boolean = false, $sort: [MediaSort] = [POPULARITY_DESC, SCORE_DESC]) { Page(page: 1, perPage: 1) { __typename media(id: $id, type: ANIME, sort: $sort, isAdult: $isAdult) { __typename id title { __typename romaji english native } description(asHtml: false) episodes duration averageScore popularity favourites status season seasonYear format source genres bannerImage coverImage { __typename extraLarge large } trailer { __typename site id } studios { __typename nodes { __typename name } } relations { __typename edges { __typename relationType(version: 2) node { __typename id type format averageScore title { __typename romaji english } coverImage { __typename extraLarge large } } } } } } }"#
      ))

    public var id: Int
    public var isAdult: GraphQLNullable<Bool>
    public var sort: GraphQLNullable<[GraphQLEnum<MediaSort>?]>

    public init(
      id: Int,
      isAdult: GraphQLNullable<Bool> = false,
      sort: GraphQLNullable<[GraphQLEnum<MediaSort>?]> = [.init(.popularityDesc), .init(.scoreDesc)]
    ) {
      self.id = id
      self.isAdult = isAdult
      self.sort = sort
    }

    public var __variables: Variables? { [
      "id": id,
      "isAdult": isAdult,
      "sort": sort
    ] }

    struct Data: AniTrackAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("Page", Page?.self, arguments: [
          "page": 1,
          "perPage": 1
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AnimeDetailQuery.Data.self
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
          .field("media", [Medium?]?.self, arguments: [
            "id": .variable("id"),
            "type": "ANIME",
            "sort": .variable("sort"),
            "isAdult": .variable("isAdult")
          ]),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AnimeDetailQuery.Data.Page.self
        ] }

        var media: [Medium?]? { __data["media"] }

        /// Page.Medium
        ///
        /// Parent Type: `Media`
        struct Medium: AniTrackAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Media }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", Int.self),
            .field("title", Title?.self),
            .field("description", String?.self, arguments: ["asHtml": false]),
            .field("episodes", Int?.self),
            .field("duration", Int?.self),
            .field("averageScore", Int?.self),
            .field("popularity", Int?.self),
            .field("favourites", Int?.self),
            .field("status", GraphQLEnum<AniTrackAPI.MediaStatus>?.self),
            .field("season", GraphQLEnum<AniTrackAPI.MediaSeason>?.self),
            .field("seasonYear", Int?.self),
            .field("format", GraphQLEnum<AniTrackAPI.MediaFormat>?.self),
            .field("source", GraphQLEnum<AniTrackAPI.MediaSource>?.self),
            .field("genres", [String?]?.self),
            .field("bannerImage", String?.self),
            .field("coverImage", CoverImage?.self),
            .field("trailer", Trailer?.self),
            .field("studios", Studios?.self),
            .field("relations", Relations?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AnimeDetailQuery.Data.Page.Medium.self
          ] }

          /// The id of the media
          var id: Int { __data["id"] }
          /// The official titles of the media in various languages
          var title: Title? { __data["title"] }
          /// Short description of the media's story and characters
          var description: String? { __data["description"] }
          /// The amount of episodes the anime has when complete
          var episodes: Int? { __data["episodes"] }
          /// The general length of each anime episode in minutes
          var duration: Int? { __data["duration"] }
          /// A weighted average score of all the user's scores of the media
          var averageScore: Int? { __data["averageScore"] }
          /// The number of users with the media on their list
          var popularity: Int? { __data["popularity"] }
          /// The amount of user's who have favourited the media
          var favourites: Int? { __data["favourites"] }
          /// The current releasing status of the media
          var status: GraphQLEnum<AniTrackAPI.MediaStatus>? { __data["status"] }
          /// The season the media was initially released in
          var season: GraphQLEnum<AniTrackAPI.MediaSeason>? { __data["season"] }
          /// The season year the media was initially released in
          var seasonYear: Int? { __data["seasonYear"] }
          /// The format the media was released in
          var format: GraphQLEnum<AniTrackAPI.MediaFormat>? { __data["format"] }
          /// Source type the media was adapted from.
          var source: GraphQLEnum<AniTrackAPI.MediaSource>? { __data["source"] }
          /// The genres of the media
          var genres: [String?]? { __data["genres"] }
          /// The banner image of the media
          var bannerImage: String? { __data["bannerImage"] }
          /// The cover images of the media
          var coverImage: CoverImage? { __data["coverImage"] }
          /// Media trailer or advertisement
          var trailer: Trailer? { __data["trailer"] }
          /// The companies who produced the media
          var studios: Studios? { __data["studios"] }
          /// Other media in the same or connecting franchise
          var relations: Relations? { __data["relations"] }

          /// Page.Medium.Title
          ///
          /// Parent Type: `MediaTitle`
          struct Title: AniTrackAPI.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.MediaTitle }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("romaji", String?.self),
              .field("english", String?.self),
              .field("native", String?.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              AnimeDetailQuery.Data.Page.Medium.Title.self
            ] }

            /// The romanization of the native language title
            var romaji: String? { __data["romaji"] }
            /// The official english title
            var english: String? { __data["english"] }
            /// Official title in it's native language
            var native: String? { __data["native"] }
          }

          /// Page.Medium.CoverImage
          ///
          /// Parent Type: `MediaCoverImage`
          struct CoverImage: AniTrackAPI.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.MediaCoverImage }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("extraLarge", String?.self),
              .field("large", String?.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              AnimeDetailQuery.Data.Page.Medium.CoverImage.self
            ] }

            /// The cover image url of the media at its largest size. If this size isn't available, large will be provided instead.
            var extraLarge: String? { __data["extraLarge"] }
            /// The cover image url of the media at a large size
            var large: String? { __data["large"] }
          }

          /// Page.Medium.Trailer
          ///
          /// Parent Type: `MediaTrailer`
          struct Trailer: AniTrackAPI.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.MediaTrailer }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("site", String?.self),
              .field("id", String?.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              AnimeDetailQuery.Data.Page.Medium.Trailer.self
            ] }

            /// The site the video is hosted by (Currently either youtube or dailymotion)
            var site: String? { __data["site"] }
            /// The trailer video id
            var id: String? { __data["id"] }
          }

          /// Page.Medium.Studios
          ///
          /// Parent Type: `StudioConnection`
          struct Studios: AniTrackAPI.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.StudioConnection }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("nodes", [Node?]?.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              AnimeDetailQuery.Data.Page.Medium.Studios.self
            ] }

            var nodes: [Node?]? { __data["nodes"] }

            /// Page.Medium.Studios.Node
            ///
            /// Parent Type: `Studio`
            struct Node: AniTrackAPI.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Studio }
              static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("name", String.self),
              ] }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                AnimeDetailQuery.Data.Page.Medium.Studios.Node.self
              ] }

              /// The name of the studio
              var name: String { __data["name"] }
            }
          }

          /// Page.Medium.Relations
          ///
          /// Parent Type: `MediaConnection`
          struct Relations: AniTrackAPI.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.MediaConnection }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("edges", [Edge?]?.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              AnimeDetailQuery.Data.Page.Medium.Relations.self
            ] }

            var edges: [Edge?]? { __data["edges"] }

            /// Page.Medium.Relations.Edge
            ///
            /// Parent Type: `MediaEdge`
            struct Edge: AniTrackAPI.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.MediaEdge }
              static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("relationType", GraphQLEnum<AniTrackAPI.MediaRelation>?.self, arguments: ["version": 2]),
                .field("node", Node?.self),
              ] }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                AnimeDetailQuery.Data.Page.Medium.Relations.Edge.self
              ] }

              /// The type of relation to the parent model
              var relationType: GraphQLEnum<AniTrackAPI.MediaRelation>? { __data["relationType"] }
              var node: Node? { __data["node"] }

              /// Page.Medium.Relations.Edge.Node
              ///
              /// Parent Type: `Media`
              struct Node: AniTrackAPI.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Media }
                static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("id", Int.self),
                  .field("type", GraphQLEnum<AniTrackAPI.MediaType>?.self),
                  .field("format", GraphQLEnum<AniTrackAPI.MediaFormat>?.self),
                  .field("averageScore", Int?.self),
                  .field("title", Title?.self),
                  .field("coverImage", CoverImage?.self),
                ] }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  AnimeDetailQuery.Data.Page.Medium.Relations.Edge.Node.self
                ] }

                /// The id of the media
                var id: Int { __data["id"] }
                /// The type of the media; anime or manga
                var type: GraphQLEnum<AniTrackAPI.MediaType>? { __data["type"] }
                /// The format the media was released in
                var format: GraphQLEnum<AniTrackAPI.MediaFormat>? { __data["format"] }
                /// A weighted average score of all the user's scores of the media
                var averageScore: Int? { __data["averageScore"] }
                /// The official titles of the media in various languages
                var title: Title? { __data["title"] }
                /// The cover images of the media
                var coverImage: CoverImage? { __data["coverImage"] }

                /// Page.Medium.Relations.Edge.Node.Title
                ///
                /// Parent Type: `MediaTitle`
                struct Title: AniTrackAPI.SelectionSet {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.MediaTitle }
                  static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("romaji", String?.self),
                    .field("english", String?.self),
                  ] }
                  static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                    AnimeDetailQuery.Data.Page.Medium.Relations.Edge.Node.Title.self
                  ] }

                  /// The romanization of the native language title
                  var romaji: String? { __data["romaji"] }
                  /// The official english title
                  var english: String? { __data["english"] }
                }

                /// Page.Medium.Relations.Edge.Node.CoverImage
                ///
                /// Parent Type: `MediaCoverImage`
                struct CoverImage: AniTrackAPI.SelectionSet {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.MediaCoverImage }
                  static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("extraLarge", String?.self),
                    .field("large", String?.self),
                  ] }
                  static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                    AnimeDetailQuery.Data.Page.Medium.Relations.Edge.Node.CoverImage.self
                  ] }

                  /// The cover image url of the media at its largest size. If this size isn't available, large will be provided instead.
                  var extraLarge: String? { __data["extraLarge"] }
                  /// The cover image url of the media at a large size
                  var large: String? { __data["large"] }
                }
              }
            }
          }
        }
      }
    }
  }

}