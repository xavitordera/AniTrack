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
- `AniTrack/Data`: AniList GraphQL service and repository
- `GraphQL/Operations`: `.graphql` operations for Apollo codegen

## Sourcery mock generation workflow

The test target now uses Sourcery to generate the shared mocks used by the unit tests.

- Annotated protocols live in:
  - `AniTrack/Domain/AnimeRepository.swift`
  - `AniTrack/Domain/MyListRepository.swift`
  - `AniTrack/Core/LocalNotificationScheduler.swift`
- Sourcery config lives at `AniTrackTests/.sourcery.yml`
- Sourcery template lives at `AniTrackTests/Sourcery/Templates/AutoMockable.stencil`
- Generated mocks are committed at `AniTrackTests/Generated/AutoMockable.generated.swift`

Regenerate mocks after changing an annotated protocol:

1. Open the project in Xcode.
2. Run the Sourcery command plugin for the `AniTrackTests` target.
3. Commit the updated `AniTrackTests/Generated/AutoMockable.generated.swift`.

Notes:
- The generic `AniListGraphQLServing` protocol is intentionally still hand-mocked in tests. It is a poor fit for the current mock template because its API is generic over GraphQL operation types.
- The generated mocks intentionally preserve the existing test helper names (`MockAnimeRepository`, `MockListRepository`, `MockReminderScheduler`) so test code stays stable while the source of truth moves to Sourcery.

## Apollo code generation workflow

The project uses Apollo iOS codegen with configuration in `apollo-codegen-config.json`.

1. Ensure `apollo-ios-cli` is available at repo root.
2. Refresh schema from AniList:

```bash
./apollo-ios-cli fetch-schema
```

3. Generate models and operations:

```bash
./apollo-ios-cli generate
```

4. Commit updated files:
- `GraphQL/schema.graphqls`
- `GraphQL/Operations/*.graphql` (if changed)
- `AniTrack/Generated/**`

Notes:
- `GraphQL` is referenced in the Xcode project for easy editing.
- `GraphQL/schema.graphqls` is not part of the app target build phases; it is an input for code generation only.

## AniList query reference used

Based on media querying patterns documented at:
- https://docs.anilist.co/guide/graphql/queries/media
