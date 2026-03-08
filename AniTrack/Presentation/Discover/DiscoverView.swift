import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel: DiscoverViewModel
    private let makeDetailViewModel: (Int) -> AnimeDetailViewModel

    @State private var isFilterSheetPresented = false

    init(viewModel: DiscoverViewModel, makeDetailViewModel: @escaping (Int) -> AnimeDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeDetailViewModel = makeDetailViewModel
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let horizontalPadding = max(12, min(20, proxy.size.width * 0.045))
                let contentWidth = max(220, proxy.size.width - (horizontalPadding * 2))

                ZStack {
                    LinearGradient(
                        colors: [Color(red: 0.02, green: 0.09, blue: 0.17), AniTrackTheme.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            topBar
                            searchBar
                            activeFiltersRow

                            if viewModel.isLoadingInitial {
                                loadingGrid(contentWidth: contentWidth)
                            } else if viewModel.items.isEmpty {
                                emptyState
                            } else {
                                mediaGrid(contentWidth: contentWidth)
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, 10)
                        .padding(.bottom, 22)
                    }
                    .refreshable {
                        await viewModel.loadInitial()
                    }
                }
            }
            .navigationBarHidden(true)
            .task {
                if viewModel.items.isEmpty {
                    await viewModel.loadInitial()
                }
            }
            .sheet(isPresented: $isFilterSheetPresented) {
                DiscoverFilterSheet(
                    viewModel: viewModel,
                    isPresented: $isFilterSheetPresented
                )
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
        }
    }

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Discover")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                Text("Find your next anime")
                    .font(.subheadline)
                    .foregroundStyle(AniTrackTheme.mutedText)
            }

            Spacer()

            Button {
                isFilterSheetPresented = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.3")
                    Text(viewModel.activeFilterCount == 0 ? "Filters" : "Filters \(viewModel.activeFilterCount)")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    Capsule(style: .continuous)
                        .fill(AniTrackTheme.card)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AniTrackTheme.mutedText)
            TextField("Search title", text: $viewModel.searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(.white)
                .submitLabel(.search)
                .onSubmit {
                    Task {
                        await viewModel.applyFilters()
                    }
                }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    Task {
                        await viewModel.applyFilters()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AniTrackTheme.mutedText)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AniTrackTheme.surface)
        )
    }

    private var activeFiltersRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let season = viewModel.selectedSeason {
                    filterPill(text: season.capitalized)
                }
                if let year = viewModel.selectedYear {
                    filterPill(text: String(year))
                }
                if let format = viewModel.selectedFormat {
                    filterPill(text: format)
                }
                if let status = viewModel.selectedStatus {
                    filterPill(text: readable(status))
                }
                ForEach(Array(viewModel.selectedGenres).sorted(), id: \.self) { genre in
                    filterPill(text: genre)
                }
                if viewModel.activeFilterCount == 0 {
                    Text("No filters")
                        .font(.caption)
                        .foregroundStyle(AniTrackTheme.mutedText)
                }
            }
        }
    }

    private func mediaGrid(contentWidth: CGFloat) -> some View {
        let columns = gridColumns(contentWidth: contentWidth)

        return LazyVGrid(columns: columns, spacing: 14) {
            ForEach(viewModel.items) { anime in
                NavigationLink {
                    AnimeDetailView(
                        viewModel: makeDetailViewModel(anime.id),
                        makeDetailViewModel: makeDetailViewModel
                    )
                } label: {
                    RecommendedPosterCard(anime: anime)
                }
                .buttonStyle(.plain)
                .task {
                    await viewModel.loadMoreIfNeeded(currentItem: anime)
                }
            }

            if viewModel.isLoadingMore {
                ForEach(0..<2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AniTrackTheme.card.opacity(0.75))
                        .frame(height: 184)
                        .shimmering()
                }
            }
        }
    }

    private func loadingGrid(contentWidth: CGFloat) -> some View {
        let columns = gridColumns(contentWidth: contentWidth)

        return LazyVGrid(columns: columns, spacing: 14) {
            ForEach(0..<8, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AniTrackTheme.card.opacity(0.75))
                    .frame(height: 184)
                    .shimmering()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles.tv")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(AniTrackTheme.accent)
            Text("No results found")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Try a broader search or remove some filters.")
                .font(.subheadline)
                .foregroundStyle(AniTrackTheme.mutedText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private func gridColumns(contentWidth: CGFloat) -> [GridItem] {
        let count = contentWidth > 500 ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: count)
    }

    private func filterPill(text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(AniTrackTheme.accent)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(AniTrackTheme.surface)
            )
    }

    private func readable(_ raw: String) -> String {
        raw
            .lowercased()
            .split(separator: "_")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}

private struct DiscoverFilterSheet: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    section(title: "Sort") {
                        Picker("Sort", selection: $viewModel.selectedSort) {
                            ForEach(DiscoverViewModel.SortOption.all) { option in
                                Text(option.title).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    section(title: "Season") {
                        chipRow(items: viewModel.availableSeasons, selected: viewModel.selectedSeason) { value in
                            viewModel.selectedSeason = viewModel.selectedSeason == value ? nil : value
                        }
                    }

                    section(title: "Year") {
                        Menu {
                            Button("Any") { viewModel.selectedYear = nil }
                            ForEach(viewModel.availableYears, id: \.self) { year in
                                Button(String(year)) { viewModel.selectedYear = year }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.selectedYear.map(String.init) ?? "Any Year")
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(AniTrackTheme.surface)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    section(title: "Format") {
                        chipRow(items: viewModel.availableFormats, selected: viewModel.selectedFormat) { value in
                            viewModel.selectedFormat = viewModel.selectedFormat == value ? nil : value
                        }
                    }

                    section(title: "Status") {
                        chipRow(items: viewModel.availableStatuses, selected: viewModel.selectedStatus) { value in
                            viewModel.selectedStatus = viewModel.selectedStatus == value ? nil : value
                        }
                    }

                    section(title: "Genres") {
                        AdaptiveChipWrap(items: viewModel.availableGenres) { genre in
                            Button {
                                if viewModel.selectedGenres.contains(genre) {
                                    viewModel.selectedGenres.remove(genre)
                                } else {
                                    viewModel.selectedGenres.insert(genre)
                                }
                            } label: {
                                Text(genre)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(viewModel.selectedGenres.contains(genre) ? AniTrackTheme.accent : .white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule(style: .continuous)
                                            .fill(viewModel.selectedGenres.contains(genre) ? AniTrackTheme.card.opacity(0.95) : AniTrackTheme.surface)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .background(AniTrackTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        viewModel.clearFilters()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        isPresented = false
                        Task {
                            await viewModel.applyFilters()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            content()
        }
    }

    private func chipRow(items: [String], selected: String?, onTap: @escaping (String) -> Void) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Button {
                        onTap(item)
                    } label: {
                        Text(readable(item))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(selected == item ? AniTrackTheme.accent : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(selected == item ? AniTrackTheme.card.opacity(0.95) : AniTrackTheme.surface)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func readable(_ raw: String) -> String {
        raw
            .lowercased()
            .split(separator: "_")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}

private struct AdaptiveChipWrap<Item: Hashable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let columns = [GridItem(.adaptive(minimum: max(90, totalWidth * 0.26)), spacing: 8, alignment: .leading)]
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    content(item)
                }
            }
        }
        .frame(minHeight: 140)
    }
}

#Preview {
    DiscoverView(
        viewModel: DiscoverViewModel(repository: AniListAnimeRepository()),
        makeDetailViewModel: { AnimeDetailViewModel(animeID: $0, repository: AniListAnimeRepository()) }
    )
}
