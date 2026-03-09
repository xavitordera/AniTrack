// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension AniTrackAPI {
  class NextAiringQuery: GraphQLQuery {
    static let operationName: String = "NextAiring"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query NextAiring($mediaId: Int) { AiringSchedule(mediaId: $mediaId, notYetAired: true) { __typename episode airingAt } }"#
      ))

    public var mediaId: GraphQLNullable<Int>

    public init(mediaId: GraphQLNullable<Int>) {
      self.mediaId = mediaId
    }

    public var __variables: Variables? { ["mediaId": mediaId] }

    struct Data: AniTrackAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("AiringSchedule", AiringSchedule?.self, arguments: [
          "mediaId": .variable("mediaId"),
          "notYetAired": true
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        NextAiringQuery.Data.self
      ] }

      /// Airing schedule query
      var airingSchedule: AiringSchedule? { __data["AiringSchedule"] }

      /// AiringSchedule
      ///
      /// Parent Type: `AiringSchedule`
      struct AiringSchedule: AniTrackAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.AiringSchedule }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("episode", Int.self),
          .field("airingAt", Int.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          NextAiringQuery.Data.AiringSchedule.self
        ] }

        /// The airing episode number
        var episode: Int { __data["episode"] }
        /// The time the episode airs at
        var airingAt: Int { __data["airingAt"] }
      }
    }
  }

}