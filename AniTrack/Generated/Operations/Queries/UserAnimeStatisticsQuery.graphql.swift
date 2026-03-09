// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension AniTrackAPI {
  class UserAnimeStatisticsQuery: GraphQLQuery {
    static let operationName: String = "UserAnimeStatistics"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query UserAnimeStatistics { Viewer { __typename id name statistics { __typename anime { __typename count meanScore minutesWatched episodesWatched genres(limit: 8, sort: [COUNT_DESC]) { __typename genre count } studios(limit: 5, sort: [COUNT_DESC]) { __typename count studio { __typename id name } } statuses(sort: [COUNT_DESC]) { __typename status count } } } } }"#
      ))

    public init() {}

    struct Data: AniTrackAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("Viewer", Viewer?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UserAnimeStatisticsQuery.Data.self
      ] }

      /// Get the currently authenticated user
      var viewer: Viewer? { __data["Viewer"] }

      /// Viewer
      ///
      /// Parent Type: `User`
      struct Viewer: AniTrackAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.User }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", Int.self),
          .field("name", String.self),
          .field("statistics", Statistics?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          UserAnimeStatisticsQuery.Data.Viewer.self
        ] }

        /// The id of the user
        var id: Int { __data["id"] }
        /// The name of the user
        var name: String { __data["name"] }
        /// The users anime & manga list statistics
        var statistics: Statistics? { __data["statistics"] }

        /// Viewer.Statistics
        ///
        /// Parent Type: `UserStatisticTypes`
        struct Statistics: AniTrackAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.UserStatisticTypes }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("anime", Anime?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            UserAnimeStatisticsQuery.Data.Viewer.Statistics.self
          ] }

          var anime: Anime? { __data["anime"] }

          /// Viewer.Statistics.Anime
          ///
          /// Parent Type: `UserStatistics`
          struct Anime: AniTrackAPI.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.UserStatistics }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("count", Int.self),
              .field("meanScore", Double.self),
              .field("minutesWatched", Int.self),
              .field("episodesWatched", Int.self),
              .field("genres", [Genre?]?.self, arguments: [
                "limit": 8,
                "sort": ["COUNT_DESC"]
              ]),
              .field("studios", [Studio?]?.self, arguments: [
                "limit": 5,
                "sort": ["COUNT_DESC"]
              ]),
              .field("statuses", [Status?]?.self, arguments: ["sort": ["COUNT_DESC"]]),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              UserAnimeStatisticsQuery.Data.Viewer.Statistics.Anime.self
            ] }

            var count: Int { __data["count"] }
            var meanScore: Double { __data["meanScore"] }
            var minutesWatched: Int { __data["minutesWatched"] }
            var episodesWatched: Int { __data["episodesWatched"] }
            var genres: [Genre?]? { __data["genres"] }
            var studios: [Studio?]? { __data["studios"] }
            var statuses: [Status?]? { __data["statuses"] }

            /// Viewer.Statistics.Anime.Genre
            ///
            /// Parent Type: `UserGenreStatistic`
            struct Genre: AniTrackAPI.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.UserGenreStatistic }
              static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("genre", String?.self),
                .field("count", Int.self),
              ] }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                UserAnimeStatisticsQuery.Data.Viewer.Statistics.Anime.Genre.self
              ] }

              var genre: String? { __data["genre"] }
              var count: Int { __data["count"] }
            }

            /// Viewer.Statistics.Anime.Studio
            ///
            /// Parent Type: `UserStudioStatistic`
            struct Studio: AniTrackAPI.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.UserStudioStatistic }
              static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("count", Int.self),
                .field("studio", Studio?.self),
              ] }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                UserAnimeStatisticsQuery.Data.Viewer.Statistics.Anime.Studio.self
              ] }

              var count: Int { __data["count"] }
              var studio: Studio? { __data["studio"] }

              /// Viewer.Statistics.Anime.Studio.Studio
              ///
              /// Parent Type: `Studio`
              struct Studio: AniTrackAPI.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Studio }
                static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("id", Int.self),
                  .field("name", String.self),
                ] }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  UserAnimeStatisticsQuery.Data.Viewer.Statistics.Anime.Studio.Studio.self
                ] }

                /// The id of the studio
                var id: Int { __data["id"] }
                /// The name of the studio
                var name: String { __data["name"] }
              }
            }

            /// Viewer.Statistics.Anime.Status
            ///
            /// Parent Type: `UserStatusStatistic`
            struct Status: AniTrackAPI.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.UserStatusStatistic }
              static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("status", GraphQLEnum<AniTrackAPI.MediaListStatus>?.self),
                .field("count", Int.self),
              ] }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                UserAnimeStatisticsQuery.Data.Viewer.Statistics.Anime.Status.self
              ] }

              var status: GraphQLEnum<AniTrackAPI.MediaListStatus>? { __data["status"] }
              var count: Int { __data["count"] }
            }
          }
        }
      }
    }
  }

}