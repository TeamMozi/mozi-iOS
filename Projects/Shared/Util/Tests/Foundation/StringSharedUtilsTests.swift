import SharedUtils
import XCTest

final class StringSharedUtilsTests: XCTestCase {
    func test_앞뒤_공백이면_제거된_문자열_반환() {
        XCTAssertEqual("  hi  ".trimmed, "hi")
    }

    func test_공백만_있으면_blank_판정() {
        XCTAssertTrue("   ".isBlank)
        XCTAssertFalse("a".isBlank)
    }

    func test_빈_문자열이면_nil_반환() {
        XCTAssertNil("".nilIfEmpty)
        XCTAssertEqual("a".nilIfEmpty, "a")
    }

    func test_공백_문자열이면_nonEmpty가_nil() {
        XCTAssertNil("   ".nonEmpty)
        XCTAssertEqual("  a ".nonEmpty, "a")
    }

    func test_대소문자_무시_검색_헬퍼가_동작() {
        XCTAssertTrue("Hello".containsIgnoringCase("ell"))
        XCTAssertTrue("Hello".hasPrefixIgnoringCase("he"))
        XCTAssertFalse("Hello".hasPrefixIgnoringCase("lo"))
    }

    func test_공백과_개행을_제거한_문자열_반환() {
        XCTAssertEqual(" a\nb\t".removingWhitespacesAndNewlines, "ab")
    }
}
