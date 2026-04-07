// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension AniTrackAPI {
  class DeleteMyAnimeListEntryMutation: GraphQLMutation {
    static let operationName: String = "DeleteMyAnimeListEntry"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation DeleteMyAnimeListEntry($id: Int) { DeleteMediaListEntry(id: $id) { __typename deleted } }"#
      ))

    public var id: GraphQLNullable<Int>

    public init(id: GraphQLNullable<Int>) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: AniTrackAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("DeleteMediaListEntry", DeleteMediaListEntry?.self, arguments: ["id": .variable("id")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        DeleteMyAnimeListEntryMutation.Data.self
      ] }

      /// Delete a media list entry
      var deleteMediaListEntry: DeleteMediaListEntry? { __data["DeleteMediaListEntry"] }

      /// DeleteMediaListEntry
      ///
      /// Parent Type: `Deleted`
      struct DeleteMediaListEntry: AniTrackAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Deleted }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("deleted", Bool?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          DeleteMyAnimeListEntryMutation.Data.DeleteMediaListEntry.self
        ] }

        /// If an item has been successfully deleted
        var deleted: Bool? { __data["deleted"] }
      }
    }
  }

}