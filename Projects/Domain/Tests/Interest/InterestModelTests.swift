import Domain
import XCTest

final class InterestModelTests: XCTestCase {
    func test_카테고리_Identifiable_id는_식별자다() {
        XCTAssertEqual(Interest(id: "7", name: "푸드/드링크").id, "7")
    }

    func test_카테고리_오류는_세_종류이고_message가_다르면_다르다() {
        let all: [InterestError] = [.network, .unauthorized, .unknown(message: "")]
        XCTAssertEqual(all.map(kind), ["network", "unauthorized", "unknown"])
        XCTAssertNotEqual(InterestError.unknown(message: "a"), .unknown(message: "b"))
    }

    // 종류가 늘거나 줄면 컴파일이 깨진다
    private func kind(_ error: InterestError) -> String {
        switch error {
        case .network: "network"
        case .unauthorized: "unauthorized"
        case .unknown: "unknown"
        }
    }
}
