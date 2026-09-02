import Domain
import XCTest

final class UserClientTests: XCTestCase {
    func test_UserClient_testValue는_생성_가능() {
        // testValue 는 UserClient.swift 의 TestDependencyKey 확장이 선언한다.
        // @DependencyClient 는 미구현 클로저를 채운 init 을 제공한다.
        _ = UserClient.testValue
    }
}
