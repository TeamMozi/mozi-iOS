import Domain
import Foundation

/// 시리즈 RepositoryImpl 의 catch 가 부른다. 엔드포인트 예외가 생기면 동작별 함수를 더해 먼저 거른다.
enum SeriesErrorMapper {
    static func map(_ error: any Error) -> SeriesError {
        // do 블록 안에서 이미 바꾼 Domain 오류는 덮어쓰지 않는다.
        if let error = error as? SeriesError {
            return error
        }
        switch RemoteFailure(error) {
        case .network:
            return .network
        case .unauthorized:
            return .unauthorized
        case .forbidden:
            return .forbidden
        case .notFound:
            return .notFound
        case let .conflict(message):
            return .conflict(message: message)
        case let .invalid(message):
            return .validation(message: message)
        case let .unknown(message):
            return .unknown(message: message)
        }
    }
}
