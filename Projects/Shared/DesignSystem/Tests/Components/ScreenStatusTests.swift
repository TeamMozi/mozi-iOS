@testable import SharedDesignSystem
import XCTest

final class ScreenStatusTests: XCTestCase {
    func test_불러오는_중이면_로딩_표시를_켠다() {
        XCTAssertTrue(ScreenStatus.loading.isLoading)
    }

    func test_불러오는_중이_아니면_로딩_표시를_끈다() {
        XCTAssertFalse(ScreenStatus.idle.isLoading)
        XCTAssertFalse(ScreenStatus.actionFailed(message: "저장하지 못했어요").isLoading)
        XCTAssertFalse(ScreenStatus.loadFailed(message: "내용을 불러오지 못했어요").isLoading)
    }

    func test_동작_실패면_그_문구로_얼럿을_띄운다() {
        XCTAssertEqual(
            ScreenStatus.actionFailed(message: "저장하지 못했어요").actionFailureMessage,
            "저장하지 못했어요"
        )
    }

    func test_동작_실패가_아니면_얼럿을_띄우지_않는다() {
        XCTAssertNil(ScreenStatus.idle.actionFailureMessage)
        XCTAssertNil(ScreenStatus.loading.actionFailureMessage)
        XCTAssertNil(ScreenStatus.loadFailed(message: "내용을 불러오지 못했어요").actionFailureMessage)
    }

    func test_불러오기_실패면_그_문구로_본문을_덮는다() {
        XCTAssertEqual(
            ScreenStatus.loadFailed(message: "내용을 불러오지 못했어요").loadFailureMessage,
            "내용을 불러오지 못했어요"
        )
    }

    func test_불러오기_실패가_아니면_본문을_덮지_않는다() {
        XCTAssertNil(ScreenStatus.idle.loadFailureMessage)
        XCTAssertNil(ScreenStatus.loading.loadFailureMessage)
        XCTAssertNil(ScreenStatus.actionFailed(message: "저장하지 못했어요").loadFailureMessage)
    }

    func test_문구가_같아도_실패_종류가_다르면_다른_상태다() {
        XCTAssertNotEqual(
            ScreenStatus.actionFailed(message: "실패했어요"),
            ScreenStatus.loadFailed(message: "실패했어요")
        )
    }
}
