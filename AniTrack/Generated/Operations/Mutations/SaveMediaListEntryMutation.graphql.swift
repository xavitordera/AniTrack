// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension AniTrackAPI {
  class SaveMediaListEntryMutation: GraphQLMutation {
    static let operationName: String = "SaveMediaListEntry"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation SaveMediaListEntry($id: Int, $mediaId: Int, $status: MediaListStatus, $score: Float, $progress: Int, $startedAt: FuzzyDateInput, $completedAt: FuzzyDateInput) { saved: SaveMediaListEntry( id: $id mediaId: $mediaId status: $status score: $score progress: $progress startedAt: $startedAt completedAt: $completedAt ) { __typename id status score progress startedAt { __typename year month day } completedAt { __typename year month day } media { __typename id episodes title { __typename romaji english userPreferred } coverImage { __typename large extraLarge } } } }"#
      ))

    public var id: GraphQLNullable<Int>
    public var mediaId: GraphQLNullable<Int>
    public var status: GraphQLNullable<GraphQLEnum<MediaListStatus>>
    public var score: GraphQLNullable<Double>
    public var progress: GraphQLNullable<Int>
    public var startedAt: GraphQLNullable<FuzzyDateInput>
    public var completedAt: GraphQLNullable<FuzzyDateInput>

    public init(
      id: GraphQLNullable<Int>,
      mediaId: GraphQLNullable<Int>,
      status: GraphQLNullable<GraphQLEnum<MediaListStatus>>,
      score: GraphQLNullable<Double>,
      progress: GraphQLNullable<Int>,
      startedAt: GraphQLNullable<FuzzyDateInput>,
      completedAt: GraphQLNullable<FuzzyDateInput>
    ) {
      self.id = id
      self.mediaId = mediaId
      self.status = status
      self.score = score
      self.progress = progress
      self.startedAt = startedAt
      self.completedAt = completedAt
    }

    public var __variables: Variables? { [
      "id": id,
      "mediaId": mediaId,
      "status": status,
      "score": score,
      "progress": progress,
      "startedAt": startedAt,
      "completedAt": completedAt
    ] }

    struct Data: AniTrackAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("SaveMediaListEntry", alias: "saved", Saved?.self, arguments: [
          "id": .variable("id"),
          "mediaId": .variable("mediaId"),
          "status": .variable("status"),
          "score": .variable("score"),
          "progress": .variable("progress"),
          "startedAt": .variable("startedAt"),
          "completedAt": .variable("completedAt")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        SaveMediaListEntryMutation.Data.self
      ] }

      /// Create or update a media list entry
      var saved: Saved? { __data["saved"] }

      /// Saved
      ///
      /// Parent Type: `MediaList`
      struct Saved: AniTrackAPI.SelectionSet {
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
          SaveMediaListEntryMutation.Data.Saved.self
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

        /// Saved.StartedAt
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
            SaveMediaListEntryMutation.Data.Saved.StartedAt.self
          ] }

          /// Numeric Year (2017)
          var year: Int? { __data["year"] }
          /// Numeric Month (3)
          var month: Int? { __data["month"] }
          /// Numeric Day (24)
          var day: Int? { __data["day"] }
        }

        /// Saved.CompletedAt
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
            SaveMediaListEntryMutation.Data.Saved.CompletedAt.self
          ] }

          /// Numeric Year (2017)
          var year: Int? { __data["year"] }
          /// Numeric Month (3)
          var month: Int? { __data["month"] }
          /// Numeric Day (24)
          var day: Int? { __data["day"] }
        }

        /// Saved.Media
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
            SaveMediaListEntryMutation.Data.Saved.Media.self
          ] }

          /// The id of the media
          var id: Int { __data["id"] }
          /// The amount of episodes the anime has when complete
          var episodes: Int? { __data["episodes"] }
          /// The official titles of the media in various languages
          var title: Title? { __data["title"] }
          /// The cover images of the media
          var coverImage: CoverImage? { __data["coverImage"] }

          /// Saved.Media.Title
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
              SaveMediaListEntryMutation.Data.Saved.Media.Title.self
            ] }

            /// The romanization of the native language title
            var romaji: String? { __data["romaji"] }
            /// The official english title
            var english: String? { __data["english"] }
            /// The currently authenticated users preferred title language. Default romaji for non-authenticated
            var userPreferred: String? { __data["userPreferred"] }
          }

          /// Saved.Media.CoverImage
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
              SaveMediaListEntryMutation.Data.Saved.Media.CoverImage.self
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