@testable import CoreNetwork
import XCTest

final class NetworkLogTests: XCTestCase {
    func test_로그용_URL에서_query와_fragment_제거() throws {
        let url = try XCTUnwrap(
            URL(string: "https://api.example.invalid/auth/callback?accessToken=secret&page=1#top")
        )
        let sanitized = NetworkLog.sanitizedURLString(url)
        XCTAssertEqual(sanitized, "https://api.example.invalid/auth/callback")
        XCTAssertFalse(sanitized.contains("accessToken=secret"))
        XCTAssertFalse(sanitized.contains("page=1"))
        XCTAssertFalse(sanitized.contains("#top"))
    }

    func test_formattedBody가_JSON을_여러줄로_정리하고_토큰_값만_가린다() {
        let body = #"{"accessToken":"abc","refreshToken":"def","isNewUser":false,"profileCompleted":false}"#

        let formatted = NetworkLog.formattedBody(body)

        XCTAssertTrue(formatted.contains("\n"))
        XCTAssertTrue(formatted.contains(#""accessToken" : "[REDACTED]""#))
        XCTAssertTrue(formatted.contains(#""refreshToken" : "[REDACTED]""#))
        XCTAssertTrue(formatted.contains(#""isNewUser" : false"#))
        XCTAssertTrue(formatted.contains(#""profileCompleted" : false"#))
        XCTAssertFalse(formatted.contains("abc"))
        XCTAssertFalse(formatted.contains("def"))
    }

    func test_redact가_identityToken과_Bearer_값을_가린다() {
        let text = """
        Authorization: Bearer secret-token
        {
          "identityToken" : "jwt.header.payload"
        }
        """

        let redacted = NetworkLog.redact(text)

        XCTAssertTrue(redacted.contains("Bearer [REDACTED]"))
        XCTAssertTrue(redacted.contains(#""identityToken" : "[REDACTED]""#))
        XCTAssertFalse(redacted.contains("secret-token"))
        XCTAssertFalse(redacted.contains("jwt.header.payload"))
    }

    func test_업로드_요청_로그는_주소_쿼리를_남기지_않는다() throws {
        let signed = try XCTUnwrap(
            URL(string: "https://storage.example.invalid/object/upload/sign/profile/1.jpg?token=signed-secret")
        )
        let unsigned = try XCTUnwrap(
            URL(string: "https://storage.example.invalid/object/upload/sign/profile/1.jpg")
        )

        let message = NetworkLog.uploadRequestMessage(url: signed)

        XCTAssertEqual(message, "↑ PUT https://storage.example.invalid/object/upload/sign/profile/1.jpg")
        XCTAssertFalse(message.contains("signed-secret"))
        XCTAssertEqual(NetworkLog.uploadRequestMessage(url: unsigned), message)
    }

    func test_업로드_응답_로그는_상태코드와_시간만_남긴다() throws {
        let signed = try XCTUnwrap(
            URL(string: "https://storage.example.invalid/object/upload/sign/profile/1.jpg?token=signed-secret")
        )

        let message = NetworkLog.uploadResponseMessage(statusCode: 403, url: signed, durationMs: 12)

        XCTAssertEqual(message, "← 403 https://storage.example.invalid/object/upload/sign/profile/1.jpg (12ms)")
        XCTAssertFalse(message.contains("signed-secret"))
    }

    func test_업로드_응답이_HTTP가_아니면_로그는_원인과_쿼리_없는_주소만_남긴다() throws {
        let signed = try XCTUnwrap(
            URL(string: "https://storage.example.invalid/object/upload/sign/profile/1.jpg?token=signed-secret")
        )

        let message = NetworkLog.uploadNonHTTPResponseMessage(url: signed)

        XCTAssertEqual(message, "✕ PUT https://storage.example.invalid/object/upload/sign/profile/1.jpg 응답이 HTTP 가 아님")
        XCTAssertFalse(message.contains("signed-secret"))
    }
}
