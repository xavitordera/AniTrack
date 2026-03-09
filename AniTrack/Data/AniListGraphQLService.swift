import Apollo
import ApolloAPI
import Foundation
import OSLog

enum AniListServiceError: Error {
    case emptyData
    case graphQLErrors([String])
    case unauthorized
}

protocol AniListGraphQLServing {
    func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy
    ) async throws -> Query.Data

    func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        publishResultToStore: Bool
    ) async throws -> Mutation.Data
}

private final class AniListAuthorizationInterceptor: ApolloInterceptor {
    let id = UUID().uuidString

    private let tokenProvider: () -> String?

    init(tokenProvider: @escaping () -> String?) {
        self.tokenProvider = tokenProvider
    }

    func interceptAsync<Operation: GraphQLOperation>(
        chain: any RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
    ) {
        if let token = tokenProvider(), !token.isEmpty {
            request.addHeader(name: "Authorization", value: "Bearer \(token)")
        }

        chain.proceedAsync(
            request: request,
            response: response,
            interceptor: self,
            completion: completion
        )
    }
}

private final class AniListInterceptorProvider: InterceptorProvider {
    private let store: ApolloStore
    private let client: URLSessionClient
    private let tokenProvider: () -> String?

    init(store: ApolloStore, client: URLSessionClient = URLSessionClient(), tokenProvider: @escaping () -> String?) {
        self.store = store
        self.client = client
        self.tokenProvider = tokenProvider
    }

    func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [any ApolloInterceptor] {
        let jsonParsingInterceptor: any ApolloInterceptor = Operation.hasDeferredFragments
            ? IncrementalJSONResponseParsingInterceptor()
            : JSONResponseParsingInterceptor()

        return [
            MaxRetryInterceptor(),
            CacheReadInterceptor(store: store),
            AniListAuthorizationInterceptor(tokenProvider: tokenProvider),
            NetworkFetchInterceptor(client: client),
            ResponseCodeInterceptor(),
            MultipartResponseParsingInterceptor(),
            jsonParsingInterceptor,
            AutomaticPersistedQueryInterceptor(),
            CacheWriteInterceptor(store: store)
        ]
    }
}

final class AniListGraphQLService: AniListGraphQLServing {
    private let endpoint = "https://graphql.anilist.co"
    private let logger = Logger(subsystem: "com.xavitordera.anitrack", category: "network")

    let apolloClient: ApolloClient

    init(tokenProvider: @escaping () -> String? = { nil }) {
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let provider = AniListInterceptorProvider(store: store, tokenProvider: tokenProvider)
        let transport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: URL(string: endpoint)!
        )
        self.apolloClient = ApolloClient(networkTransport: transport, store: store)
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
                self.handle(result: result, operationName: operationName, continuation: continuation)
            }
        }
    }

    func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        publishResultToStore: Bool = false
    ) async throws -> Mutation.Data {
        let operationName = Mutation.operationName
        logger.info("➡️ Apollo mutation started: \(operationName, privacy: .public)")

        return try await withCheckedThrowingContinuation { continuation in
            _ = apolloClient.perform(
                mutation: mutation,
                publishResultToStore: publishResultToStore,
                queue: .global(qos: .userInitiated)
            ) { result in
                self.handle(result: result, operationName: operationName, continuation: continuation)
            }
        }
    }

    private func handle<SelectionSet: RootSelectionSet>(
        result: Result<GraphQLResult<SelectionSet>, any Error>,
        operationName: String,
        continuation: CheckedContinuation<SelectionSet, Error>
    ) {
        switch result {
        case .failure(let error):
            let mappedError = mapApolloError(error, operationName: operationName)
            logger.error(
                "❌ Apollo transport failure: \(operationName, privacy: .public) error=\(String(describing: mappedError), privacy: .public)"
            )
            continuation.resume(throwing: mappedError)
        case .success(let response):
            if let errors = response.errors, !errors.isEmpty {
                let messages = errors.compactMap(\.message)
                if messages.contains(where: Self.isUnauthorized(message:)) {
                    logger.error("❌ Apollo unauthorized: \(operationName, privacy: .public)")
                    continuation.resume(throwing: AniListServiceError.unauthorized)
                    return
                }

                logger.error(
                    "❌ Apollo GraphQL errors: \(operationName, privacy: .public) \(messages.joined(separator: " | "), privacy: .public)"
                )
                continuation.resume(throwing: AniListServiceError.graphQLErrors(messages))
                return
            }

            guard let data = response.data else {
                logger.error("❌ Apollo empty data: \(operationName, privacy: .public)")
                continuation.resume(throwing: AniListServiceError.emptyData)
                return
            }

            logger.info("⬅️ Apollo response: \(operationName, privacy: .public)")
            continuation.resume(returning: data)
        }
    }

    private func mapApolloError(_ error: any Error, operationName: String) -> any Error {
        if let responseError = error as? ResponseCodeInterceptor.ResponseCodeError {
            switch responseError {
            case .invalidResponseCode(let response, _):
                if response?.statusCode == 401 {
                    logger.error("❌ Apollo unauthorized response: \(operationName, privacy: .public)")
                    return AniListServiceError.unauthorized
                }
            }
        }

        if Self.isUnauthorized(message: error.localizedDescription) {
            return AniListServiceError.unauthorized
        }

        return error
    }

    private static func isUnauthorized(message: String) -> Bool {
        message.localizedCaseInsensitiveContains("unauthorized")
            || message.localizedCaseInsensitiveContains("authentication")
            || message.localizedCaseInsensitiveContains("401")
    }
}
