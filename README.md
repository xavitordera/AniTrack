# AniTrack (iOS)

AniTrack is a SwiftUI iOS app using MVVM and AniList GraphQL data.

## What is implemented

- SwiftUI app structure with `TabView` and a mobile-first `Home` screen.
- MVVM setup:
  - `HomeViewModel` for state and filtering
  - `AnimeRepository` abstraction
  - `AniListAnimeRepository` data implementation
- GraphQL integration targeting `https://graphql.anilist.co`
- Apollo iOS added as Swift Package dependency in the Xcode project.
- Home sections adapted from the desktop screenshot for mobile:
  - Top brand bar and search
  - Horizontal categories
  - Featured hero banner
  - Popular this season list
  - Continue watching carousel
  - Airing now list
  - Recommended carousel

## Project layout

- `AniTrack/App`: app entry and container
- `AniTrack/Presentation`: views and view models
- `AniTrack/Domain`: entities and repository protocol
- `AniTrack/Data`: AniList GraphQL service, queries, DTOs, repository
- `GraphQL/Operations`: `.graphql` operations for Apollo codegen

## Apollo + GraphQL notes

The app already includes `ApolloClient` initialization and an AniList GraphQL service. To switch fully to generated Apollo operation types:

1. Download AniList schema to `GraphQL/schema.graphqls`.
2. Run Apollo iOS codegen using `apollo-codegen-config.json`.
3. Replace raw query execution with generated `HomeFeedQuery` types.

## AniList query reference used

Based on media querying patterns documented at:
- https://docs.anilist.co/guide/graphql/queries/media

