import Domain
import Foundation
import XCTest

final class SnapPointModelTests: XCTestCase {
    func test_보낸_시각이_있으면_보낸_스냅포인트() {
        var snapPoint = SnapPoint(
            id: "s1",
            name: "모임 전",
            notificationMessage: "오고 계신가요?",
            order: 1,
            sentAt: nil,
            participantCount: nil
        )
        XCTAssertFalse(snapPoint.isSent)
        snapPoint.sentAt = Date(timeIntervalSince1970: 0)
        XCTAssertTrue(snapPoint.isSent)
    }

    func test_스냅포인트_상한은_10개와_알림메시지_50자() {
        XCTAssertEqual(SnapPointLimit.maxCount, 10)
        XCTAssertEqual(SnapPointLimit.notificationMessageMaxLength, 50)
    }

    func test_추천_스냅포인트는_시안_순서의_여섯이다() {
        XCTAssertEqual(
            SnapPointRecommendation.all.map(\.name),
            ["모임 전", "왓츠인마이백", "응원봉 점등식", "상영 시작 5초 전", "내 기준 명장면", "코노 셋리스트"]
        )
        XCTAssertEqual(SnapPointRecommendation.all.first?.notificationMessage, "오고 계신가요? 인증샷을 찍어보세요 👀")
    }

    func test_추천_스냅포인트_알림메시지는_50자를_넘지_않는다() {
        for draft in SnapPointRecommendation.all {
            XCTAssertLessThanOrEqual(
                draft.notificationMessage.count,
                SnapPointLimit.notificationMessageMaxLength,
                draft.name
            )
        }
    }

    func test_스냅포인트_오류는_종류가_같으면_같다() {
        XCTAssertEqual(SnapPointError.validation(message: ""), .validation(message: ""))
        XCTAssertNotEqual(SnapPointError.limitExceeded, .meetingEnded)
    }
}
