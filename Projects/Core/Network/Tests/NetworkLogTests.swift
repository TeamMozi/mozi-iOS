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
}
