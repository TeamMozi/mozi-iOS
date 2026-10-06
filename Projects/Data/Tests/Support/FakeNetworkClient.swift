import CoreNetwork
import Foundation

/// Data 테스트용 `NetworkClient`. 보낸 endpoint 를 기록하고, 미리 넣은 JSON 을 해석해 돌려주거나 미리 넣은 오류를 던진다.
/// 주소 조립과 상태 코드 → `NetworkError` 변환은 하지 않는다. 그 검증은 CoreNetwork 테스트가 맡는다.
actor FakeNetworkClient: NetworkClient {
    struct SentEndpoint: Equatable, Sendable {
        let path: String
        let method: HTTPMethod
        let headers: [String: String]
        let queryItems: [URLQueryItem]
        let body: Data?
    }

    enum Response: Sendable {
        /// 디코딩 요청은 이 바이트를 `NetworkJSONCoding.makeDecoder()` 로 해석하고, 실패하면 실제처럼 `NetworkError.decodingFailed` 를 던진다. 바디 없는 요청은 무시한다.
        case json(Data)
        case failure(any Error)
    }

    enum FakeError: Error, Equatable {
        case noResponse
    }

    private(set) var sentEndpoints: [SentEndpoint] = []
    private let response: Response?

    /// `response` 가 nil 이면 요청이 오는 순간 `FakeError.noResponse` 를 던진다. 요청이 없어야 하는 테스트에 쓴다.
    init(response: Response? = nil) {
        self.response = response
    }

    func request<T: Decodable & Sendable>(_ endpoint: some APIEndpoint) async throws -> T {
        let data = try record(endpoint)
        do {
            return try NetworkJSONCoding.makeDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    func request(_ endpoint: some APIEndpoint) async throws {
        _ = try record(endpoint)
    }

    private func record(_ endpoint: some APIEndpoint) throws -> Data {
        sentEndpoints.append(
            SentEndpoint(
                path: endpoint.path,
                method: endpoint.method,
                headers: endpoint.headers,
                queryItems: endpoint.queryItems,
                body: endpoint.body
            )
        )
        switch response {
        case let .json(data):
            return data
        case let .failure(error):
            throw error
        case nil:
            throw FakeError.noResponse
        }
    }
}
