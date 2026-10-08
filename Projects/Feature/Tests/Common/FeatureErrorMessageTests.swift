import Domain
import Feature
import XCTest

final class FeatureErrorMessageTests: XCTestCase {
    func test_세_타입_공통_종류는_같은_문구다() {
        XCTAssertEqual(FeatureErrorMessage.message(for: AuthError.network), "네트워크 연결을 확인해 주세요")
        XCTAssertEqual(FeatureErrorMessage.message(for: UserError.network), "네트워크 연결을 확인해 주세요")
        XCTAssertEqual(FeatureErrorMessage.message(for: InterestError.network), "네트워크 연결을 확인해 주세요")
        XCTAssertEqual(FeatureErrorMessage.message(for: AuthError.unauthorized), "로그인이 필요해요. 다시 로그인해 주세요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: UserError.unauthorized), "로그인이 필요해요. 다시 로그인해 주세요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: InterestError.unauthorized), "로그인이 필요해요. 다시 로그인해 주세요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: AuthError.unknown(message: "x")), "알 수 없는 오류가 발생했어요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: UserError.unknown(message: "x")), "알 수 없는 오류가 발생했어요.")
        XCTAssertEqual(FeatureErrorMessage.message(for: InterestError.unknown(message: "x")), "알 수 없는 오류가 발생했어요.")
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
}
