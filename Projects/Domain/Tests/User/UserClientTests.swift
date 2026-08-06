import Domain
import XCTest

final class UserClientTests: XCTestCase {
    func test_UserClient_testValue는_빈_클라이언트로_생성() {
        // @DependencyClient 는 testValue = UserClient() 를 기본 제공한다.
        // 미구현 endpoint 호출 시 issue를 내므로, 생성 가능성만 검증한다.
        _ = UserClient.testValue
        XCTAssertTrue(true)
    }
}
