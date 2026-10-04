/// 로그인 화면 데모 상태 셋.
public enum LoginDemoState: String, CaseIterable, Hashable, Sendable {
    case idle
    case loading
    case networkError

    /// LoginFeature 가 `AuthError.network` 에 쓰는 문구와 같다. DemoLoginFeatureTests 가 둘이 같은지 본다.
    static let networkErrorMessage = "네트워크 연결을 확인해 주세요"

    /// 상태 시트의 줄 이름.
    public var title: String {
        switch self {
        case .idle: "기본"
        case .loading: "불러오는 중"
        case .networkError: "오류 안내"
        }
    }

    /// 데모 버튼에 적는 짧은 이름.
    public var shortTitle: String {
        switch self {
        case .idle: "기본"
        case .loading: "로딩"
        case .networkError: "오류"
        }
    }
}
