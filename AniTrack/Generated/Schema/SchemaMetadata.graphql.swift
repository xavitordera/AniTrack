// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

protocol AniTrackAPI_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == AniTrackAPI.SchemaMetadata {}

protocol AniTrackAPI_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == AniTrackAPI.SchemaMetadata {}

protocol AniTrackAPI_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == AniTrackAPI.SchemaMetadata {}

protocol AniTrackAPI_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == AniTrackAPI.SchemaMetadata {}

extension AniTrackAPI {
  typealias SelectionSet = AniTrackAPI_SelectionSet

  typealias InlineFragment = AniTrackAPI_InlineFragment

  typealias MutableSelectionSet = AniTrackAPI_MutableSelectionSet

  typealias MutableInlineFragment = AniTrackAPI_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      switch typename {
      case "AiringSchedule": return AniTrackAPI.Objects.AiringSchedule
      case "Deleted": return AniTrackAPI.Objects.Deleted
      case "FuzzyDate": return AniTrackAPI.Objects.FuzzyDate
      case "Media": return AniTrackAPI.Objects.Media
      case "MediaConnection": return AniTrackAPI.Objects.MediaConnection
      case "MediaCoverImage": return AniTrackAPI.Objects.MediaCoverImage
      case "MediaEdge": return AniTrackAPI.Objects.MediaEdge
      case "MediaList": return AniTrackAPI.Objects.MediaList
      case "MediaListCollection": return AniTrackAPI.Objects.MediaListCollection
      case "MediaListGroup": return AniTrackAPI.Objects.MediaListGroup
      case "MediaTitle": return AniTrackAPI.Objects.MediaTitle
      case "MediaTrailer": return AniTrackAPI.Objects.MediaTrailer
      case "Mutation": return AniTrackAPI.Objects.Mutation
      case "Page": return AniTrackAPI.Objects.Page
      case "PageInfo": return AniTrackAPI.Objects.PageInfo
      case "Query": return AniTrackAPI.Objects.Query
      case "Studio": return AniTrackAPI.Objects.Studio
      case "StudioConnection": return AniTrackAPI.Objects.StudioConnection
      case "User": return AniTrackAPI.Objects.User
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}