import Foundation

/// 페이지 하나를 달라는 요청. 정렬은 넣지 않고 서버 기본 정렬을 따른다.
/// 화면은 `.first` 와 받은 `Page.next` 만 보내고, 페이지 번호를 계산하지 않는다.
public struct PageRequest: Equatable, Sendable {
    public static let first = PageRequest(page: 0, size: 20)

    public var page: Int
    public var size: Int

    public init(page: Int, size: Int) {
        self.page = page
        self.size = size
    }
}
