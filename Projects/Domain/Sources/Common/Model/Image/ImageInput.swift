import Foundation

/// 포스터·시리즈 커버 입력. 사진을 올리는 일은 Data 가 감춘다.
public enum ImageInput: Equatable, Sendable {
    /// 지금 사진을 그대로 둔다
    case keep
    /// 새 사진 데이터로 바꾼다
    case new(Data)
    /// 사진을 지운다
    case remove
}
