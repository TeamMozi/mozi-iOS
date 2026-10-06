import Foundation

/// 페이지 번호 방식 목록의 한 페이지. `next` 가 nil 이면 마지막 페이지다.
public struct Page<Item> {
    public var items: [Item]
    public var next: PageRequest?

    public init(items: [Item], next: PageRequest?) {
        self.items = items
        self.next = next
    }
}

extension Page: Equatable where Item: Equatable {}
extension Page: Sendable where Item: Sendable {}
