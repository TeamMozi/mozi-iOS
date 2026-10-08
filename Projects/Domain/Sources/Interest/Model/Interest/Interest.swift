import Foundation

/// 카테고리. 모임의 분류이자 사용자의 관심사다. 식별자는 문자열이고 서버 정수와의 변환은 Data 가 맡는다.
/// `Category` 라는 이름은 Objective-C 런타임 타입과 부딪혀 쓰지 않는다.
public struct Interest: Equatable, Hashable, Sendable, Codable, Identifiable {
    public var id: String
    public var name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
