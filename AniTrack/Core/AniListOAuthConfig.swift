import Foundation

struct AniListOAuthConfig {
    /// Register your app at https://anilist.co/settings/developer and paste your client ID here.
    static let clientID = "<YOUR_CLIENT_ID>"

    /// The redirect URI should be registered with AniList. Use a custom scheme (example below).
    static let redirectScheme = "anitrack"
    static let redirectHost = "oauth"
    static var redirectURI: String { "\(redirectScheme)://\(redirectHost)" }

    static func authorizeURL(state: String) -> URL {
        var components = URLComponents(string: "https://anilist.co/api/v2/oauth/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "scope", value: "user"),
        ]
        return components.url!
    }
}
