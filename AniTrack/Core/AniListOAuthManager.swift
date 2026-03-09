import AuthenticationServices
import CryptoKit
import OSLog
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
    private let urlSession = URLSession.shared
    private let logger = Logger(subsystem: "com.xavitordera.anitrack", category: "auth")

    func authorize() async throws -> AniListOAuthResponse {
        let state = UUID().uuidString
        let codeVerifier = PKCE.generateVerifier()
        let codeChallenge = PKCE.challenge(for: codeVerifier)
        let url = AniListOAuthConfig.authorizeURL(
            state: state,
            codeChallenge: AniListOAuthConfig.flow == .authorizationCodePKCE ? codeChallenge : nil
        )

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
                    if AniListOAuthConfig.flow == .implicitToken {
                        let token = try Self.extractToken(from: callbackURL, expectedState: state)
                        continuation.resume(returning: token)
                        return
                    }
                    let (code, returnedState) = try Self.extractCode(from: callbackURL)
                    guard returnedState == state else {
                        throw AniListOAuthError.stateMismatch
                    }
                    guard let strongSelf = self else {
                        throw AniListOAuthError.other("OAuth session was interrupted.")
                    }
                    Task {
                        do {
                            let response = try await strongSelf.exchangeCode(code: code, codeVerifier: codeVerifier)
                            continuation.resume(returning: response)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            session?.presentationContextProvider = self
            session?.prefersEphemeralWebBrowserSession = true
            session?.start()
        }
    }

    private func exchangeCode(code: String, codeVerifier: String) async throws -> AniListOAuthResponse {
        var request = URLRequest(url: AniListOAuthConfig.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let includeSecret = AniListOAuthConfig.clientSecret != nil
        let attempts = includeSecret ? [true, false] : [false]
        var lastError: Error?
        for includeSecretVariant in attempts {
            do {
                return try await performTokenRequest(
                    code: code,
                    codeVerifier: codeVerifier,
                    includeSecret: includeSecretVariant
                )
            } catch {
                logger.error("Token exchange failed (secret=\(includeSecretVariant)) \(error.localizedDescription, privacy: .public)")
                lastError = error
            }
        }
        throw lastError ?? AniListOAuthError.other("Token exchange failed")
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
                acc[String(pair[0])] = String(pair[1]).removingPercentEncoding
            }
        if let returnedState = pairs["state"], returnedState != expectedState {
            throw AniListOAuthError.stateMismatch
        }
        guard let token = pairs["access_token"], !token.isEmpty else {
            throw AniListOAuthError.missingToken
        }
        let expiresIn = pairs["expires_in"].flatMap(Int.init)
        return AniListOAuthResponse(token: token, expiresIn: expiresIn, refreshToken: nil)
    }

    private func performTokenRequest(code: String, codeVerifier: String, includeSecret: Bool) async throws -> AniListOAuthResponse {
        var request = URLRequest(url: AniListOAuthConfig.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var parameters: [String: String] = [
            "grant_type": "authorization_code",
            "client_id": AniListOAuthConfig.clientID,
            "redirect_uri": AniListOAuthConfig.redirectURI,
            "code": code,
            "code_verifier": codeVerifier
        ]
        if includeSecret, let secret = AniListOAuthConfig.clientSecret, !secret.isEmpty {
            parameters["client_secret"] = secret
        }

        request.httpBody = Self.formEncodedBody(from: parameters)

        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AniListOAuthError.other("Invalid token response.")
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? ""
            throw AniListOAuthError.other("Token endpoint error: \(httpResponse.statusCode) - \(message)")
        }

        let decoded = try JSONDecoder().decode(AniListTokenExchangeResponse.self, from: data)
        return AniListOAuthResponse(
            token: decoded.accessToken,
            expiresIn: decoded.expiresIn,
            refreshToken: decoded.refreshToken
        )
    }

    private static func extractCode(from url: URL) throws -> (code: String, state: String) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            throw AniListOAuthError.missingToken
        }
        if let errorItem = queryItems.first(where: { $0.name == "error" }),
           let value = errorItem.value {
            throw AniListOAuthError.other(value)
        }
        guard let code = queryItems.first(where: { $0.name == "code" })?.value else {
            throw AniListOAuthError.missingToken
        }
        guard let state = queryItems.first(where: { $0.name == "state" })?.value else {
            throw AniListOAuthError.missingToken
        }
        return (code, state)
    }

    private static func formEncodedBody(from parameters: [String: String]) -> Data? {
        var components = URLComponents()
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components.percentEncodedQuery?.data(using: .utf8)
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

private struct AniListTokenExchangeResponse: Decodable {
    let accessToken: String
    let expiresIn: Int?
    let refreshToken: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }
}

private struct PKCE {
    static func generateVerifier() -> String {
        var data = Data()
        data.reserveCapacity(64)
        for _ in 0..<64 {
            data.append(UInt8.random(in: 0...255))
        }
        return data.base64URLEncodedString()
    }

    static func challenge(for verifier: String) -> String {
        let hashed = SHA256.hash(data: Data(verifier.utf8))
        return Data(hashed).base64URLEncodedString()
    }
}

private extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .trimmingCharacters(in: CharacterSet(charactersIn: "="))
    }
}
