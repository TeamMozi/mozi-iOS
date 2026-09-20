import CoreNetwork
import CoreStorage
@testable import Data
import Domain
import Foundation
import XCTest

final class AuthErrorMapperTests: XCTestCase {
    func test_로그인_경로가_전송_실패를_네트워크_오류로_바꾼다() {
        let mapped = AuthErrorMapper.login(NetworkError.transport(message: "끊김"))

        XCTAssertEqual(mapped, .network)
    }

    func test_로그인_경로가_401_을_로그인_실패로_바꾼다() {
        XCTAssertEqual(AuthErrorMapper.login(NetworkError.unauthorized), .loginFailed)
    }

    func test_로그인_경로가_400_을_로그인_실패로_바꾼다() {
        XCTAssertEqual(
            AuthErrorMapper.login(NetworkError.badRequest(message: nil)),
            .loginFailed
        )
    }

    func test_로그인_경로가_이미_바뀐_오류를_그대로_통과시킨다() {
        XCTAssertEqual(AuthErrorMapper.login(AuthError.cancelled), .cancelled)
    }

    func test_로그인_경로가_키체인_오류를_저장_오류로_바꾼다() {
        let mapped = AuthErrorMapper.login(KeychainError.saveFailed(status: -1))

        guard case .storage = mapped else {
            return XCTFail("저장 오류가 아니다: \(mapped)")
        }
    }

    func test_저장_경로가_이미_바뀐_오류를_그대로_통과시킨다() {
        XCTAssertEqual(AuthErrorMapper.storage(AuthError.unauthorized), .unauthorized)
    }

    func test_저장_경로가_그_밖의_오류를_저장_오류로_바꾼다() {
        let mapped = AuthErrorMapper.storage(KeychainError.saveFailed(status: -1))

        guard case .storage = mapped else {
            return XCTFail("저장 오류가 아니다: \(mapped)")
        }
    }
}
