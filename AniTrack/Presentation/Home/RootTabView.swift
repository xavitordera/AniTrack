import SwiftUI

struct RootTabView: View {
    private let container = AppContainer()

    var body: some View {
        TabView {
            AniTrackHomeView(
                viewModel: HomeViewModel(
                    repository: container.animeRepository,
                    listRepository: container.listRepository,
                    authStore: container.authStore
                ),
                makeDetailViewModel: { animeID in
                    AnimeDetailViewModel(
                        animeID: animeID,
                        repository: container.animeRepository,
                        listRepository: container.listRepository,
                        authStore: container.authStore
                    )
                }
            )
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            DiscoverView(
                viewModel: DiscoverViewModel(repository: container.animeRepository),
                makeDetailViewModel: { animeID in
                    AnimeDetailViewModel(
                        animeID: animeID,
                        repository: container.animeRepository,
                        listRepository: container.listRepository,
                        authStore: container.authStore
                    )
                }
            )
                .tabItem {
                    Label("Discover", systemImage: "safari.fill")
                }

            MyListView(
                viewModel: MyListViewModel(repository: container.listRepository),
                authStore: container.authStore
            )
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
