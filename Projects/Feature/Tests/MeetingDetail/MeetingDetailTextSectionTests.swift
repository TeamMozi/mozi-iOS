@testable import Feature
import XCTest

final class MeetingDetailTextSectionTests: XCTestCase {
    func test_CRLF_줄바꿈도_줄_끝에_CR_을_남기지_않고_나눈다() {
        XCTAssertEqual(
            MeetingDetailTextSection.lines(of: "첫 줄\r\n\r\n셋째 줄\n넷째 줄"),
            ["첫 줄", "", "셋째 줄", "넷째 줄"]
        )
    }
}
