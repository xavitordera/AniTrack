import SwiftUI

struct AnimeDetailView: View {
    @StateObject private var viewModel: AnimeDetailViewModel
    private let makeDetailViewModel: (Int) -> AnimeDetailViewModel

    init(viewModel: AnimeDetailViewModel, makeDetailViewModel: @escaping (Int) -> AnimeDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeDetailViewModel = makeDetailViewModel
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let headerHeight = max(250, min(360, width * 0.78))

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if let detail = viewModel.detail {
                        header(detail: detail, height: headerHeight)
                        titleBlock(detail: detail)
                        actionRow
                        if let nextAiring = viewModel.nextAiring {
                            airingCard(nextAiring: nextAiring)
                            if let reminderMessage = viewModel.reminderMessage {
                                Text(reminderMessage)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AniTrackTheme.accent)
                                    .padding(.horizontal, 16)
                            }
                        }
                        statGrid(detail: detail)
                        infoChips(detail: detail)
                        if !detail.relations.isEmpty {
                            relations(detail: detail)
                        }
                        synopsis(detail: detail)
                        if !detail.studios.isEmpty {
                            studios(detail: detail)
                        }
                    } else if viewModel.isLoading {
                        skeleton(headerHeight: headerHeight)
                    }
                }
                .padding(.bottom, 26)
            }
            .background(AniTrackTheme.background.ignoresSafeArea())
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.toggleTracked() }
                } label: {
                    if viewModel.isUpdatingList {
                        ProgressView()
                            .tint(AniTrackTheme.accent)
                    } else {
                        Image(systemName: viewModel.isTracked ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(viewModel.isTracked ? AniTrackTheme.accent : .white)
                    }
                }
                .disabled(viewModel.isUpdatingList)
            }
        }
        .task {
            await viewModel.load()
        }
        .alert("Error", isPresented: Binding(get: {
            viewModel.errorText != nil
        }, set: { showing in
            if !showing { viewModel.errorText = nil }
        })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorText ?? "")
        }
    }

    private func header(detail: AnimeDetail, height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 0, style: .continuous)
                    .fill(AniTrackTheme.surface)

                RemoteImageView(urlString: detail.bannerImage ?? detail.coverImage, contentMode: .fit)
            }
            .frame(maxWidth: .greatestFiniteMagnitude)
            .clipped()

            HStack(alignment: .bottom, spacing: 12) {
                RemoteImageView(urlString: detail.coverImage, contentMode: .fill)
                    .frame(width: 96, height: 144)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .clipped()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(.white.opacity(0.14), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        if let score = detail.score {
                            Label("\(score)", systemImage: "star.fill")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.yellow)
                        }
                        Text(detail.seasonLabel)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    Text(detail.title)
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
        }
    }

    private func titleBlock(detail: AnimeDetail) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(detail.subtitle)
                .font(.caption)
                .foregroundStyle(AniTrackTheme.mutedText)
                .lineLimit(1)
            Text(detail.genres.prefix(3).joined(separator: " • ").isEmpty ? "Anime" : detail.genres.prefix(3).joined(separator: " • "))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.92))
        }
        .padding(.horizontal, 16)
    }

    private var actionRow: some View {
        HStack(spacing: 10) {
            Button("Watch Trailer") {}
                .font(.subheadline.weight(.bold))
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(AniTrackTheme.accent)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Button("Add To List") {
                Task { await viewModel.toggleTracked() }
            }
            .font(.subheadline.weight(.bold))
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(viewModel.isTracked ? AniTrackTheme.accent : AniTrackTheme.surface)
            .foregroundStyle(viewModel.isTracked ? .black : .white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .disabled(viewModel.isUpdatingList)
        }
        .padding(.horizontal, 16)
    }

    private func airingCard(nextAiring: AiringScheduleInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Next Episode")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)

                Spacer(minLength: 10)

                Button {
                    Task {
                        await viewModel.scheduleReminderForNextEpisode()
                    }
                } label: {
                    if viewModel.isSchedulingReminder {
                        ProgressView()
                            .tint(AniTrackTheme.accent)
                    } else {
                        Label("Remind Me", systemImage: "bell.badge")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AniTrackTheme.accent)
                    }
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isSchedulingReminder)
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Episode \(nextAiring.episode)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("Airs \(Self.airingDateFormatter.string(from: nextAiring.airingAt))")
                        .font(.caption)
                        .foregroundStyle(AniTrackTheme.mutedText)
                }
                Spacer(minLength: 10)
                Text(viewModel.countdownText ?? "--")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AniTrackTheme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        Capsule(style: .continuous)
                            .fill(AniTrackTheme.surface)
                    )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AniTrackTheme.card)
        )
        .padding(.horizontal, 16)
    }

    private func statGrid(detail: AnimeDetail) -> some View {
        let cards: [StatItem] = [
            StatItem(label: "Episodes", value: detail.episodes.map(String.init) ?? "-"),
            StatItem(label: "Duration", value: detail.duration.map { "\($0)m" } ?? "-"),
            StatItem(label: "Status", value: detail.status),
            StatItem(label: "Format", value: detail.format),
            StatItem(label: "Source", value: detail.source),
            StatItem(label: "Popularity", value: detail.popularity.map(String.init) ?? "-")
        ]

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(cards) { card in
                VStack(alignment: .leading, spacing: 5) {
                    Text(card.label)
                        .font(.caption2)
                        .foregroundStyle(AniTrackTheme.mutedText)
                    Text(card.value)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AniTrackTheme.card)
                )
            }
        }
        .padding(.horizontal, 16)
    }

    private func infoChips(detail: AnimeDetail) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(detail.genres.prefix(8), id: \.self) { genre in
                    Text(genre)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule().fill(AniTrackTheme.surface)
                        )
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func synopsis(detail: AnimeDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Synopsis")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
            Text(detail.description)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
    }

    private func relations(detail: AnimeDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Franchise")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(detail.relations) { relation in
                        NavigationLink {
                            AnimeDetailView(
                                viewModel: makeDetailViewModel(relation.id),
                                makeDetailViewModel: makeDetailViewModel
                            )
                        } label: {
                            relationCard(relation: relation)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func relationCard(relation: AnimeRelation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RemoteImageView(urlString: relation.coverImage, contentMode: .fill)
                .frame(width: 132, height: 176)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .clipped()

            Text(relation.relationType)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(AniTrackTheme.accent)
                .lineLimit(1)

            Text(relation.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)

            HStack(spacing: 6) {
                Text(relation.format)
                    .font(.caption2)
                    .foregroundStyle(AniTrackTheme.mutedText)
                if let score = relation.score {
                    Label("\(score)", systemImage: "star.fill")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.yellow)
                }
            }
            .lineLimit(1)
        }
        .frame(width: 132, alignment: .leading)
    }

    private func studios(detail: AnimeDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Studios")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(detail.studios, id: \.self) { studio in
                        Text(studio)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AniTrackTheme.accent)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                Capsule().fill(AniTrackTheme.surface)
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func skeleton(headerHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 0)
                .fill(AniTrackTheme.card.opacity(0.65))
                .frame(height: headerHeight)
                .shimmering()

            RoundedRectangle(cornerRadius: 8)
                .fill(AniTrackTheme.card.opacity(0.65))
                .frame(width: 200, height: 18)
                .shimmering()
                .padding(.horizontal, 16)

            RoundedRectangle(cornerRadius: 8)
                .fill(AniTrackTheme.card.opacity(0.65))
                .frame(width: 260, height: 14)
                .shimmering()
                .padding(.horizontal, 16)

            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(AniTrackTheme.card.opacity(0.65))
                    .frame(height: 64)
                    .padding(.horizontal, 16)
                    .shimmering()
            }
        }
    }
}

private struct StatItem: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}

extension AnimeDetailView {
    private static let airingDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    AnimeDetailView(
        viewModel: AnimeDetailViewModel(
            animeID: 1,
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
