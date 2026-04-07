import SwiftUI

struct AniTrackHomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var selectedDetailID: SelectedAnime?
    private let makeDetailViewModel: (Int) -> AnimeDetailViewModel

    init(viewModel: HomeViewModel, makeDetailViewModel: @escaping (Int) -> AnimeDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeDetailViewModel = makeDetailViewModel
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let screenWidth = proxy.size.width
                let horizontalPadding = max(12, min(20, screenWidth * 0.045))
                let contentWidth = max(220, screenWidth - (horizontalPadding * 2))

                ZStack {
                    LinearGradient(
                        colors: [Color(red: 0.02, green: 0.09, blue: 0.17), AniTrackTheme.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    VStack(spacing: 0) {
                        topChrome(horizontalPadding: horizontalPadding)

                        ScrollView {
                            if isInitialLoading {
                                loadingSkeleton(contentWidth: contentWidth, horizontalPadding: horizontalPadding)
                            } else {
                                VStack(alignment: .leading, spacing: 16) {
                                    featuredSection(contentWidth: contentWidth)
                                    if !viewModel.filteredPopular.isEmpty {
                                        popularSection
                                    }
                                    continueTrackingSection(contentWidth: contentWidth)
                                    if !viewModel.airingToday.isEmpty {
                                        airingTodaySection
                                    }
                                    if !viewModel.recommended.isEmpty {
                                        recommendedSection(contentWidth: contentWidth)
                                    }
                                }
                                .padding(.horizontal, horizontalPadding)
                                .padding(.top, 12)
                                .padding(.bottom, 22)
                            }
                        }
                        .refreshable {
                            await viewModel.load()
                        }
                    }
                }
                .navigationBarHidden(true)
            }
            .task {
                await viewModel.load()
            }
            .alert("Error", isPresented: Binding(get: {
                viewModel.errorText != nil
            }, set: { isPresented in
                if !isPresented {
                    viewModel.errorText = nil
                }
            })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorText ?? "")
            }
            .navigationDestination(item: $selectedDetailID) { selection in
                detailDestination(animeID: selection.id)
            }
        }
    }

    private var isInitialLoading: Bool {
        viewModel.isLoading && viewModel.featured == nil && viewModel.popular.isEmpty
    }

    private func loadingSkeleton(contentWidth: CGFloat, horizontalPadding: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            skeletonHero(contentWidth: contentWidth)
            skeletonSectionHeader

            VStack(spacing: 10) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AniTrackTheme.card.opacity(0.7))
                        .frame(height: 92)
                        .shimmering()
                }
            }

            skeletonSectionHeader
            VStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AniTrackTheme.card.opacity(0.7))
                        .frame(height: 142)
                        .shimmering()
                }
            }

            skeletonSectionHeader
            VStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AniTrackTheme.card.opacity(0.7))
                        .frame(height: 56)
                        .shimmering()
                }
            }

            skeletonSectionHeader
            let columns = recommendedColumns(contentWidth: contentWidth)
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(0..<6, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AniTrackTheme.card.opacity(0.7))
                        .frame(height: 185)
                        .shimmering()
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 12)
        .padding(.bottom, 22)
    }

    private func skeletonHero(contentWidth: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(AniTrackTheme.card.opacity(0.75))
            .frame(height: heroHeight(contentWidth: contentWidth))
            .shimmering()
    }

    private var skeletonSectionHeader: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(AniTrackTheme.card.opacity(0.8))
            .frame(width: 170, height: 18)
            .shimmering()
    }

    private func topChrome(horizontalPadding: CGFloat) -> some View {
        VStack(spacing: 12) {
            topBar
            searchBar
            categoriesSection
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(
            LinearGradient(
                colors: [AniTrackTheme.background.opacity(0.98), AniTrackTheme.background.opacity(0.88)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var topBar: some View {
        HStack {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 7)
                    .fill(AniTrackTheme.accent)
                    .frame(width: 20, height: 20)
                    .overlay(Image(systemName: "play.fill").font(.caption2).foregroundStyle(.black))
                Text("AniTrack")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
            }

            Spacer()

            Button {
            } label: {
                Image(systemName: "bell")
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(AniTrackTheme.surface)
                    .clipShape(Circle())
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AniTrackTheme.mutedText)
            TextField("Search anime, characters, or genres", text: $viewModel.searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AniTrackTheme.surface)
        )
    }

    private var categoriesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.categories, id: \.self) { category in
                    CategoryChip(label: category, isSelected: viewModel.selectedCategory == category) {
                        viewModel.selectedCategory = category
                    }
                }
            }
        }
    }

    private func featuredSection(contentWidth: CGFloat) -> some View {
        Group {
            if let featured = viewModel.featured {
                FeaturedBannerCard(
                    anime: featured,
                    isTracked: viewModel.isTracked(featured.id),
                    isUpdatingTrackedState: viewModel.isUpdating(featured.id),
                    onWatch: {
                        selectedDetailID = SelectedAnime(id: featured.id)
                    },
                    onToggleList: {
                        Task { await viewModel.toggleTracked(for: featured) }
                    },
                    height: heroHeight(contentWidth: contentWidth)
                )
            } else {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AniTrackTheme.card.opacity(0.65))
                    .frame(height: max(170, heroHeight(contentWidth: contentWidth) - 30))
            }
        }
    }

    private var popularSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title: "Popular This Season")

            ForEach(Array(viewModel.filteredPopular.prefix(4).enumerated()), id: \.element.id) { index, anime in
                NavigationLink {
                    detailDestination(animeID: anime.id)
                } label: {
                    PopularRowCard(rank: index + 1, anime: anime)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func continueTrackingSection(contentWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title: "Continue Tracking")

            if viewModel.shouldShowTrackingPrompt {
                continueTrackingPrompt
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(viewModel.continueTracking) { item in
                            ContinueWatchingCard(
                                item: item,
                                isUpdating: viewModel.isUpdatingTracking(item.id),
                                onOpen: {
                                    selectedDetailID = SelectedAnime(id: item.id)
                                },
                                onPrimaryAction: {
                                    if item.primaryAction == .viewDetails {
                                        selectedDetailID = SelectedAnime(id: item.id)
                                    } else {
                                        Task { await viewModel.performPrimaryTrackingAction(for: item) }
                                    }
                                }
                            )
                            .frame(width: continueTrackingCardWidth(contentWidth: contentWidth))
                        }
                    }
                }
            }
        }
    }

    private var airingTodaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title: "Airing Now")

            ForEach(Array(viewModel.airingToday.prefix(5)), id: \.id) { anime in
                NavigationLink {
                    detailDestination(animeID: anime.id)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(anime.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text(anime.subtitle.isEmpty ? "Anime" : anime.subtitle)
                                .font(.caption2)
                                .foregroundStyle(AniTrackTheme.mutedText)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 8)
                        HStack(spacing: 6) {
                            Image(systemName: "dot.radiowaves.left.and.right")
                            Text(anime.genres.first ?? "Anime")
                        }
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AniTrackTheme.accent)
                        .lineLimit(1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(AniTrackTheme.card)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func recommendedSection(contentWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title: "Recommended For You")

            let columns = recommendedColumns(contentWidth: contentWidth)
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(viewModel.recommended.prefix(8)) { anime in
                    NavigationLink {
                        detailDestination(animeID: anime.id)
                    } label: {
                        RecommendedPosterCard(anime: anime)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func recommendedColumns(contentWidth: CGFloat) -> [GridItem] {
        let count = contentWidth > 430 ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: count)
    }

    private func heroHeight(contentWidth: CGFloat) -> CGFloat {
        max(170, min(230, contentWidth * 0.54))
    }

    private func continueTrackingCardWidth(contentWidth: CGFloat) -> CGFloat {
        max(220, min(300, contentWidth * 0.8))
    }

    private var continueTrackingPrompt: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.isSignedIn ? "Nothing in progress yet" : "Sign in to keep your anime progress in sync")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)

            Text(
                viewModel.isSignedIn
                ? "When you start watching shows on AniList, they’ll appear here with quick episode actions."
                : "AniTrack can turn your AniList watch progress into quick home-screen actions once you connect your account."
            )
            .font(.caption)
            .foregroundStyle(AniTrackTheme.mutedText)

            if viewModel.isSignedIn {
                Button("Browse Trending") {
                    viewModel.browseTrendingCTA()
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AniTrackTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AniTrackTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
            Spacer()
        }
    }

    private func detailDestination(animeID: Int) -> some View {
        AnimeDetailView(
            viewModel: makeDetailViewModel(animeID),
            makeDetailViewModel: makeDetailViewModel
        )
    }
}

private struct SelectedAnime: Identifiable, Hashable {
    let id: Int
}

#Preview {
    AniTrackHomeView(
        viewModel: HomeViewModel(
            repository: AniListAnimeRepository(),
            listRepository: AniListListRepository(service: AniListGraphQLService(), authStore: AniListAuthStore()),
            authStore: AniListAuthStore()
        ),
        makeDetailViewModel: {
            AnimeDetailViewModel(
                animeID: $0,
                repository: AniListAnimeRepository(),
                listRepository: AniListListRepository(service: AniListGraphQLService(), authStore: AniListAuthStore()),
                authStore: AniListAuthStore()
            )
        }
    )
}
