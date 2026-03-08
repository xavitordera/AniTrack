import Apollo
import Foundation
import OSLog

enum AniListServiceError: Error {
    case emptyData
    case graphQLErrors([String])
    case unauthorized
}

final class AniListGraphQLService {
    private let endpoint = "https://graphql.anilist.co"
    private let logger = Logger(subsystem: "com.xavitordera.anitrack", category: "network")

    // Apollo is configured for this endpoint so generated operations can be plugged in later.
    let apolloClient: ApolloClient

    init() {
        self.apolloClient = ApolloClient(url: URL(string: endpoint)!)
    }

    func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .fetchIgnoringCacheCompletely
    ) async throws -> Query.Data {
        let operationName = Query.operationName
        logger.info("➡️ Apollo request started: \(operationName, privacy: .public)")

        return try await withCheckedThrowingContinuation { continuation in
            _ = apolloClient.fetch(
                query: query,
                cachePolicy: cachePolicy,
                queue: .global(qos: .userInitiated)
            ) { result in
                switch result {
                case .failure(let error):
                    self.logger.error(
                        "❌ Apollo transport failure: \(operationName, privacy: .public) error=\(String(describing: error), privacy: .public)"
                    )
                    continuation.resume(throwing: error)
                case .success(let response):
                    if let errors = response.errors, !errors.isEmpty {
                        let messages = errors.compactMap(\.message)
                        self.logger.error(
                            "❌ Apollo GraphQL errors: \(operationName, privacy: .public) \(messages.joined(separator: " | "), privacy: .public)"
                        )
                        continuation.resume(throwing: AniListServiceError.graphQLErrors(messages))
                        return
                    }

                    guard let data = response.data else {
                        self.logger.error("❌ Apollo empty data: \(operationName, privacy: .public)")
                        continuation.resume(throwing: AniListServiceError.emptyData)
                        return
                    }

                    self.logger.info("⬅️ Apollo response: \(operationName, privacy: .public)")
                    continuation.resume(returning: data)
                }
            }
        }
    }
}
