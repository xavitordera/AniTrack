// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension AniTrackAPI {
  struct MediaCard: AniTrackAPI.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment MediaCard on Media { __typename id title { __typename romaji english } description(asHtml: false) episodes averageScore genres bannerImage coverImage { __typename large } }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.Media }
    static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", Int.self),
      .field("title", Title?.self),
      .field("description", String?.self, arguments: ["asHtml": false]),
      .field("episodes", Int?.self),
      .field("averageScore", Int?.self),
      .field("genres", [String?]?.self),
      .field("bannerImage", String?.self),
      .field("coverImage", CoverImage?.self),
    ] }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
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

    /// Title
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
        MediaCard.Title.self
      ] }

      /// The romanization of the native language title
      var romaji: String? { __data["romaji"] }
      /// The official english title
      var english: String? { __data["english"] }
    }

    /// CoverImage
    ///
    /// Parent Type: `MediaCoverImage`
    struct CoverImage: AniTrackAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { AniTrackAPI.Objects.MediaCoverImage }
      static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("large", String?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MediaCard.CoverImage.self
      ] }

      /// The cover image url of the media at a large size
      var large: String? { __data["large"] }
    }
  }

}