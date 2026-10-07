import CoreNetwork
@testable import Data
import Foundation
import XCTest

final class RemoteFailureTests: XCTestCase {
    // 분류 표 1줄: NetworkError.transport
    func test_전송_실패는_network() {
        XCTAssertEqual(RemoteFailure(NetworkError.transport(message: "끊김")), .network)
    }

    // 분류 표 2줄: NetworkError.unauthorized
    func test_401_은_unauthorized() {
        XCTAssertEqual(RemoteFailure(NetworkError.unauthorized), .unauthorized)
    }

    // 분류 표 3줄: NetworkError.forbidden(m)
    func test_403_은_서버_문구를_담은_forbidden() {
        XCTAssertEqual(
            RemoteFailure(NetworkError.forbidden(message: "권한이 없습니다")),
            .forbidden(message: "권한이 없습니다")
        )
    }

    func test_403_에_문구가_없으면_빈_문구_forbidden() {
        XCTAssertEqual(RemoteFailure(NetworkError.forbidden(message: nil)), .forbidden(message: ""))
    }

    // 분류 표 4줄: NetworkError.notFound(m)
    func test_404_는_서버_문구를_담은_notFound() {
        XCTAssertEqual(
            RemoteFailure(NetworkError.notFound(message: "모임이 없습니다")),
            .notFound(message: "모임이 없습니다")
        )
    }

    func test_404_에_문구가_없으면_빈_문구_notFound() {
        XCTAssertEqual(RemoteFailure(NetworkError.notFound(message: nil)), .notFound(message: ""))
    }

    // 분류 표 5줄: NetworkError.conflict(m)
    func test_409_는_서버_문구를_담은_conflict() {
        XCTAssertEqual(
            RemoteFailure(NetworkError.conflict(message: "정원이 찼습니다")),
            .conflict(message: "정원이 찼습니다")
        )
    }

    func test_409_에_문구가_없으면_빈_문구_conflict() {
        XCTAssertEqual(RemoteFailure(NetworkError.conflict(message: nil)), .conflict(message: ""))
    }

    // 분류 표 6줄: NetworkError.badRequest(m), .clientError(_, m)
    func test_400_은_서버_문구를_담은_invalid() {
        XCTAssertEqual(
            RemoteFailure(NetworkError.badRequest(message: "이미 시작된 모임입니다")),
            .invalid(message: "이미 시작된 모임입니다")
        )
    }

    func test_400_에_문구가_없으면_빈_문구_invalid() {
        XCTAssertEqual(RemoteFailure(NetworkError.badRequest(message: nil)), .invalid(message: ""))
    }

    func test_그_밖의_4xx_는_서버_문구를_담은_invalid() {
        XCTAssertEqual(
            RemoteFailure(NetworkError.clientError(statusCode: 422, message: "형식이 맞지 않습니다")),
            .invalid(message: "형식이 맞지 않습니다")
        )
    }

    func test_그_밖의_4xx_에_문구가_없으면_빈_문구_invalid() {
        XCTAssertEqual(
            RemoteFailure(NetworkError.clientError(statusCode: 429, message: nil)),
            .invalid(message: "")
        )
    }

    // 분류 표 7줄: NetworkError.serverError(_, m)
    func test_5xx_는_서버_문구를_담은_unknown() {
        XCTAssertEqual(
            RemoteFailure(NetworkError.serverError(statusCode: 502, message: "외부 연동에 실패했습니다")),
            .unknown(message: "외부 연동에 실패했습니다")
        )
    }

    func test_5xx_에_문구가_없으면_상태_코드를_넣지_않고_빈_문구_unknown() {
        XCTAssertEqual(
            RemoteFailure(NetworkError.serverError(statusCode: 500, message: nil)),
            .unknown(message: "")
        )
    }

    // 분류 표 8줄: NetworkError.invalidURL, .invalidResponse, .decodingFailed
    func test_주소_응답_해석_실패는_기술_문구_없이_빈_문구_unknown() {
        XCTAssertEqual(RemoteFailure(NetworkError.invalidURL), .unknown(message: ""))
        XCTAssertEqual(RemoteFailure(NetworkError.invalidResponse), .unknown(message: ""))
        XCTAssertEqual(RemoteFailure(NetworkError.decodingFailed), .unknown(message: ""))
    }

    // 분류 표 9줄: UploadError.transport
    func test_업로드_전송_실패는_network() {
        XCTAssertEqual(RemoteFailure(UploadError.transport), .network)
    }

    // 분류 표 10줄: UploadError.rejected(_). 주소 만료(401·403)를 로그인 풀림으로 읽지 않는다
    func test_업로드_거부는_상태_코드와_상관없이_빈_문구_unknown() {
        XCTAssertEqual(RemoteFailure(UploadError.rejected(statusCode: 401)), .unknown(message: ""))
        XCTAssertEqual(RemoteFailure(UploadError.rejected(statusCode: 403)), .unknown(message: ""))
        XCTAssertEqual(RemoteFailure(UploadError.rejected(statusCode: 500)), .unknown(message: ""))
    }

    // 분류 표 11줄: 그 밖의 Error
    func test_작업_취소는_빈_문구_unknown() {
        XCTAssertEqual(RemoteFailure(CancellationError()), .unknown(message: ""))
    }

    func test_모르는_오류는_빈_문구_unknown() {
        XCTAssertEqual(RemoteFailure(OtherError()), .unknown(message: ""))
    }
}

private struct OtherError: Error {}
