import Foundation

struct AniListTokenRecord: Codable {
    let token: String
    let expiresAt: Date?

    var isExpired: Bool {
        if let expiresAt {
            return Date() >= expiresAt
        }
        return false
    }
}

final class AniListAuthStore: ObservableObject {
    @Published private(set) var record: AniListTokenRecord?

    var accessToken: String? {
        record?.token
    }

    var isAuthenticated: Bool {
        guard let record else { return false }
        return !record.isExpired
    }

    private let keychainService = "com.xavitordera.anitrack.auth"
    private let keychainAccount = "aniListToken"

    init() {
        self.record = loadRecord()
        if let record, record.isExpired {
            clear()
        }
    }

    func updateToken(_ token: String, expiresIn: Int?) {
        let expires = expiresIn.map { Date().addingTimeInterval(TimeInterval($0)) }
        let newRecord = AniListTokenRecord(token: token, expiresAt: expires)
        record = newRecord
        persist(record: newRecord)
    }

    func clear() {
        record = nil
        try? KeychainHelper.delete(service: keychainService, account: keychainAccount)
    }

    private func persist(record: AniListTokenRecord) {
        guard let data = try? JSONEncoder().encode(record) else { return }
        try? KeychainHelper.save(data, service: keychainService, account: keychainAccount)
    }

    private func loadRecord() -> AniListTokenRecord? {
        guard let data = try? KeychainHelper.read(service: keychainService, account: keychainAccount) else {
            return nil
        }
        return try? JSONDecoder().decode(AniListTokenRecord.self, from: data)
    }
}
