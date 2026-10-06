import Domain
import Foundation

/// 모임 RepositoryImpl 의 catch 가 부른다. 엔드포인트 예외는 동작별 함수가 먼저 거르고 나머지는 `map` 에 넘긴다.
enum MeetingErrorMapper {
    static func map(_ error: any Error) -> MeetingError {
        // do 블록 안에서 이미 바꾼 Domain 오류는 덮어쓰지 않는다.
        if let error = error as? MeetingError {
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

    /// 참여 신청(`POST /api/meetings/{id}/members`). 403 은 연령·성별 조건 미달이다.
    static func join(_ error: any Error) -> MeetingError {
        if case .forbidden = RemoteFailure(error) {
            return .joinRestricted
        }
        return map(error)
    }
}
