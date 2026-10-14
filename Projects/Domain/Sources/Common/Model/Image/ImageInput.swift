import Foundation

/// 포스터·시리즈 커버 입력. 사진을 올리는 일은 Data 가 감춘다.
public enum ImageInput: Equatable, Sendable {
    /// 지금 사진을 그대로 둔다
    case keep
    /// 새 사진 데이터로 바꾼다
    case new(Data)
    /// 사진을 지운다
    case remove
    /// 지난 모임·시리즈의 사진을 이어 쓴다. 서버에 아직 없다.
    /// 앱이 아는 것은 지난 사진 주소뿐이라 주소를 넘기고, 서버에 보내는 방법은 Data 가 정한다.
    case reuse(URL)
}
