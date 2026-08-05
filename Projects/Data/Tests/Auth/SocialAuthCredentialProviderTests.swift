@testable import Data
import CoreSocialAuth
import Domain
import XCTest

final class SocialAuthCredentialProviderTests: XCTestCase {
    func test_카카오_provider면_kakao_service를_호출() async throws {
        let kakao = StubSocialAuthService(token: "kakao-token")
        let apple = StubSocialAuthService(token: "apple-token")
        let services = SocialAuthServices(kakao: kakao, apple: apple)

        let token = try await SocialAuthCredentialProvider.credential(
            for: .kakao,
            services: services
        )

        XCTAssertEqual(token, "kakao-token")
        let kakaoCalls = await kakao.callCount
        let appleCalls = await apple.callCount
        XCTAssertEqual(kakaoCalls, 1)
        XCTAssertEqual(appleCalls, 0)
    }

    func test_애플_provider면_apple_service를_호출() async throws {
        let kakao = StubSocialAuthService(token: "kakao-token")
        let apple = StubSocialAuthService(token: "apple-token")
        let services = SocialAuthServices(kakao: kakao, apple: apple)

        let token = try await SocialAuthCredentialProvider.credential(
            for: .apple,
            services: services
        )

        XCTAssertEqual(token, "apple-token")
    }

    func test_cancelled는_AuthError_cancelled로_매핑() async {
        let services = SocialAuthServices(
            kakao: StubSocialAuthService(error: SocialAuthError.cancelled),
            apple: StubSocialAuthService(token: "unused")
        )

        do {
            _ = try await SocialAuthCredentialProvider.credential(
                for: .kakao,
                services: services
            )
            XCTFail("expected cancelled")
        } catch let error as AuthError {
            XCTAssertEqual(error, .cancelled)
        } catch {
            XCTFail("unexpected \(error)")
        }
    }

    func test_notConfigured는_AuthError_notConfigured로_매핑() async {
        let services = SocialAuthServices(
            kakao: StubSocialAuthService(
                error: .notConfigured(message: "Kakao login is not configured yet")
            ),
            apple: StubSocialAuthService(token: "unused")
        )

        do {
            _ = try await SocialAuthCredentialProvider.credential(
                for: .kakao,
                services: services
            )
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

    func test_failed는_AuthError_loginFailed로_매핑() async {
        let services = SocialAuthServices(
            kakao: StubSocialAuthService(error: .failed),
            apple: StubSocialAuthService(token: "unused")
        )

        do {
            _ = try await SocialAuthCredentialProvider.credential(
                for: .kakao,
                services: services
            )
            XCTFail("expected loginFailed")
        } catch let error as AuthError {
            XCTAssertEqual(error, .loginFailed)
        } catch {
            XCTFail("unexpected \(error)")
        }
    }
}

private actor StubSocialAuthService: SocialAuthService {
    private let token: String?
    private let error: SocialAuthError?
    private(set) var callCount = 0

    init(token: String) {
        self.token = token
        self.error = nil
    }

    init(error: SocialAuthError) {
        self.token = nil
        self.error = error
    }

    func login() async throws -> String {
        callCount += 1
        if let error {
            throw error
        }
        return token ?? ""
    }
}
