import Foundation

public actor DefaultNetworkClient: NetworkClient {
    private let configuration: NetworkConfiguration
    private let session: URLSession
    private let tokenProvider: (any TokenProviding)?
    private let tokenRefresher: (any TokenRefreshing)?
    private var refreshTask: Task<Void, Error>?
    private var accessTokenGeneration = 0

    private init(
        configuration: NetworkConfiguration,
        session: URLSession,
        tokenProvider: (any TokenProviding)?,
        tokenRefresher: (any TokenRefreshing)?
    ) {
        self.configuration = configuration
        self.session = session
        self.tokenProvider = tokenProvider
        self.tokenRefresher = tokenRefresher
    }

    public static func plain(
        configuration: NetworkConfiguration,
        session: URLSession = .shared
    ) -> DefaultNetworkClient {
        DefaultNetworkClient(
            configuration: configuration,
            session: session,
            tokenProvider: nil,
            tokenRefresher: nil
        )
    }

    public static func authed(
        configuration: NetworkConfiguration,
        tokenProvider: any TokenProviding,
        tokenRefresher: any TokenRefreshing,
        session: URLSession = .shared
    ) -> DefaultNetworkClient {
        DefaultNetworkClient(
            configuration: configuration,
            session: session,
            tokenProvider: tokenProvider,
            tokenRefresher: tokenRefresher
        )
    }

    public func request<T: Decodable & Sendable>(_ endpoint: some APIEndpoint) async throws -> T {
        let data = try await perform(endpoint)
        do {
            return try configuration.jsonDecoder.decode(T.self, from: data)
        } catch {
            NetworkLog.error(error, url: nil)
            throw NetworkError.decodingFailed
        }
    }

    public func request(_ endpoint: some APIEndpoint) async throws {
        _ = try await perform(endpoint)
    }

    private func perform(_ endpoint: some APIEndpoint) async throws -> Data {
        let (_, data) = try await send(endpoint, allowRefresh: true)
        return data
    }

    private func send(
        _ endpoint: some APIEndpoint,
        allowRefresh: Bool
    ) async throws -> (HTTPURLResponse, Data) {
        let prepared = try await makeURLRequest(for: endpoint)
        NetworkLog.request(prepared.request)

        let started = Date()
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: prepared.request)
        } catch {
            NetworkLog.error(error, url: prepared.request.url)
            throw NetworkError.transport(message: error.localizedDescription)
        }

        let durationMs = Int(Date().timeIntervalSince(started) * 1000)
        guard let httpResponse = response as? HTTPURLResponse else {
            let error = NetworkError.invalidResponse
            NetworkLog.error(error, url: prepared.request.url)
            throw error
        }

        NetworkLog.response(
            statusCode: httpResponse.statusCode,
            url: prepared.request.url,
            data: data,
            durationMs: durationMs
        )

        if httpResponse.statusCode == 401 {
            guard tokenRefresher != nil, allowRefresh else {
                throw NetworkError.unauthorized
            }

            // 이미 다른 요청이 refresh를 끝낸 뒤라면 중복 refresh 없이 재시도한다.
            if let usedGeneration = prepared.accessTokenGeneration,
               usedGeneration < accessTokenGeneration {
                return try await send(endpoint, allowRefresh: false)
            }

            try await refreshSingleFlight()
            return try await send(endpoint, allowRefresh: false)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw mapStatusCode(httpResponse.statusCode, data: data)
        }

        return (httpResponse, data)
    }

    private func refreshSingleFlight() async throws {
        if let refreshTask {
            try await refreshTask.value
            return
        }

        let task = Task {
            guard let tokenRefresher else {
                throw NetworkError.unauthorized
            }
            do {
                try await tokenRefresher.refresh()
            } catch {
                throw NetworkError.unauthorized
            }
        }
        refreshTask = task

        do {
            try await task.value
            accessTokenGeneration += 1
            refreshTask = nil
        } catch {
            refreshTask = nil
            throw error
        }
    }

    private func makeURLRequest(for endpoint: some APIEndpoint) async throws -> PreparedRequest {
        guard var components = URLComponents(
            url: configuration.baseURL.appendingPathComponent(normalizedPath(endpoint.path)),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }

        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url, timeoutInterval: configuration.timeout)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if endpoint.body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        var usedGeneration: Int?
        if let tokenProvider {
            if let token = try await tokenProvider.accessToken() {
                guard url.scheme?.lowercased() == "https" else {
                    throw NetworkError.invalidURL
                }
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                usedGeneration = accessTokenGeneration
            }
        }

        return PreparedRequest(request: request, accessTokenGeneration: usedGeneration)
    }

    private func normalizedPath(_ path: String) -> String {
        if path.hasPrefix("/") {
            return String(path.dropFirst())
        }
        return path
    }

    private func mapStatusCode(_ statusCode: Int, data: Data) -> NetworkError {
        let message = try? configuration.jsonDecoder
            .decode(ErrorMessageDTO.self, from: data)
            .message
        switch statusCode {
        case 400:
            return .badRequest(message: message)
        case 401:
            return .unauthorized
        case 403:
            return .forbidden(message: message)
        case 404:
            return .notFound(message: message)
        case 409:
            return .conflict(message: message)
        case 400...499:
            return .clientError(statusCode: statusCode, message: message)
        case 500...599:
            return .serverError(statusCode: statusCode, message: message)
        default:
            return .serverError(statusCode: statusCode, message: message)
        }
    }
}

private struct PreparedRequest: Sendable {
    let request: URLRequest
    let accessTokenGeneration: Int?
}
