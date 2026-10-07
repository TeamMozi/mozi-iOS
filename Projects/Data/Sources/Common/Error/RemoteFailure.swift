import CoreNetwork
import Foundation

/// 서버 통신 오류의 공통 분류. 기능 `<기능>ErrorMapper` 가 이것을 switch 해 Domain 오류로 바꾼다.
/// 서버 문구가 없으면 message 는 `""` 다. 기술 문구와 상태 코드는 넣지 않는다.
enum RemoteFailure: Equatable, Sendable {
    case network
    case unauthorized
    case forbidden(message: String)
    case notFound(message: String)
    case conflict(message: String)
    /// 400 과 그 밖의 4xx. 엔드포인트와 상관없이 Domain `validation` 으로 간다.
    case invalid(message: String)
    case unknown(message: String)

    init(_ error: any Error) {
        switch error {
        case let networkError as NetworkError:
            self = Self.classify(networkError)
        case let uploadError as UploadError:
            self = Self.classify(uploadError)
        default:
            // 호출 전에 던진 CancellationError 만 여기로 온다. 요청 중 취소는 transport 로 와서 .network 다.
            self = .unknown(message: "")
        }
    }

    private static func classify(_ error: NetworkError) -> RemoteFailure {
        switch error {
        case .transport:
            return .network
        case .unauthorized:
            return .unauthorized
        case let .forbidden(message):
            return .forbidden(message: message ?? "")
        case let .notFound(message):
            return .notFound(message: message ?? "")
        case let .conflict(message):
            return .conflict(message: message ?? "")
        case let .badRequest(message), let .clientError(_, message):
            return .invalid(message: message ?? "")
        case let .serverError(_, message):
            return .unknown(message: message ?? "")
        case .invalidURL, .invalidResponse, .decodingFailed:
            return .unknown(message: "")
        }
    }

    private static func classify(_ error: UploadError) -> RemoteFailure {
        switch error {
        case .transport:
            return .network
        case .rejected:
            // 주소 만료(401·403)를 로그인 풀림으로 읽지 않게 상태 코드를 보지 않는다.
            return .unknown(message: "")
        }
    }
}
