@testable import CoreSocialAuth
import XCTest

final class SocialAuthServiceFactoryTests: XCTestCase {
    @MainActor
    func test_카카오키없으면_카카오는_notConfigured() async {
        let services = SocialAuthServiceFactory().make(
            configuration: SocialAuthConfiguration(kakaoAppKey: nil)
        )

        do {
            _ = try await services.kakao.login()
            XCTFail("expected notConfigured")
        } catch let error as SocialAuthError {
            XCTAssertEqual(
                error,
                .notConfigured(message: "Kakao login is not configured yet")
            )
        } catch {
            XCTFail("unexpected \(error)")
        }
    }

    @MainActor
    func test_빈_카카오키면_카카오는_notConfigured() async {
        let services = SocialAuthServiceFactory().make(
            configuration: SocialAuthConfiguration(kakaoAppKey: "")
        )

        do {
            _ = try await services.kakao.login()
            XCTFail("expected notConfigured")
        } catch let error as SocialAuthError {
            XCTAssertEqual(
                error,
                .notConfigured(message: "Kakao login is not configured yet")
            )
        } catch {
            XCTFail("unexpected \(error)")
        }
    }
}
