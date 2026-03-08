import Foundation

final class AniListAuthStore: ObservableObject {
    @Published var accessToken: String? {
        didSet {
            persistToken(accessToken)
        }
    }

    private let tokenKey = "AniTrack.AnilistAccessToken"

    init() {
        self.accessToken = UserDefaults.standard.string(forKey: tokenKey)
    }

    func updateToken(_ token: String?) {
        accessToken = token
    }

    func clear() {
        accessToken = nil
    }

    private func persistToken(_ token: String?) {
        let defaults = UserDefaults.standard
        if let token {
            defaults.set(token, forKey: tokenKey)
        } else {
            defaults.removeObject(forKey: tokenKey)
        }
    }
}
