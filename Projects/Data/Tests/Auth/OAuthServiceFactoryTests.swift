@testable import Data
import Domain
import XCTest

final class OAuthServiceFactoryTests: XCTestCase {
    func test_stub_kakao는_notConfigured() async {
        let services = OAuthServiceFactory.makeStub()

        do {
            _ = try await services.service(for: .kakao).login()
            XCTFail("expected notConfigured")
        } catch let error as AuthError {
            XCTAssertEqual(
                error,
                .notConfigured(message: "Kakao login is not configured yet")
            )
        } catch {
            XCTFail("unexpected \(error)")
        }
    }

    func test_stub_apple은_notConfigured() async {
        let services = OAuthServiceFactory.makeStub()

        do {
            _ = try await services.service(for: .apple).login()
            XCTFail("expected notConfigured")
        } catch let error as AuthError {
            XCTAssertEqual(
                error,
                .notConfigured(message: "Apple login is not configured yet")
            )
        } catch {
            XCTFail("unexpected \(error)")
        }
    }
}
