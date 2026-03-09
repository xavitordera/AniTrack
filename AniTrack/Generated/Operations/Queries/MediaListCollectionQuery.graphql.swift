// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension AniTrackAPI {
  class MediaListCollectionQuery: GraphQLQuery {
    static let operationName: String = "MediaListCollection"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query MediaListCollection($type: MediaType) { collection: MediaListCollection(type: $type) { __typename lists { __typename name isCustomList entries { __typename id status score progress startedAt { __typename year month day } completedAt { __typename year month day } media { __typename id episodes title { __typename romaji english userPreferred } coverImage { __typename large extraLarge } } } } } }"#
      ))

    public var type: GraphQLNullable<GraphQLEnum<MediaType>>

    public init(type: GraphQLNullable<GraphQLEnum<MediaType>>) {
      self.type = type
    }

    public var __variables: Variables? { ["type": type] }

    struct Data: AniTrackAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("MediaListCollection", alias: "collection", Collection?.self, arguments: ["type": .variable("type")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MediaListCollectionQuery.Data.self
      ] }

      /// Media list collection query, provides list pre-grouped by status & custom lists. User ID and Media Type arguments required.
      var collection: Collection? { __data["collection"] }

      /// Collection
      ///
      /// Parent Type: `MediaListCollection`
      struct Collection: AniTrackAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.MediaListCollection }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("lists", [List?]?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MediaListCollectionQuery.Data.Collection.self
        ] }

        /// Grouped media list entries
        var lists: [List?]? { __data["lists"] }

        /// Collection.List
        ///
        /// Parent Type: `MediaListGroup`
        struct List: AniTrackAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.MediaListGroup }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String?.self),
            .field("isCustomList", Bool?.self),
            .field("entries", [Entry?]?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MediaListCollectionQuery.Data.Collection.List.self
          ] }

          var name: String? { __data["name"] }
          var isCustomList: Bool? { __data["isCustomList"] }
          /// Media list entries
          var entries: [Entry?]? { __data["entries"] }

          /// Collection.List.Entry
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
              .field("startedAt", StartedAt?.self),
              .field("completedAt", CompletedAt?.self),
              .field("media", Media?.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              MediaListCollectionQuery.Data.Collection.List.Entry.self
            ] }

            /// The id of the list entry
            var id: Int { __data["id"] }
            /// The watching/reading status
            var status: GraphQLEnum<AniTrackAPI.MediaListStatus>? { __data["status"] }
            /// The score of the entry
            var score: Double? { __data["score"] }
            /// The amount of episodes/chapters consumed by the user
            var progress: Int? { __data["progress"] }
            /// When the entry was started by the user
            var startedAt: StartedAt? { __data["startedAt"] }
            /// When the entry was completed by the user
            var completedAt: CompletedAt? { __data["completedAt"] }
            var media: Media? { __data["media"] }

            /// Collection.List.Entry.StartedAt
            ///
            /// Parent Type: `FuzzyDate`
            struct StartedAt: AniTrackAPI.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.FuzzyDate }
              static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("year", Int?.self),
                .field("month", Int?.self),
                .field("day", Int?.self),
              ] }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                MediaListCollectionQuery.Data.Collection.List.Entry.StartedAt.self
              ] }

              /// Numeric Year (2017)
              var year: Int? { __data["year"] }
              /// Numeric Month (3)
              var month: Int? { __data["month"] }
              /// Numeric Day (24)
              var day: Int? { __data["day"] }
            }

            /// Collection.List.Entry.CompletedAt
            ///
            /// Parent Type: `FuzzyDate`
            struct CompletedAt: AniTrackAPI.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.FuzzyDate }
              static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("year", Int?.self),
                .field("month", Int?.self),
                .field("day", Int?.self),
              ] }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                MediaListCollectionQuery.Data.Collection.List.Entry.CompletedAt.self
              ] }

              /// Numeric Year (2017)
              var year: Int? { __data["year"] }
              /// Numeric Month (3)
              var month: Int? { __data["month"] }
              /// Numeric Day (24)
              var day: Int? { __data["day"] }
            }

            /// Collection.List.Entry.Media
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
                .field("title", Title?.self),
                .field("coverImage", CoverImage?.self),
              ] }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                MediaListCollectionQuery.Data.Collection.List.Entry.Media.self
              ] }

              /// The id of the media
              var id: Int { __data["id"] }
              /// The amount of episodes the anime has when complete
              var episodes: Int? { __data["episodes"] }
              /// The official titles of the media in various languages
              var title: Title? { __data["title"] }
              /// The cover images of the media
              var coverImage: CoverImage? { __data["coverImage"] }

              /// Collection.List.Entry.Media.Title
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
                  .field("userPreferred", String?.self),
                ] }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  MediaListCollectionQuery.Data.Collection.List.Entry.Media.Title.self
                ] }

                /// The romanization of the native language title
                var romaji: String? { __data["romaji"] }
                /// The official english title
                var english: String? { __data["english"] }
                /// The currently authenticated users preferred title language. Default romaji for non-authenticated
                var userPreferred: String? { __data["userPreferred"] }
              }

              /// Collection.List.Entry.Media.CoverImage
              ///
              /// Parent Type: `MediaCoverImage`
              struct CoverImage: AniTrackAPI.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.MediaCoverImage }
                static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("large", String?.self),
                  .field("extraLarge", String?.self),
                ] }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  MediaListCollectionQuery.Data.Collection.List.Entry.Media.CoverImage.self
                ] }

                /// The cover image url of the media at a large size
                var large: String? { __data["large"] }
                /// The cover image url of the media at its largest size. If this size isn't available, large will be provided instead.
                var extraLarge: String? { __data["extraLarge"] }
              }
            }
          }
        }
      }
    }
  }

}