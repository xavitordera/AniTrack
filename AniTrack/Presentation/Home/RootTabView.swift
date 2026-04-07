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

            StatsView(
                viewModel: StatsViewModel(service: container.statsService),
                authStore: container.authStore
            )
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
        }
        .tint(AniTrackTheme.accent)
    }
}

#Preview {
    RootTabView()
}
