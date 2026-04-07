// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension AniTrackAPI {
  class UserAnimeStatisticsFallbackQuery: GraphQLQuery {
    static let operationName: String = "UserAnimeStatisticsFallback"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query UserAnimeStatisticsFallback($userId: Int) { MediaListCollection(userId: $userId, type: ANIME) { __typename lists { __typename status entries { __typename id status score progress media { __typename id episodes duration genres studios { __typename nodes { __typename id name } } } } } } }"#
      ))

    public var userId: GraphQLNullable<Int>

    public init(userId: GraphQLNullable<Int>) {
      self.userId = userId
    }

    public var __variables: Variables? { ["userId": userId] }

    struct Data: AniTrackAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("MediaListCollection", MediaListCollection?.self, arguments: [
          "userId": .variable("userId"),
          "type": "ANIME"
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UserAnimeStatisticsFallbackQuery.Data.self
      ] }

      /// Media list collection query, provides list pre-grouped by status & custom lists. User ID and Media Type arguments required.
      var mediaListCollection: MediaListCollection? { __data["MediaListCollection"] }

      /// MediaListCollection
      ///
      /// Parent Type: `MediaListCollection`
      struct MediaListCollection: AniTrackAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.MediaListCollection }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("lists", [List?]?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          UserAnimeStatisticsFallbackQuery.Data.MediaListCollection.self
        ] }

        /// Grouped media list entries
        var lists: [List?]? { __data["lists"] }

        /// MediaListCollection.List
        ///
        /// Parent Type: `MediaListGroup`
        struct List: AniTrackAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.MediaListGroup }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("status", GraphQLEnum<AniTrackAPI.MediaListStatus>?.self),
            .field("entries", [Entry?]?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            UserAnimeStatisticsFallbackQuery.Data.MediaListCollection.List.self
          ] }

          var status: GraphQLEnum<AniTrackAPI.MediaListStatus>? { __data["status"] }
          /// Media list entries
          var entries: [Entry?]? { __data["entries"] }

          /// MediaListCollection.List.Entry
          ///
          /// Parent Type: `MediaList`
          struct Entry: AniTrackAPI.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.MediaList }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", Int.self),
              .field("status", GraphQLEnum<AniTrackAPI.MediaListStatus>?.self),
              .field("score", Double?.self),
              .field("progress", Int?.self),
              .field("media", Media?.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              UserAnimeStatisticsFallbackQuery.Data.MediaListCollection.List.Entry.self
            ] }

            /// The id of the list entry
            var id: Int { __data["id"] }
            /// The watching/reading status
            var status: GraphQLEnum<AniTrackAPI.MediaListStatus>? { __data["status"] }
            /// The score of the entry
            var score: Double? { __data["score"] }
            /// The amount of episodes/chapters consumed by the user
            var progress: Int? { __data["progress"] }
            var media: Media? { __data["media"] }

            /// MediaListCollection.List.Entry.Media
            ///
            /// Parent Type: `Media`
            struct Media: AniTrackAPI.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Media }
              static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("id", Int.self),
                .field("episodes", Int?.self),
                .field("duration", Int?.self),
                .field("genres", [String?]?.self),
                .field("studios", Studios?.self),
              ] }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                UserAnimeStatisticsFallbackQuery.Data.MediaListCollection.List.Entry.Media.self
              ] }

              /// The id of the media
              var id: Int { __data["id"] }
              /// The amount of episodes the anime has when complete
              var episodes: Int? { __data["episodes"] }
              /// The general length of each anime episode in minutes
              var duration: Int? { __data["duration"] }
              /// The genres of the media
              var genres: [String?]? { __data["genres"] }
              /// The companies who produced the media
              var studios: Studios? { __data["studios"] }

              /// MediaListCollection.List.Entry.Media.Studios
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
                  UserAnimeStatisticsFallbackQuery.Data.MediaListCollection.List.Entry.Media.Studios.self
                ] }

                var nodes: [Node?]? { __data["nodes"] }

                /// MediaListCollection.List.Entry.Media.Studios.Node
                ///
                /// Parent Type: `Studio`
                struct Node: AniTrackAPI.SelectionSet {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Studio }
                  static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("id", Int.self),
                    .field("name", String.self),
                  ] }
                  static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                    UserAnimeStatisticsFallbackQuery.Data.MediaListCollection.List.Entry.Media.Studios.Node.self
                  ] }

                  /// The id of the studio
                  var id: Int { __data["id"] }
                  /// The name of the studio
                  var name: String { __data["name"] }
                }
              }
            }
          }
        }
      }
    }
  }

}
