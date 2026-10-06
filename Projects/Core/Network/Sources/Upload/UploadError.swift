/// 업로드 실패. `NetworkError` 와 따로 둬서 주소 만료(401·403 등)가 로그인 풀림으로 읽히지 않게 한다.
public enum UploadError: Error, Equatable, Sendable {
    /// 2xx 가 아닌 응답. 원래 상태 코드를 보존한다.
    case rejected(statusCode: Int)
    /// 망 오류·취소·HTTP 가 아닌 응답.
    case transport
}
