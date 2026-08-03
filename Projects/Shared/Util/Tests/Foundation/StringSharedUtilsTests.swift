import SharedUtils
import XCTest

final class StringSharedUtilsTests: XCTestCase {
    func test_trimmed() {
        XCTAssertEqual("  hi  ".trimmed, "hi")
    }

    func test_isBlank() {
        XCTAssertTrue("   ".isBlank)
        XCTAssertFalse("a".isBlank)
    }

    func test_nilIfEmpty() {
        XCTAssertNil("".nilIfEmpty)
        XCTAssertEqual("a".nilIfEmpty, "a")
    }

    func test_nonEmpty_trims() {
        XCTAssertNil("   ".nonEmpty)
        XCTAssertEqual("  a ".nonEmpty, "a")
    }

    func test_case_insensitive_helpers() {
        XCTAssertTrue("Hello".containsIgnoringCase("ell"))
        XCTAssertTrue("Hello".hasPrefixIgnoringCase("he"))
        XCTAssertFalse("Hello".hasPrefixIgnoringCase("lo"))
    }

    func test_removingWhitespacesAndNewlines() {
        XCTAssertEqual(" a\nb\t".removingWhitespacesAndNewlines, "ab")
    }
}
