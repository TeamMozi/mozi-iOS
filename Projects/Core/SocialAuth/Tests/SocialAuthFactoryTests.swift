@testable import CoreSocialAuth
import XCTest

final class SocialAuthFactoryTests: XCTestCase {
    @MainActor
    func test_카카오키없으면_카카오는_notConfigured() async {
        let services = SocialAuthFactory.make(
            config: SocialAuthConfiguration(kakaoAppKey: nil)
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
        let services = SocialAuthFactory.make(
            config: SocialAuthConfiguration(kakaoAppKey: "")
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

    // Bootstrap(SDK 초기화) 없이 factory 만 불러도 서비스가 만들어져야 한다. App 은 factory 를 먼저 부른다.
    @MainActor
    func test_카카오키가_있으면_SDK_초기화_없이_카카오와_애플_서비스를_만든다() {
        let services = SocialAuthFactory.make(
            config: SocialAuthConfiguration(kakaoAppKey: "test-kakao-key")
        )

        XCTAssertTrue(services.kakao is KakaoSocialAuthService)
        XCTAssertTrue(services.apple is AppleSocialAuthService)
    }
}
