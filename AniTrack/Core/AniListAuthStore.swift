import Foundation

struct AniListTokenRecord: Codable {
    let token: String
    let expiresAt: Date?
    let viewerID: Int?
    let viewerName: String?

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

    var viewer: AniListViewer? {
        guard let viewerID = record?.viewerID else { return nil }
        return AniListViewer(id: viewerID, name: record?.viewerName)
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
        let newRecord = AniListTokenRecord(
            token: token,
            expiresAt: expires,
            viewerID: record?.viewerID,
            viewerName: record?.viewerName
        )
        record = newRecord
        persist(record: newRecord)
    }

    func updateViewer(id: Int, name: String?) {
        guard let currentRecord = record else { return }
        let newRecord = AniListTokenRecord(
            token: currentRecord.token,
            expiresAt: currentRecord.expiresAt,
            viewerID: id,
            viewerName: name
        )
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
