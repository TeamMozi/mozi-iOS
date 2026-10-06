import CoreNetwork
@testable import Data
import Domain
import Foundation
import XCTest

final class SeriesErrorMapperTests: XCTestCase {
    func test_전송_실패는_network() {
        XCTAssertEqual(SeriesErrorMapper.map(NetworkError.transport(message: "끊김")), .network)
    }

    func test_401_은_unauthorized() {
        XCTAssertEqual(SeriesErrorMapper.map(NetworkError.unauthorized), .unauthorized)
    }

    func test_403_은_forbidden() {
        XCTAssertEqual(
            SeriesErrorMapper.map(NetworkError.forbidden(message: "권한이 없습니다")),
            .forbidden
        )
    }

    func test_404_는_notFound() {
        XCTAssertEqual(SeriesErrorMapper.map(NetworkError.notFound(message: nil)), .notFound)
    }

    func test_409_는_서버_문구를_담은_conflict() {
        XCTAssertEqual(
            SeriesErrorMapper.map(NetworkError.conflict(message: "다른 시리즈에 묶인 모임입니다")),
            .conflict(message: "다른 시리즈에 묶인 모임입니다")
        )
    }

    func test_400_은_서버_문구를_담은_validation() {
        XCTAssertEqual(
            SeriesErrorMapper.map(NetworkError.badRequest(message: "제목을 입력해 주세요")),
            .validation(message: "제목을 입력해 주세요")
        )
    }

    func test_5xx_는_서버_문구를_담은_unknown() {
        XCTAssertEqual(
            SeriesErrorMapper.map(NetworkError.serverError(statusCode: 502, message: "외부 연동에 실패했습니다")),
            .unknown(message: "외부 연동에 실패했습니다")
        )
    }

    func test_서버_문구가_없는_오류는_빈_문구_unknown() {
        XCTAssertEqual(SeriesErrorMapper.map(CancellationError()), .unknown(message: ""))
    }

    func test_이미_SeriesError_면_그대로_돌려준다() {
        XCTAssertEqual(
            SeriesErrorMapper.map(SeriesError.conflict(message: "이미 묶인 모임입니다")),
            .conflict(message: "이미 묶인 모임입니다")
        )
    }
}
