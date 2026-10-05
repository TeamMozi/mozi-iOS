@testable import SharedDesignSystem
import XCTest

final class DesignTextLimitTests: XCTestCase {
    private let single = DesignTextLimit(maxLength: 50, overflow: .truncate)
    private let multi = DesignTextLimit(maxLength: 50, overflow: .keep)

    func test_빈_칸에_한_글자를_넣으면_받는다() {
        XCTAssertEqual(append("가", to: "", limit: single), .accept)
    }

    func test_정확히_최대가_되는_입력은_받는다() {
        XCTAssertEqual(append("가", to: hangul(49), limit: single), .accept)
    }

    func test_최대에서_한_글자를_더하면_받지_않는다() {
        XCTAssertEqual(append("가", to: hangul(50), limit: single), .reject)
    }

    func test_이모지_묶음은_한_글자로_센다() {
        let family = "👨‍👩‍👧‍👦"
        XCTAssertEqual(family.count, 1)
        XCTAssertEqual(append(family, to: hangul(49), limit: single), .accept)
        XCTAssertEqual(single.counterText(for: hangul(49) + family), "50/50")
    }

    func test_최대에서_이모지_묶음을_더하면_받지_않는다() {
        XCTAssertEqual(append("👨‍👩‍👧‍👦", to: hangul(50), limit: single), .reject)
    }

    func test_조합_중이면_최대에서도_받는다() {
        let current = hangul(50)
        let decision = single.decide(current: current, range: end(of: current), replacement: "ㅎ", isComposing: true)
        XCTAssertEqual(decision, .accept)
    }

    func test_붙여넣은_긴_글은_남은_자리만큼_앞부분만_넣는다() {
        XCTAssertEqual(append("나다라마", to: hangul(48), limit: single), .replace(with: "나다"))
    }

    func test_자리가_없으면_붙여넣기를_받지_않는다() {
        XCTAssertEqual(append("나다", to: hangul(50), limit: single), .reject)
    }

    func test_55자_값에서_한_글자를_지우면_받는다() {
        let decision = multi.decide(
            current: hangul(55),
            range: NSRange(location: 54, length: 1),
            replacement: "",
            isComposing: false
        )
        XCTAssertEqual(decision, .accept)
    }

    func test_55자_값에서_한_글자를_더하면_받지_않는다() {
        XCTAssertEqual(append("가", to: hangul(55), limit: multi), .reject)
    }

    func test_55자_값의_일부를_짧은_글로_바꿔도_넘치면_받지_않는다() {
        let decision = multi.decide(
            current: hangul(55),
            range: NSRange(location: 50, length: 3),
            replacement: "나",
            isComposing: false
        )
        XCTAssertEqual(decision, .reject)
    }

    func test_조합이_끝나_넘친_글자는_새_글자의_뒤에서_자른다() {
        XCTAssertEqual(single.settle(hangul(49) + "나다", previous: hangul(49)), hangul(49) + "나")
    }

    func test_가운데서_조합이_끝나_넘치면_그_자리_글자를_자른다() {
        let limit = DesignTextLimit(maxLength: 4, overflow: .truncate)
        XCTAssertEqual(limit.settle("가XY나다", previous: "가나다"), "가X나다")
    }

    func test_지워서_줄어든_긴_값은_그대로_둔다() {
        XCTAssertEqual(multi.settle(hangul(54), previous: hangul(55)), hangul(54))
    }

    func test_최대_안의_값은_조합이_끝나도_그대로_둔다() {
        XCTAssertEqual(single.settle(hangul(50), previous: hangul(49)), hangul(50))
    }

    func test_한_줄_칸은_넘어온_긴_값을_최대까지_자른다() {
        XCTAssertEqual(single.incoming(hangul(55)), hangul(50))
    }

    func test_여러_줄_칸은_넘어온_긴_값을_그대로_둔다() {
        XCTAssertEqual(multi.incoming(hangul(55)), hangul(55))
    }

    func test_글자_수는_현재와_최대를_빗금으로_잇는다() {
        XCTAssertEqual(multi.counterText(for: ""), "0/50")
        XCTAssertEqual(multi.counterText(for: "심심해요"), "4/50")
        XCTAssertEqual(multi.counterText(for: hangul(55)), "55/50")
    }

    private func hangul(_ count: Int) -> String {
        String(repeating: "가", count: count)
    }

    private func end(of text: String) -> NSRange {
        NSRange(location: (text as NSString).length, length: 0)
    }

    private func append(_ text: String, to current: String, limit: DesignTextLimit) -> DesignTextEditDecision {
        limit.decide(current: current, range: end(of: current), replacement: text, isComposing: false)
    }
}
