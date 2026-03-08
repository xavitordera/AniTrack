import SwiftUI

struct RootTabView: View {
    private let container = AppContainer()

    var body: some View {
        TabView {
            AniTrackHomeView(
                viewModel: HomeViewModel(repository: container.animeRepository),
                makeDetailViewModel: { animeID in
                    AnimeDetailViewModel(animeID: animeID, repository: container.animeRepository)
                }
            )
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            DiscoverView(
                viewModel: DiscoverViewModel(repository: container.animeRepository),
                makeDetailViewModel: { animeID in
                    AnimeDetailViewModel(animeID: animeID, repository: container.animeRepository)
                }
            )
                .tabItem {
                    Label("Discover", systemImage: "safari.fill")
                }

            PlaceholderScreen(title: "My List", icon: "bookmark.fill")
                .tabItem {
                    Label("My List", systemImage: "bookmark.fill")
                }

            PlaceholderScreen(title: "Stats", icon: "chart.bar.fill")
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
        }
        .tint(AniTrackTheme.accent)
    }
}

private struct PlaceholderScreen: View {
    let title: String
    let icon: String

    var body: some View {
        ZStack {
            AniTrackTheme.background.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AniTrackTheme.accent)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Coming soon")
                    .font(.subheadline)
                    .foregroundStyle(AniTrackTheme.mutedText)
            }
        }
    }
}

#Preview {
    RootTabView()
}
