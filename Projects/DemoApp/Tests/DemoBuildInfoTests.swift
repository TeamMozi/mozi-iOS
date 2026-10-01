@testable import MoziDemo
import XCTest

final class DemoBuildInfoTests: XCTestCase {
    /// fastlane/test/build_note_test.rb 와 같은 짝이다. 한쪽을 바꾸면 다른 쪽도 바꾼다.
    private let fixtureNote = "로그인 \"오류\" 문구, 'Apple' 버튼 $HOME (6c004cd)"
    private let fixtureBase64 = "66Gc6re47J24ICLsmKTrpZgiIOusuOq1rCwgJ0FwcGxlJyDrsoTtirwgJEhPTUUgKDZjMDA0Y2Qp"

    func test_문구와_해시가_비었으면_개발_빌드() {
        let info = DemoBuildInfo(infoDictionary: [
            "CFBundleVersion": "1",
            "MoziBuildNote": "",
            "MoziBuildHash": "",
        ])

        XCTAssertNil(info.upload)
        XCTAssertEqual(info.changeSummary, "개발 빌드")
        XCTAssertNil(info.footer)
    }

    func test_키가_없으면_개발_빌드() {
        let info = DemoBuildInfo(infoDictionary: [:])

        XCTAssertNil(info.upload)
        XCTAssertEqual(info.changeSummary, "개발 빌드")
        XCTAssertNil(info.footer)
    }

    func test_업로드_문구는_Base64를_풀어_따옴표_공백_한글을_그대로_보인다() {
        let info = DemoBuildInfo(infoDictionary: [
            "CFBundleVersion": "20261001.2",
            "MoziBuildNote": fixtureBase64,
            "MoziBuildHash": "6c004cd",
        ])

        XCTAssertEqual(info.upload, DemoBuildInfo.Upload(note: fixtureNote, commitHash: "6c004cd"))
        XCTAssertEqual(info.changeSummary, fixtureNote)
        XCTAssertEqual(info.footer, "빌드 20261001.2 · 6c004cd")
    }

    func test_문구를_풀지_못하면_개발_빌드() {
        let info = DemoBuildInfo(infoDictionary: [
            "CFBundleVersion": "20261001.2",
            "MoziBuildNote": "로그인 화면",
            "MoziBuildHash": "6c004cd",
        ])

        XCTAssertNil(info.upload)
        XCTAssertEqual(info.changeSummary, "개발 빌드")
    }

    func test_해시가_비면_개발_빌드() {
        let info = DemoBuildInfo(infoDictionary: [
            "CFBundleVersion": "20261001.2",
            "MoziBuildNote": fixtureBase64,
            "MoziBuildHash": " ",
        ])

        XCTAssertNil(info.upload)
        XCTAssertNil(info.footer)
    }
}
