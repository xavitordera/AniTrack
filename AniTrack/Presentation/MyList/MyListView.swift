import SwiftUI

struct MyListView: View {
    @StateObject private var viewModel: MyListViewModel
    @ObservedObject private var authStore: AniListAuthStore

    @State private var editingEntry: MediaListEntry?
    @State private var showingBulkSheet = false
    @State private var isAuthenticating = false
    @State private var authError: String?
    @State private var selectedFilter: ListFilter = .all

    init(viewModel: MyListViewModel, authStore: AniListAuthStore) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.authStore = authStore
    }

    var body: some View {
        NavigationStack {
            Group {
                if authStore.accessToken == nil {
                    tokenPrompt
                } else if viewModel.isLoading && viewModel.entries.isEmpty {
                    ProgressView("Loading list…")
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AniTrackTheme.background)
                } else if viewModel.entries.isEmpty {
                    emptyState
                } else {
                    content
                }
            }
            .toolbar {
                if viewModel.selectionMode {
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: { showingBulkSheet = true }) {
                            Text("Bulk update")
                                .fontWeight(.semibold)
                        }
                        .disabled(viewModel.selectedIDs.isEmpty || viewModel.isBulkApplying)
                    }
                }
            }
            .refreshable { await viewModel.reload() }
            .onAppear { if authStore.accessToken != nil { Task { await viewModel.load() } } }
            .onChange(of: authStore.accessToken) { _, token in
                if token == nil {
                    viewModel.entries.removeAll()
                    selectedFilter = .all
                } else {
                    Task { await viewModel.load() }
                }
            }
            .onChange(of: viewModel.requiresAuthentication) { _, needsAuth in
                if needsAuth {
                    authStore.clear()
                    viewModel.requiresAuthentication = false
                }
            }
            .alert("Error", isPresented: Binding(get: { viewModel.errorText != nil }, set: { _ in viewModel.errorText = nil })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorText ?? "")
            }
            .sheet(item: $editingEntry) { entry in
                MyListEntryEditor(entry: entry) { patch in
                    Task { await viewModel.update(entry: entry, with: patch) }
                    editingEntry = nil
                } onCancel: {
                    editingEntry = nil
                }
            }
            .sheet(isPresented: $showingBulkSheet) {
                MyListBulkEditor(isApplying: viewModel.isBulkApplying) { bulkPatch in
                    Task { await viewModel.applyBulk(patch: bulkPatch) }
                    showingBulkSheet = false
                } onCancel: {
                    showingBulkSheet = false
                }
            }
            .overlay(alignment: .bottom) {
                if let message = viewModel.actionMessage {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(AniTrackTheme.surface))
                        .padding()
                } else if viewModel.isBulkApplying {
                    ProgressView("Updating…")
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(AniTrackTheme.surface))
                        .padding()
                }
            }
        }
    }

    private var tokenPrompt: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Connect AniTrack to AniList to persist your watch progress, scores, and dates.")
                    .foregroundStyle(.white)
                Text("Tap Sign In / Sign Up to open the AniList OAuth flow. The returned token stays on this device.")
                    .foregroundStyle(AniTrackTheme.mutedText)
                    .font(.callout)
                Button {
                    startOAuthFlow()
                } label: {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.plus")
                        Text(isAuthenticating ? "Authenticating…" : "Sign In / Sign Up")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isAuthenticating)
                if isAuthenticating {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                if let authError {
                    Text(authError)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                Link("Need help generating a token?", destination: URL(string: "https://anilist.co/settings/developer")!)
                    .font(.caption)
                    .foregroundStyle(AniTrackTheme.accent)
            }
            .padding()
        }
        .background(AniTrackTheme.background.ignoresSafeArea())
    }

    private func startOAuthFlow() {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        authError = nil

        Task {
            do {
                let response = try await AniListOAuthManager.shared.authorize()
                await MainActor.run {
                    authStore.updateToken(response.token, expiresIn: response.expiresIn)
                }
            } catch AniListOAuthError.userCancelled {
                // user backed out; no change needed
            } catch {
                await MainActor.run {
                    authError = error.localizedDescription
                }
            }
            await MainActor.run {
                isAuthenticating = false
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                filterStrip

                LazyVStack(spacing: 14) {
                    ForEach(displayedEntries) { entry in
                        MyListEntryRow(
                            entry: entry,
                            selectionMode: viewModel.selectionMode,
                            isSelected: viewModel.isSelected(entry)
                        ) {
                            editingEntry = entry
                        } onDelete: {
                            Task { await viewModel.delete(entry: entry) }
                        } onToggleSelection: {
                            viewModel.setSelection(for: entry)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .background(AniTrackTheme.background)
    }

    private var content: some View {
        ZStack {
            AniTrackTheme.background.ignoresSafeArea()
            list
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(AniTrackTheme.accent)
            Text("Your AniList is empty")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Add an anime from its detail screen and it will appear here.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(AniTrackTheme.mutedText)
                .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AniTrackTheme.background)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("My List")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                if let viewer = viewModel.viewer {
                    Text(viewer.name ?? "AniList user")
                        .font(.caption)
                        .foregroundStyle(AniTrackTheme.mutedText)
                }
            }

            Spacer()

            HStack(spacing: 10) {
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .frame(width: 36, height: 36)
                        .background(AniTrackTheme.surface)
                        .clipShape(Circle())
                }

                Menu {
                    Button(viewModel.selectionMode ? "Done Selecting" : "Select Entries") {
                        viewModel.toggleSelectionMode()
                    }
                    Button("Sign Out", role: .destructive, action: signOut)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .frame(width: 36, height: 36)
                        .background(AniTrackTheme.surface)
                        .clipShape(Circle())
                }
            }
        }
    }

    private var filterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filters) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(filter.color)
                                .frame(width: 7, height: 7)
                            Text(filter.label)
                                .font(.caption.weight(.semibold))
                            Text("\(count(for: filter))")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(
                            Capsule(style: .continuous)
                                .fill(selectedFilter == filter ? AniTrackTheme.surface : AniTrackTheme.card)
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(selectedFilter == filter ? AniTrackTheme.accent.opacity(0.6) : .clear, lineWidth: 1)
                        )
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var filters: [ListFilter] {
        [.all] + MediaListStatus.allCases.map(ListFilter.status)
    }

    private var displayedEntries: [MediaListEntry] {
        switch selectedFilter {
        case .all:
            return viewModel.entries
        case .status(let status):
            return viewModel.entries.filter { $0.status == status }
        }
    }

    private func count(for filter: ListFilter) -> Int {
        switch filter {
        case .all:
            return viewModel.entries.count
        case .status(let status):
            return viewModel.entries.filter { $0.status == status }.count
        }
    }

    private func signOut() {
        authStore.clear()
    }
}

private enum ListFilter: Hashable, Identifiable {
    case all
    case status(MediaListStatus)

    var id: String {
        switch self {
        case .all:
            return "all"
        case .status(let status):
            return status.rawValue
        }
    }

    var label: String {
        switch self {
        case .all:
            return "All"
        case .status(let status):
            return status.displayName
        }
    }

    var color: Color {
        switch self {
        case .all:
            return AniTrackTheme.accent
        case .status(.current):
            return Color(red: 0.25, green: 0.62, blue: 0.98)
        case .status(.completed):
            return Color(red: 0.22, green: 0.78, blue: 0.45)
        case .status(.planning):
            return Color(red: 0.47, green: 0.29, blue: 0.96)
        case .status(.onHold):
            return Color(red: 0.93, green: 0.67, blue: 0.20)
        case .status(.dropped):
            return Color(red: 0.93, green: 0.38, blue: 0.32)
        case .status(.repeating):
            return Color(red: 0.86, green: 0.45, blue: 0.93)
        }
    }
}

private struct MyListEntryRow: View {
    let entry: MediaListEntry
    let selectionMode: Bool
    let isSelected: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleSelection: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if selectionMode {
                Button(action: onToggleSelection) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(AniTrackTheme.accent)
                        .font(.title2)
                        .padding(.top, 6)
                }
                .buttonStyle(.plain)
            }

            RemoteImageView(urlString: entry.media.coverImage, contentMode: .fill)
                .frame(width: 74, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AniTrackTheme.surface)
                )

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.media.title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        Text(entry.displaySubtitle.isEmpty ? entry.status.displayName : entry.displaySubtitle)
                            .font(.caption)
                            .foregroundStyle(AniTrackTheme.mutedText)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 6)

                    Menu {
                        Button("Edit", action: onEdit)
                        Button("Remove", role: .destructive, action: onDelete)
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(6)
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 6) {
                    ForEach(Array(entry.media.genres.prefix(3)), id: \.self) { genre in
                        Text(genre)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.72))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(AniTrackTheme.surface)
                            )
                    }
                }

                HStack(spacing: 12) {
                    Label(progressLabel, systemImage: "play.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AniTrackTheme.mutedText)
                    if let score = entry.score {
                        Label(scoreLabel(score), systemImage: "star.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.yellow)
                    }
                }

                if let progress = entry.progress {
                    ProgressView(value: Double(progress), total: Double(max(entry.media.episodes ?? max(progress, 1), 1)))
                        .tint(AniTrackTheme.accent)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AniTrackTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.05), lineWidth: 1)
        )
        .onTapGesture {
            if selectionMode {
                onToggleSelection()
            } else {
                onEdit()
            }
        }
    }

    private var progressLabel: String {
        if let progress = entry.progress, let total = entry.media.episodes, total > 0 {
            return "\(progress)/\(total)"
        }
        if let progress = entry.progress {
            return "\(progress) eps"
        }
        return "No progress"
    }

    private func scoreLabel(_ score: Double) -> String {
        if score.rounded(.towardZero) == score {
            return String(Int(score))
        }
        return String(format: "%.1f", score)
    }
}

private struct MyListEntryEditor: View {
    let entry: MediaListEntry
    let onSave: (MediaListEntryPatch) -> Void
    let onCancel: () -> Void

    @State private var status: MediaListStatus
    @State private var progress: Int
    @State private var hasScore: Bool
    @State private var scoreValue: Int
    @State private var includeStartDate: Bool
    @State private var startDate: Date
    @State private var includeCompletionDate: Bool
    @State private var completionDate: Date

    init(entry: MediaListEntry, onSave: @escaping (MediaListEntryPatch) -> Void, onCancel: @escaping () -> Void) {
        self.entry = entry
        self.onSave = onSave
        self.onCancel = onCancel
        _status = State(initialValue: entry.status)
        _progress = State(initialValue: entry.progress ?? 0)
        _scoreValue = State(initialValue: Int(entry.score ?? 0))
        _hasScore = State(initialValue: entry.score != nil)
        _includeStartDate = State(initialValue: entry.startedAt != nil)
        _includeCompletionDate = State(initialValue: entry.completedAt != nil)
        _startDate = State(initialValue: Self.date(from: entry.startedAt) ?? Date())
        _completionDate = State(initialValue: Self.date(from: entry.completedAt) ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(MediaListStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    Stepper(value: $progress, in: 0...(entry.media.episodes ?? max(10, progress)), step: 1) {
                        Text("Progress: \(progress)")
                    }
                    Toggle("Track Score", isOn: $hasScore)
                    if hasScore {
                        Stepper(value: $scoreValue, in: 0...100, step: 5) {
                            Text("Score: \(scoreValue)")
                        }
                    }
                }
                Section("Dates") {
                    Toggle("Started", isOn: $includeStartDate)
                    if includeStartDate {
                        DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                    }
                    Toggle("Completed", isOn: $includeCompletionDate)
                    if includeCompletionDate {
                        DatePicker("Completion date", selection: $completionDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle(entry.media.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(patch())
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: onCancel)
                }
            }
        }
    }

    private func patch() -> MediaListEntryPatch {
        var result = MediaListEntryPatch(id: entry.id, mediaId: entry.media.id)
        result.status = status
        result.progress = progress
        result.score = hasScore ? Double(scoreValue) : nil
        result.startedAt = includeStartDate ? fuzzyDate(from: startDate) : nil
        result.completedAt = includeCompletionDate ? fuzzyDate(from: completionDate) : nil
        return result
    }

    private func fuzzyDate(from date: Date) -> FuzzyDateInput {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return FuzzyDateInput(year: comps.year, month: comps.month, day: comps.day)
    }

    private static func date(from fuzzy: FuzzyDate?) -> Date? {
        guard let fuzzy else { return nil }
        var components = DateComponents()
        components.year = fuzzy.year
        components.month = fuzzy.month
        components.day = fuzzy.day
        return Calendar.current.date(from: components)
    }
}

private struct MyListBulkEditor: View {
    let isApplying: Bool
    let onSave: (MediaListBulkPatch) -> Void
    let onCancel: () -> Void

    @State private var status: MediaListStatus = .current
    @State private var applyProgress = false
    @State private var progressValue = 0
    @State private var applyScore = false
    @State private var scoreValue = 0
    @State private var includeStart = false
    @State private var startDate = Date()
    @State private var includeCompletion = false
    @State private var completionDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Bulk Status") {
                    Picker("Status", selection: $status) {
                        ForEach(MediaListStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                }
                Section("Bulk Progress") {
                    Toggle("Update progress", isOn: $applyProgress)
                    if applyProgress {
                        Stepper(value: $progressValue, in: 0...200) {
                            Text("Progress: \(progressValue)")
                        }
                    }
                }
                Section("Bulk Score") {
                    Toggle("Update score", isOn: $applyScore)
                    if applyScore {
                        Stepper(value: $scoreValue, in: 0...100, step: 5) {
                            Text("Score: \(scoreValue)")
                        }
                    }
                }
                Section("Dates") {
                    Toggle("Set start date", isOn: $includeStart)
                    if includeStart {
                        DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                    }
                    Toggle("Set completion date", isOn: $includeCompletion)
                    if includeCompletion {
                        DatePicker("Completion date", selection: $completionDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Bulk update")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { onSave(patch()) }) {
                        if isApplying {
                            ProgressView()
                        } else {
                            Text("Apply")
                        }
                    }
                    .disabled(isApplying)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: onCancel)
                }
            }
        }
    }

    private func patch() -> MediaListBulkPatch {
        var patch = MediaListBulkPatch()
        patch.status = status
        if applyProgress {
            patch.progress = progressValue
        }
        if applyScore {
            patch.score = Double(scoreValue)
        }
        if includeStart {
            patch.startedAt = fuzzyDate(from: startDate)
        }
        if includeCompletion {
            patch.completedAt = fuzzyDate(from: completionDate)
        }
        return patch
    }

    private func fuzzyDate(from date: Date) -> FuzzyDateInput {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return FuzzyDateInput(year: comps.year, month: comps.month, day: comps.day)
    }
}
