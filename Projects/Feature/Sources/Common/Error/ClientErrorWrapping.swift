import Domain

extension MeetingError {
    /// Client 가 던진 오류를 모임 오류로 받는다. 다른 오류는 문구 없는 `unknown` 이다.
    static func wrapping(_ error: any Error) -> MeetingError {
        (error as? MeetingError) ?? .unknown(message: "")
    }
}

extension SnapPointError {
    /// Client 가 던진 오류를 스냅 포인트 오류로 받는다. 다른 오류는 문구 없는 `unknown` 이다.
    static func wrapping(_ error: any Error) -> SnapPointError {
        (error as? SnapPointError) ?? .unknown(message: "")
    }
}
