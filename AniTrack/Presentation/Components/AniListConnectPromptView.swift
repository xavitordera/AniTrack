import SwiftUI

struct AniListConnectPromptView: View {
    @ObservedObject var authStore: AniListAuthStore

    @State private var isAuthenticating = false
    @State private var authError: String?

    var body: some View {
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
}
