import CoreNetwork
@testable import Data
import Domain
import Foundation
import XCTest

final class MeetingErrorMapperTests: XCTestCase {
    func test_전송_실패는_network() {
        XCTAssertEqual(MeetingErrorMapper.map(NetworkError.transport(message: "끊김")), .network)
    }

    func test_401_은_unauthorized() {
        XCTAssertEqual(MeetingErrorMapper.map(NetworkError.unauthorized), .unauthorized)
    }

    func test_403_은_forbidden() {
        XCTAssertEqual(
            MeetingErrorMapper.map(NetworkError.forbidden(message: "권한이 없습니다")),
            .forbidden
        )
    }

    func test_404_는_notFound() {
        XCTAssertEqual(MeetingErrorMapper.map(NetworkError.notFound(message: nil)), .notFound)
    }

    func test_409_는_서버_문구를_담은_conflict() {
        XCTAssertEqual(
            MeetingErrorMapper.map(NetworkError.conflict(message: "정원이 찼습니다")),
            .conflict(message: "정원이 찼습니다")
        )
    }

    func test_400_은_서버_문구를_담은_validation() {
        XCTAssertEqual(
            MeetingErrorMapper.map(NetworkError.badRequest(message: "이미 시작된 모임입니다")),
            .validation(message: "이미 시작된 모임입니다")
        )
    }

    func test_5xx_는_서버_문구를_담은_unknown() {
        XCTAssertEqual(
            MeetingErrorMapper.map(NetworkError.serverError(statusCode: 502, message: "외부 연동에 실패했습니다")),
            .unknown(message: "외부 연동에 실패했습니다")
        )
    }

    func test_서버_문구가_없는_오류는_빈_문구_unknown() {
        XCTAssertEqual(MeetingErrorMapper.map(CancellationError()), .unknown(message: ""))
    }

    func test_이미_MeetingError_면_그대로_돌려준다() {
        XCTAssertEqual(MeetingErrorMapper.map(MeetingError.joinRestricted), .joinRestricted)
        XCTAssertEqual(
            MeetingErrorMapper.join(MeetingError.validation(message: "제목이 비었습니다")),
            .validation(message: "제목이 비었습니다")
        )
    }

    func test_참여_신청의_403_은_joinRestricted() {
        XCTAssertEqual(
            MeetingErrorMapper.join(NetworkError.forbidden(message: "참여 조건이 맞지 않습니다")),
            .joinRestricted
        )
        XCTAssertEqual(MeetingErrorMapper.join(NetworkError.forbidden(message: nil)), .joinRestricted)
    }

    func test_참여_신청의_403_이_아닌_오류는_map_과_같다() {
        let errors: [any Error] = [
            NetworkError.transport(message: "끊김"),
            NetworkError.unauthorized,
            NetworkError.notFound(message: nil),
            NetworkError.conflict(message: "이미 참여 중입니다"),
            NetworkError.badRequest(message: "이미 시작된 모임입니다"),
            NetworkError.serverError(statusCode: 502, message: nil),
            UploadError.rejected(statusCode: 403),
            CancellationError(),
        ]

        for error in errors {
            XCTAssertEqual(MeetingErrorMapper.join(error), MeetingErrorMapper.map(error), "\(error)")
        }
    }
}
