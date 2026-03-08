import AuthenticationServices
import UIKit

enum AniListOAuthError: Error {
    case userCancelled
    case missingToken
    case stateMismatch
    case other(String)
}

final class AniListOAuthManager: NSObject {
    static let shared = AniListOAuthManager()

    private var session: ASWebAuthenticationSession?

    func authorize() async throws -> AniListOAuthResponse {
        let state = UUID().uuidString
        let url = AniListOAuthConfig.authorizeURL(state: state)

        return try await withCheckedThrowingContinuation { continuation in
            session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: AniListOAuthConfig.redirectScheme
            ) { [weak self] callbackURL, error in
                defer { self?.session = nil }

                if let error = error as? ASWebAuthenticationSessionError, error.code == .canceledLogin {
                    continuation.resume(throwing: AniListOAuthError.userCancelled)
                    return
                }
                if let error = error {
                    continuation.resume(throwing: AniListOAuthError.other(error.localizedDescription))
                    return
                }
                guard let callbackURL = callbackURL else {
                    continuation.resume(throwing: AniListOAuthError.missingToken)
                    return
                }
                do {
                    let token = try Self.extractToken(from: callbackURL, expectedState: state)
                    continuation.resume(returning: token)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            session?.presentationContextProvider = self
            session?.prefersEphemeralWebBrowserSession = true
            session?.start()
        }
    }

    private static func extractToken(from url: URL, expectedState: String) throws -> AniListOAuthResponse {
        guard let fragment = url.fragment else {
            throw AniListOAuthError.missingToken
        }
        let pairs = fragment
            .split(separator: "&")
            .map { $0.split(separator: "=") }
            .reduce(into: [String: String]()) { acc, pair in
                guard pair.count == 2 else { return }
                let key = String(pair[0])
                let value = String(pair[1])
                acc[key] = value
            }

        if let returnedState = pairs["state"], returnedState != expectedState {
            throw AniListOAuthError.stateMismatch
        }
        guard let token = pairs["access_token"], !token.isEmpty else {
            throw AniListOAuthError.missingToken
        }
        let expiresIn = pairs["expires_in"].flatMap { Int($0) }
        return AniListOAuthResponse(token: token, expiresIn: expiresIn)
    }
}

extension AniListOAuthManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }
}
