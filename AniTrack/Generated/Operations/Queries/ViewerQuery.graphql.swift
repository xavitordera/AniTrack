// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension AniTrackAPI {
  class ViewerQuery: GraphQLQuery {
    static let operationName: String = "Viewer"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Viewer { viewer: Viewer { __typename id name } }"#
      ))

    public init() {}

    struct Data: AniTrackAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("Viewer", alias: "viewer", Viewer?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ViewerQuery.Data.self
      ] }

      /// Get the currently authenticated user
      var viewer: Viewer? { __data["viewer"] }

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
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ViewerQuery.Data.Viewer.self
        ] }

        /// The id of the user
        var id: Int { __data["id"] }
        /// The name of the user
        var name: String { __data["name"] }
      }
    }
  }

}