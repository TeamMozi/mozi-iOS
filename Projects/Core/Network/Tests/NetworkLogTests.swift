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
}
