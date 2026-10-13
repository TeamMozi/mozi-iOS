import Domain
@testable import Feature
import XCTest

final class FeatureErrorMessageTests: XCTestCase {
    func test_다섯_타입_공통_종류는_같은_문구다() {
        XCTAssertEqual(FeatureErrorMessage.message(for: AuthError.network), "네트워크 연결을 확인해 주세요")
        XCTAssertEqual(FeatureErrorMessage.message(for: UserError.network), "네트워크 연결을 확인해 주세요")
        XCTAssertEqual(FeatureErrorMessage.message(for: InterestError.network), "네트워크 연결을 확인해 주세요")
        XCTAssertEqual(FeatureErrorMessage.message(for: MeetingError.network), "네트워크 연결을 확인해 주세요")
        XCTAssertEqual(FeatureErrorMessage.message(for: SnapPointError.network), "네트워크 연결을 확인해 주세요")
        XCTAssertEqual(FeatureErrorMessage.message(for: AuthError.unauthorized), "로그인이 필요해요. 다시 로그인해 주세요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: UserError.unauthorized), "로그인이 필요해요. 다시 로그인해 주세요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: InterestError.unauthorized), "로그인이 필요해요. 다시 로그인해 주세요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: MeetingError.unauthorized), "로그인이 필요해요. 다시 로그인해 주세요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: SnapPointError.unauthorized), "로그인이 필요해요. 다시 로그인해 주세요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: AuthError.unknown(message: "x")), "알 수 없는 오류가 발생했어요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: UserError.unknown(message: "x")), "알 수 없는 오류가 발생했어요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: InterestError.unknown(message: "x")), "알 수 없는 오류가 발생했어요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: MeetingError.unknown(message: "x")), "알 수 없는 오류가 발생했어요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: SnapPointError.unknown(message: "x")), "알 수 없는 오류가 발생했어요.")
    }

    func test_사용자_오류_종류마다_문구가_있다() {
        XCTAssertEqual(FeatureErrorMessage.message(for: UserError.validation(message: "서버")), "입력한 내용을 확인해 주세요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: UserError.notFound), "선택한 항목을 찾을 수 없어요. 다시 시도해 주세요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: UserError.forbidden), "요청을 처리하지 못했어요. 다시 시도해 주세요.")
        XCTAssertEqual(
            FeatureErrorMessage.message(for: UserError.conflict(message: "서버")),
            "요청을 처리하지 못했어요. 다시 시도해 주세요."
        )
    }

    func test_인증_오류_종류마다_문구가_있고_취소는_문구가_없다() {
        XCTAssertNil(FeatureErrorMessage.message(for: AuthError.cancelled))
        XCTAssertEqual(FeatureErrorMessage.message(for: AuthError.notConfigured(message: "x")), "로그인 설정이 완료되지 않았어요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: AuthError.loginFailed), "로그인에 실패했어요")
        XCTAssertEqual(
            FeatureErrorMessage.message(for: AuthError.storage(message: "keychain")),
            "정보를 기기에 저장하지 못했어요. 다시 시도해 주세요."
        )
    }

    func test_서버_message는_문구에_들어가지_않는다() {
        XCTAssertFalse(FeatureErrorMessage.message(for: UserError.validation(message: "닉네임 길이 초과")).contains("닉네임"))
        XCTAssertFalse(FeatureErrorMessage.message(for: InterestError.unknown(message: "boom")).contains("boom"))
        XCTAssertFalse(FeatureErrorMessage.message(for: MeetingError.conflict(message: "이미 신청했어요")).contains("신청"))
        XCTAssertFalse(FeatureErrorMessage.message(for: SnapPointError.validation(message: "서버 문구")).contains("서버"))
        XCTAssertEqual(
            FeatureErrorMessage.meetingFailure(for: .validation(message: "답을 확인해요"), action: "동작"),
            "동작"
        )
    }

    func test_로그아웃_실패_문구는_마이페이지_문구_그대로다() {
        XCTAssertEqual(
            FeatureErrorMessage.logoutFailure(for: .storage(message: "keychain")),
            "로그아웃 정보를 지우지 못했어요. 다시 시도해 주세요."
        )
        XCTAssertEqual(FeatureErrorMessage.logoutFailure(for: .network), "네트워크 연결을 확인해 주세요")
        let others: [AuthError] = [
            .cancelled, .notConfigured(message: ""), .loginFailed, .unauthorized, .unknown(message: ""),
        ]
        for error in others {
            XCTAssertEqual(FeatureErrorMessage.logoutFailure(for: error), "로그아웃에 실패했어요. 다시 시도해 주세요.")
        }
    }

    func test_모임_오류_종류마다_문구가_있다() {
        XCTAssertEqual(FeatureErrorMessage.message(for: MeetingError.joinRestricted), "참여 조건이 맞지 않아 신청할 수 없어요")
        let others: [MeetingError] = [.forbidden, .notFound, .conflict(message: "x"), .validation(message: "x")]
        for error in others {
            XCTAssertEqual(FeatureErrorMessage.message(for: error), "요청을 처리하지 못했어요. 다시 시도해 주세요.")
        }
    }

    func test_스냅포인트_오류_종류마다_문구가_있다() {
        XCTAssertEqual(
            FeatureErrorMessage.message(for: SnapPointError.limitExceeded),
            "스냅 포인트는 10개까지 등록할 수 있어요"
        )
        XCTAssertEqual(
            FeatureErrorMessage.message(for: SnapPointError.sentSnapPointNotDeletable),
            "알림을 보낸 스냅 포인트는 삭제할 수 없어요"
        )
        XCTAssertEqual(
            FeatureErrorMessage.message(for: SnapPointError.meetingEnded),
            "종료된 모임은 스냅 포인트를 바꿀 수 없어요"
        )
        let others: [SnapPointError] = [.forbidden, .notFound, .validation(message: "x")]
        for error in others {
            XCTAssertEqual(FeatureErrorMessage.message(for: error), "요청을 처리하지 못했어요. 다시 시도해 주세요.")
        }
    }

    func test_모임_동작_실패는_네트워크_로그인_참여_조건만_표_문구이고_나머지는_동작_문구다() {
        XCTAssertEqual(FeatureErrorMessage.meetingFailure(for: .network, action: "동작"), "네트워크 연결을 확인해 주세요")
        XCTAssertEqual(
            FeatureErrorMessage.meetingFailure(for: .unauthorized, action: "동작"),
            "로그인이 필요해요. 다시 로그인해 주세요."
        )
        XCTAssertEqual(
            FeatureErrorMessage.meetingFailure(for: .joinRestricted, action: "동작"),
            "참여 조건이 맞지 않아 신청할 수 없어요"
        )
        let others: [MeetingError] = [
            .forbidden, .notFound, .conflict(message: ""), .validation(message: ""), .unknown(message: "boom"),
        ]
        for error in others {
            XCTAssertEqual(FeatureErrorMessage.meetingFailure(for: error, action: "동작"), "동작")
        }
    }

    func test_스냅포인트_동작_실패는_네트워크_로그인_스냅포인트_규칙만_표_문구이고_나머지는_동작_문구다() {
        let tableErrors: [SnapPointError] = [
            .network, .unauthorized, .limitExceeded, .sentSnapPointNotDeletable, .meetingEnded,
        ]
        for error in tableErrors {
            XCTAssertEqual(
                FeatureErrorMessage.snapPointFailure(for: error, action: "동작"),
                FeatureErrorMessage.message(for: error)
            )
        }
        let others: [SnapPointError] = [.forbidden, .notFound, .validation(message: ""), .unknown(message: "boom")]
        for error in others {
            XCTAssertEqual(FeatureErrorMessage.snapPointFailure(for: error, action: "동작"), "동작")
        }
    }

    func test_모임_충돌은_충돌_문구가_있으면_그것을_띄운다() {
        XCTAssertEqual(
            FeatureErrorMessage.meetingFailure(
                for: .conflict(message: "정원 초과"),
                action: FeatureErrorMessage.MeetingAction.approveFailed,
                conflict: FeatureErrorMessage.MeetingAction.approveCapacityFull
            ),
            "정원이 다 차서 승인할 수 없어요"
        )
        XCTAssertEqual(
            FeatureErrorMessage.meetingFailure(
                for: .conflict(message: ""),
                action: FeatureErrorMessage.MeetingAction.approveFailed
            ),
            "승인하지 못했어요"
        )
    }

    func test_모임_상태_바꾸기_실패_문구는_고른_상태마다_다르다() {
        XCTAssertEqual(FeatureErrorMessage.MeetingAction.statusChangeFailed(.recruiting), "모집을 다시 열지 못했어요")
        XCTAssertEqual(FeatureErrorMessage.MeetingAction.statusChangeFailed(.closed), "모집을 마감하지 못했어요")
        XCTAssertEqual(FeatureErrorMessage.MeetingAction.statusChangeFailed(.ended), "모임을 종료하지 못했어요")
    }
}
