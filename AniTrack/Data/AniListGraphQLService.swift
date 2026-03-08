import Apollo
import Foundation
import OSLog

enum GraphQLValue: Encodable {
    case int(Int)
    case string(String)
    case bool(Bool)
    case array([GraphQLValue])
    case null

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

struct GraphQLRequestBody: Encodable {
    let query: String
    let variables: [String: GraphQLValue]
}

struct GraphQLError: Decodable {
    let message: String
}

struct GraphQLResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [GraphQLError]?
}

enum AniListServiceError: Error {
    case invalidURL
    case emptyData
    case graphQLErrors([String])
}

final class AniListGraphQLService {
    private let endpoint = "https://graphql.anilist.co"
    private let session: URLSession
    private let logger = Logger(subsystem: "com.xavitordera.anitrack", category: "network")
    private let tokenProvider: () -> String?

    // Apollo is configured for this endpoint so generated operations can be plugged in later.
    let apolloClient: ApolloClient

    init(session: URLSession = .shared, tokenProvider: @escaping () -> String? = { nil }) {
        self.session = session
        self.tokenProvider = tokenProvider
        self.apolloClient = ApolloClient(url: URL(string: endpoint)!)
    }

    func execute<T: Decodable>(query: String, variables: [String: GraphQLValue], responseType: T.Type) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw AniListServiceError.invalidURL
        }

        let operationName = Self.extractOperationName(from: query)
        let start = Date()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = tokenProvider(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(GraphQLRequestBody(query: query, variables: variables))

        logger.info("➡️ GraphQL request started: \(operationName, privacy: .public) vars=\(String(describing: variables), privacy: .public)")

        do {
            let (data, response) = try await session.data(for: request)
            let elapsedMs = Int(Date().timeIntervalSince(start) * 1000)
            if let http = response as? HTTPURLResponse {
                logger.info("⬅️ GraphQL response: \(operationName, privacy: .public) status=\(http.statusCode) bytes=\(data.count) timeMs=\(elapsedMs)")
            } else {
                logger.info("⬅️ GraphQL response: \(operationName, privacy: .public) bytes=\(data.count) timeMs=\(elapsedMs)")
            }

            let decoded = try JSONDecoder().decode(GraphQLResponse<T>.self, from: data)

            if let errors = decoded.errors, !errors.isEmpty {
                let messages = errors.map(\.message).joined(separator: " | ")
                logger.error("❌ GraphQL errors: \(operationName, privacy: .public) \(messages, privacy: .public)")
                throw AniListServiceError.graphQLErrors(errors.map(\.message))
            }

            guard let payload = decoded.data else {
                logger.error("❌ GraphQL empty data: \(operationName, privacy: .public)")
                throw AniListServiceError.emptyData
            }

            return payload
        } catch {
            logger.error("❌ GraphQL transport/decode failure: \(operationName, privacy: .public) error=\(String(describing: error), privacy: .public)")
            throw error
        }
    }

    private static func extractOperationName(from query: String) -> String {
        query
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first(where: { $0.hasPrefix("query ") || $0.hasPrefix("mutation ") })
            .flatMap { line in
                let parts = line.split(separator: " ")
                return parts.count > 1 ? String(parts[1]) : nil
            } ?? "UnknownOperation"
    }
}
