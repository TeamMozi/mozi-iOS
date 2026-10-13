import Domain
import Foundation

/// 포스터 화면에서 고른 것. 모임 만들기 흐름이 들고 있다가 만들기 입력으로 바꾼다.
public struct PosterSelection: Equatable, Sendable {
    public var image: PosterImage
    public var music: BackgroundMusic?

    public init(image: PosterImage = .empty, music: BackgroundMusic? = nil) {
        self.image = image
        self.music = music
    }

    /// 만들기 입력의 포스터. 고르지 않았으면 포스터 없이 만든다(만들기에서 `.keep` 은 포스터 없음이다).
    public var imageInput: ImageInput {
        switch image {
        case .empty:
            .keep
        case let .previous(url):
            .reuse(url)
        case let .picked(_, data):
            .new(data)
        }
    }
}

public enum PosterImage: Equatable, Sendable {
    /// 고르지 않았다
    case empty
    /// 불러온 지난 모임의 포스터. 그대로 이어 쓴다
    case previous(URL)
    /// 고른 사진이나 「기본」 견본. `id` 는 사진이면 보관함 id, 견본이면 `swatch-<번호>` 다
    case picked(id: String, data: Data)
}
