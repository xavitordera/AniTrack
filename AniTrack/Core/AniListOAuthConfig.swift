import Foundation

struct AniListOAuthConfig {
    enum Flow {
        case implicitToken
        case authorizationCodePKCE
    }

    /// AniList currently expects authorization-code exchange for this client.
    static let flow: Flow = .authorizationCodePKCE

    /// Register your app at https://anilist.co/settings/developer and paste your client ID here.
    static let clientID = "37017"

    /// Client secret (optional for public clients when using PKCE). If AniList issued a secret for your app, you can add it here.
    static let clientSecret: String? = "M11U3sHJZCgh5RFJ0mn0EMo4MBeqzhsJ0pKF8IH0"

    /// OAuth endpoints
    static let authorizeEndpoint = URL(string: "https://anilist.co/api/v2/oauth/authorize")!
    static let tokenEndpoint = URL(string: "https://anilist.co/api/v2/oauth/token")!

    /// The redirect URI should be registered with AniList. Use a custom scheme (example below).
    static let redirectScheme = "anitrack"
    static let redirectHost = "oauth"
    static var redirectURI: String { "\(redirectScheme)://\(redirectHost)" }

    static func authorizeURL(state: String, codeChallenge: String?) -> URL {
        var components = URLComponents(url: authorizeEndpoint, resolvingAgainstBaseURL: false)!
        var items: [URLQueryItem] = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: flow == .authorizationCodePKCE ? "code" : "token"),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "state", value: state),
        ]
        if flow == .authorizationCodePKCE, let codeChallenge {
            items.append(URLQueryItem(name: "code_challenge", value: codeChallenge))
            items.append(URLQueryItem(name: "code_challenge_method", value: "S256"))
        }
        components.queryItems = items
        return components.url!
    }
}
