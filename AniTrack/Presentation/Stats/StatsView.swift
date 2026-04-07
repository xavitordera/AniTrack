import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel: StatsViewModel
    @ObservedObject private var authStore: AniListAuthStore

    init(viewModel: StatsViewModel, authStore: AniListAuthStore) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.authStore = authStore
    }

    var body: some View {
        NavigationStack {
            ZStack {
                dashboardBackground

                Group {
                    if !authStore.isAuthenticated {
                        AniListConnectPromptView(authStore: authStore)
                    } else if viewModel.isLoading && viewModel.dashboard == nil {
                        loadingView
                    } else if let dashboard = viewModel.dashboard {
                        dashboardView(dashboard)
                    } else {
                        errorView
                    }
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                viewModel.syncAuthentication(isAuthenticated: authStore.isAuthenticated)
            }
            .onChange(of: authStore.isAuthenticated) {
                viewModel.syncAuthentication(isAuthenticated: authStore.isAuthenticated)
            }
            .refreshable {
                await viewModel.load()
            }
        }
    }

    private var dashboardBackground: some View {
        ZStack {
            AniTrackTheme.background.ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.08, blue: 0.16),
                    AniTrackTheme.background,
                    Color(red: 0.02, green: 0.05, blue: 0.11)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(AniTrackTheme.accent.opacity(0.16))
                .frame(width: 280, height: 280)
                .blur(radius: 50)
                .offset(x: 140, y: -250)

            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 220, height: 220)
                .blur(radius: 70)
                .offset(x: -130, y: 260)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 18) {
            ProgressView()
                .tint(AniTrackTheme.accent)
                .scaleEffect(1.2)

            Text("Building your dashboard…")
                .foregroundStyle(.white)
                .font(.headline)

            Text("Pulling your AniList stats and shaping the overview.")
                .foregroundStyle(AniTrackTheme.mutedText)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AniTrackTheme.card)
                    .frame(width: 72, height: 72)

                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AniTrackTheme.accent)
            }

            Text(viewModel.errorText ?? "Unable to load stats.")
                .foregroundStyle(.white)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            Button("Retry") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
            .tint(AniTrackTheme.accent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
    }

    private func dashboardView(_ dashboard: StatsDashboard) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                heroCard(dashboard)
                metricGrid(dashboard.overview)
                analyticsStrip(dashboard.overview)
                pieSection(
                    title: "Top Genres",
                    subtitle: "What defines your watch profile",
                    items: dashboard.genres,
                    symbol: "sparkles",
                    palette: [
                        AniTrackTheme.accent,
                        Color(red: 0.38, green: 0.78, blue: 1.0),
                        Color(red: 0.47, green: 0.93, blue: 0.66),
                        Color(red: 1.0, green: 0.73, blue: 0.32),
                        Color(red: 0.98, green: 0.52, blue: 0.66)
                    ]
                )
                pieSection(
                    title: "Top Studios",
                    subtitle: "Studios showing up the most",
                    items: dashboard.studios,
                    symbol: "building.2.crop.circle",
                    palette: [
                        Color(red: 0.38, green: 0.78, blue: 1.0),
                        AniTrackTheme.accent,
                        Color(red: 0.82, green: 0.65, blue: 1.0),
                        Color(red: 1.0, green: 0.73, blue: 0.32),
                        Color(red: 0.56, green: 0.98, blue: 0.58)
                    ]
                )
                statusBreakdownSection(dashboard.statusBreakdown)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
    }

    private func heroCard(_ dashboard: StatsDashboard) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Anime Dashboard")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    Text("@\(dashboard.userName)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AniTrackTheme.mutedText)
                }

                Spacer()

                Image(systemName: "waveform.path.ecg.rectangle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AniTrackTheme.accent)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.black.opacity(0.18))
                    )
            }

            HStack(spacing: 18) {
                circularHighlight(
                    title: "Avg Score",
                    value: dashboard.overview.averageScore > 0 ? Int(dashboard.overview.averageScore.rounded()) : 0,
                    accent: AniTrackTheme.accent
                )

                VStack(alignment: .leading, spacing: 10) {
                    heroStat(
                        title: "Episodes watched",
                        value: "\(dashboard.overview.episodesWatched)",
                        icon: "play.circle.fill"
                    )
                    heroStat(
                        title: "Hours logged",
                        value: String(format: "%.1f", dashboard.overview.hoursWatched),
                        icon: "clock.fill"
                    )
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AniTrackTheme.card,
                            Color(red: 0.05, green: 0.15, blue: 0.24)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AniTrackTheme.accent.opacity(0.22), lineWidth: 1)
        )
    }

    private func circularHighlight(title: String, value: Int, accent: Color) -> some View {
        let normalized = min(max(CGFloat(value) / 100.0, 0.08), 1.0)

        return ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 12)

            Circle()
                .trim(from: 0, to: normalized)
                .stroke(
                    AngularGradient(
                        colors: [accent.opacity(0.3), accent, Color.white.opacity(0.9)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 4) {
                Text(value > 0 ? "\(value)" : "--")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AniTrackTheme.mutedText)
            }
        }
        .frame(width: 114, height: 114)
    }

    private func heroStat(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AniTrackTheme.accent)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.black.opacity(0.18))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(AniTrackTheme.mutedText)
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
            }

            Spacer()
        }
    }

    private func metricGrid(_ overview: StatsOverview) -> some View {
        let items: [(String, String, String)] = [
            ("Completed", "\(overview.completedAnime)", "checkmark.seal.fill"),
            ("Episodes", "\(overview.episodesWatched)", "film.stack.fill"),
            ("Hours", String(format: "%.1f", overview.hoursWatched), "timer"),
            ("Score", overview.averageScore > 0 ? String(format: "%.1f", overview.averageScore) : "-", "star.fill")
        ]

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(items, id: \.0) { item in
                metricCard(title: item.0, value: item.1, icon: item.2)
            }
        }
    }

    private func metricCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AniTrackTheme.accent)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(AniTrackTheme.surface)
                    )
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                Text(title.uppercased())
                    .font(.caption2.weight(.semibold))
                    .kerning(0.8)
                    .foregroundStyle(AniTrackTheme.mutedText)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AniTrackTheme.card.opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func analyticsStrip(_ overview: StatsOverview) -> some View {
        HStack(spacing: 12) {
            statPill(
                title: "Minutes watched",
                value: "\(overview.minutesWatched)",
                icon: "bolt.horizontal.circle.fill"
            )
            statPill(
                title: "Completed share",
                value: completionRatioText(overview),
                icon: "chart.pie.fill"
            )
        }
    }

    private func statPill(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(AniTrackTheme.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(AniTrackTheme.mutedText)
                Text(value)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AniTrackTheme.surface.opacity(0.95))
        )
    }

    private func pieSection(
        title: String,
        subtitle: String,
        items: [StatsCountItem],
        symbol: String,
        palette: [Color]
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AniTrackTheme.mutedText)
                }

                Spacer()

                Image(systemName: symbol)
                    .foregroundStyle(AniTrackTheme.accent)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AniTrackTheme.surface)
                    )
            }

            if items.isEmpty {
                emptyCard(text: "No data yet")
            } else {
                let slices = Array(items.prefix(5).enumerated()).map { index, item in
                    PieSliceData(
                        item: item,
                        color: palette[index % palette.count]
                    )
                }

                HStack(alignment: .center, spacing: 18) {
                    PieChartView(slices: slices)
                        .frame(width: 148, height: 148)

                    VStack(spacing: 10) {
                        ForEach(Array(slices.enumerated()), id: \.element.item.id) { index, slice in
                            pieLegendRow(
                                item: slice.item,
                                rank: index + 1,
                                color: slice.color,
                                total: slices.map(\.item.count).reduce(0, +)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.leading, 6)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AniTrackTheme.card.opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func pieLegendRow(item: StatsCountItem, rank: Int, color: Color, total: Int) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(rank). \(item.name)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text("\(item.count) entries · \(Int((Double(item.count) / Double(max(total, 1)) * 100).rounded()))%")
                    .font(.caption)
                    .foregroundStyle(AniTrackTheme.mutedText)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.14))
        )
    }

    private func statusBreakdownSection(_ statuses: [StatsStatusItem]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Status Flow")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("How your list is distributed")
                        .font(.caption)
                        .foregroundStyle(AniTrackTheme.mutedText)
                }

                Spacer()

                Image(systemName: "chart.bar.doc.horizontal.fill")
                    .foregroundStyle(AniTrackTheme.accent)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AniTrackTheme.surface)
                    )
            }

            if statuses.isEmpty {
                emptyCard(text: "No status data yet")
            } else {
                let total = max(statuses.map(\.count).reduce(0, +), 1)

                VStack(spacing: 12) {
                    ForEach(statuses) { item in
                        statusRow(item: item, total: total)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AniTrackTheme.card.opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func statusRow(item: StatsStatusItem, total: Int) -> some View {
        let ratio = CGFloat(item.count) / CGFloat(total)

        return HStack(spacing: 12) {
            Image(systemName: statusSymbol(for: item.status))
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(statusColor(for: item.status))
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AniTrackTheme.surface)
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(Int((ratio * 100).rounded()))%")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AniTrackTheme.mutedText)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AniTrackTheme.surface)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        statusColor(for: item.status).opacity(0.55),
                                        statusColor(for: item.status)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(14, proxy.size.width * ratio))
                    }
                }
                .frame(height: 10)
            }

            Text("\(item.count)")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 32, alignment: .trailing)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.14))
        )
    }

    private func emptyCard(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(AniTrackTheme.mutedText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black.opacity(0.14))
            )
    }

    private func completionRatioText(_ overview: StatsOverview) -> String {
        let base = max(overview.completedAnime, 1)
        let ratio = Double(overview.completedAnime) / Double(base + max(overview.episodesWatched / 24, 0))
        return "\(Int((ratio * 100).rounded()))%"
    }

    private func statusSymbol(for status: MediaListStatus) -> String {
        switch status {
        case .current: return "play.fill"
        case .planning: return "bookmark.fill"
        case .completed: return "checkmark.circle.fill"
        case .onHold: return "pause.fill"
        case .dropped: return "xmark.circle.fill"
        case .repeating: return "repeat.circle.fill"
        }
    }

    private func statusColor(for status: MediaListStatus) -> Color {
        switch status {
        case .current:
            return AniTrackTheme.accent
        case .planning:
            return Color(red: 0.64, green: 0.80, blue: 1.0)
        case .completed:
            return Color(red: 0.56, green: 0.98, blue: 0.58)
        case .onHold:
            return Color(red: 1.0, green: 0.73, blue: 0.32)
        case .dropped:
            return Color(red: 1.0, green: 0.47, blue: 0.47)
        case .repeating:
            return Color(red: 0.82, green: 0.65, blue: 1.0)
        }
    }
}

private struct PieSliceData {
    let item: StatsCountItem
    let color: Color
}

private struct PieChartView: View {
    let slices: [PieSliceData]

    var body: some View {
        GeometryReader { proxy in
            let frame = min(proxy.size.width, proxy.size.height)
            let lineWidth = frame * 0.24
            let total = max(slices.map(\.item.count).reduce(0, +), 1)

            ZStack {
                Circle()
                    .stroke(AniTrackTheme.surface, lineWidth: lineWidth)

                ForEach(Array(slices.enumerated()), id: \.element.item.id) { index, slice in
                    let start = startFraction(for: index, total: total)
                    let end = endFraction(for: index, total: total)

                    Circle()
                        .trim(from: start, to: end)
                        .stroke(slice.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                        .rotationEffect(.degrees(-90))
                }

                VStack(spacing: 4) {
                    Text("\(total)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("total")
                        .font(.caption)
                        .foregroundStyle(AniTrackTheme.mutedText)
                }
            }
            .frame(width: frame, height: frame)
        }
    }

    private func startFraction(for index: Int, total: Int) -> CGFloat {
        let prior = slices.prefix(index).map(\.item.count).reduce(0, +)
        return CGFloat(Double(prior) / Double(total))
    }

    private func endFraction(for index: Int, total: Int) -> CGFloat {
        let upto = slices.prefix(index + 1).map(\.item.count).reduce(0, +)
        return CGFloat(Double(upto) / Double(total))
    }
}

#Preview {
    let container = AppContainer()
    StatsView(
        viewModel: StatsViewModel(service: container.statsService),
        authStore: container.authStore
    )
}
