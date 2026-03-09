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
