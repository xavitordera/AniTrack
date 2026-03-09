// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension AniTrackAPI {
  /// Date object that allows for incomplete date values (fuzzy)
  struct FuzzyDateInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      year: GraphQLNullable<Int> = nil,
      month: GraphQLNullable<Int> = nil,
      day: GraphQLNullable<Int> = nil
    ) {
      __data = InputDict([
        "year": year,
        "month": month,
        "day": day
      ])
    }

    /// Numeric Year (2017)
    var year: GraphQLNullable<Int> {
      get { __data["year"] }
      set { __data["year"] = newValue }
    }

    /// Numeric Month (3)
    var month: GraphQLNullable<Int> {
      get { __data["month"] }
      set { __data["month"] = newValue }
    }

    /// Numeric Day (24)
    var day: GraphQLNullable<Int> {
      get { __data["day"] }
      set { __data["day"] = newValue }
    }
  }

}