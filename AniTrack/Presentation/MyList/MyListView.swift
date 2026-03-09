import SwiftUI

struct MyListView: View {
    @StateObject private var viewModel: MyListViewModel
    @ObservedObject private var authStore: AniListAuthStore

    @State private var editingEntry: MediaListEntry?
    @State private var showingBulkSheet = false
    @State private var isAuthenticating = false
    @State private var authError: String?

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
                } else {
                    list
                }
            }
            .navigationTitle("My List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: signOut) {
                        Text(authStore.accessToken == nil ? "" : "Sign Out")
                    }
                    .disabled(authStore.accessToken == nil)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.toggleSelectionMode) {
                        Text(viewModel.selectionMode ? "Done" : "Select")
                    }
                    .disabled(viewModel.entries.isEmpty)
                }
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
            .onChange(of: authStore.accessToken) { token in
                if token == nil {
                    viewModel.entries.removeAll()
                } else {
                    Task { await viewModel.load() }
                }
            }
            .onChange(of: viewModel.requiresAuthentication) { needsAuth in
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
        List {
            if let viewer = viewModel.viewer {
                Section("Signed in as") {
                    HStack {
                        Text(viewer.name ?? "AniList user")
                            .foregroundStyle(.white)
                    }
                }
            }

            ForEach(viewModel.groupedEntries, id: \.status) { group in
                Section(header: Text(group.status.displayName)) {
                    ForEach(group.entries) { entry in
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
        }
        .listStyle(.insetGrouped)
        .background(AniTrackTheme.background)
    }

    private func signOut() {
        authStore.clear()
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
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(AniTrackTheme.accent)
                    .font(.title2)
                    .padding(.top, 6)
                    .onTapGesture { onToggleSelection() }
            }

            RemoteImageView(urlString: entry.media.coverImage, contentMode: .fill)
                .frame(width: 56, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.media.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(entry.displaySubtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                if let progress = entry.progress {
                    ProgressView(value: Double(progress), total: Double(max(entry.media.episodes ?? 1, 1)))
                        .tint(AniTrackTheme.accent)
                    if let total = entry.media.episodes, total > 0 {
                        Text("\(progress) / \(total)")
                            .font(.caption2)
                            .foregroundStyle(AniTrackTheme.mutedText)
                    } else {
                        Text("\(progress) episodes tracked")
                            .font(.caption2)
                            .foregroundStyle(AniTrackTheme.mutedText)
                    }
                }
                if let score = entry.score {
                    Label(String(format: "%.1f", score), systemImage: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                }
                if let start = entry.startedAt, !start.localizedDescription.isEmpty {
                    Text("Started \(start.localizedDescription)")
                        .font(.caption2)
                        .foregroundStyle(AniTrackTheme.mutedText)
                }
                if let complete = entry.completedAt, !complete.localizedDescription.isEmpty {
                    Text("Completed \(complete.localizedDescription)")
                        .font(.caption2)
                        .foregroundStyle(AniTrackTheme.mutedText)
                }
            }
            Spacer()
            VStack(spacing: 6) {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                .buttonStyle(.bordered)
                Button(role: .destructive, action: onDelete) {
                    Label("Remove", systemImage: "trash")
                }
                .buttonStyle(.bordered)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if selectionMode {
                onToggleSelection()
            } else {
                onEdit()
            }
        }
        .listRowBackground(AniTrackTheme.card)
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
