import Foundation

struct AniListOAuthConfig {
    /// Register your app at https://anilist.co/settings/developer and paste your client ID here.
    static let clientID = "36956"

    /// Client secret (optional for public clients when using PKCE). If AniList issued a secret for your app, you can add it here.
    static let clientSecret: String? = "0BErvYv4J3VTWkXwnSJTHfRNDGd5agYLJeIhZHZp"

    /// OAuth endpoints
    static let authorizeEndpoint = URL(string: "https://anilist.co/api/v2/oauth/authorize")!
    static let tokenEndpoint = URL(string: "https://anilist.co/api/v2/oauth/token")!

    /// The redirect URI should be registered with AniList. Use a custom scheme (example below).
    static let redirectScheme = "anitrack"
    static let redirectHost = "oauth"
    static var redirectURI: String { "\(redirectScheme)://\(redirectHost)" }

    static func authorizeURL(state: String, codeChallenge: String) -> URL {
        var components = URLComponents(url: authorizeEndpoint, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "scope", value: "user"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
        ]
        return components.url!
    }
}
