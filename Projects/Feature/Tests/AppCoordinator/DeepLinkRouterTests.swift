import Feature
import XCTest

final class DeepLinkRouterTests: XCTestCase {
    func test_홈_커스텀스킴_파싱() {
        guard let url = URL(string: "mozi://home") else {
            return XCTFail("유효한 URL을 만들지 못했습니다.")
        }
        XCTAssertEqual(DeepLinkRouter.parse(url), .home)
    }

    func test_홈_경로_파싱() {
        guard let url = URL(string: "https://mozi.app/home") else {
            return XCTFail("유효한 URL을 만들지 못했습니다.")
        }
        XCTAssertEqual(DeepLinkRouter.parse(url), .home)
    }

    func test_알수없는_경로_무시() {
        guard let url = URL(string: "mozi://unknown") else {
            return XCTFail("유효한 URL을 만들지 못했습니다.")
        }
        XCTAssertNil(DeepLinkRouter.parse(url))
    }
}
