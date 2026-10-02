import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

/// `DesignText` 가 실제로 차지하는 높이가 Figma 줄 높이 × 줄 수와 같은지 본다.
final class DesignTextLayoutTests: XCTestCase {
    @MainActor
    func test_body_한_줄_높이가_줄_높이와_같다() {
        let style = TextStyle.ds.body.regular
        let size = fittingSize(DesignText("모지 Mozi 123", style: style, lineLimit: 1), width: 320)
        XCTAssertEqual(size.height, style.lineHeight, accuracy: 0.5)
    }

    @MainActor
    func test_title1_한_줄_높이가_줄_높이와_같다() {
        let style = TextStyle.ds.title1.bold
        let size = fittingSize(DesignText("모지 Mozi 123", style: style, lineLimit: 1), width: 320)
        XCTAssertEqual(size.height, style.lineHeight, accuracy: 0.5)
    }

    /// 줄 높이가 Pretendard 기본 줄 높이(글자 크기 × 2444/2048)보다 작은 스타일은 글꼴 높이가 이긴다.
    @MainActor
    func test_모든_글자_스타일_한_줄_높이가_줄_높이와_같다() {
        XCTAssertEqual(allTextStyles.count, 21)
        for (name, style) in allTextStyles {
            let size = fittingSize(DesignText("모지 Mozi 123", style: style, lineLimit: 1), width: 320)
            let expected = max(style.lineHeight, style.size * 2444 / 2048)
            XCTAssertEqual(
                size.height,
                expected,
                accuracy: 0.5,
                "\(name) (크기 \(style.size), 줄 높이 \(style.lineHeight))"
            )
        }
    }

    /// 띄어쓰기 하나로 나뉜 두 낱말을, 한 줄 폭보다 1pt 좁고 낱말 하나보다 넓은 폭에 둔다.
    /// 낱말 안에서는 줄이 바뀌지 않으므로 정확히 두 줄이 된다. 줄 수 제한 2와 제한 없음의 높이가 같은지도 함께 본다.
    @MainActor
    func test_body_두_줄_높이가_줄_높이의_두_배다() {
        let style = TextStyle.ds.body.regular
        let word = "모지모지"
        let text = "\(word) \(word)"
        let oneLineWidth = fittingSize(DesignText(text, style: style, lineLimit: 1), width: 1000).width
        let wordWidth = fittingSize(DesignText(word, style: style, lineLimit: 1), width: 1000).width
        let width = oneLineWidth - 1
        XCTAssertGreaterThan(width, wordWidth, "낱말 하나가 들어갈 폭이어야 한다")

        let wrapped = fittingSize(DesignText(text, style: style), width: width)
        let limitedToTwo = fittingSize(DesignText(text, style: style, lineLimit: 2), width: width)
        let single = fittingSize(DesignText(text, style: style, lineLimit: 1), width: width)

        XCTAssertEqual(wrapped.height, limitedToTwo.height, accuracy: 0.01, "두 줄을 넘었다")
        XCTAssertGreaterThan(wrapped.height, single.height + 1, "한 줄로 남았다")
        XCTAssertEqual(wrapped.height, style.lineHeight * 2, accuracy: 0.5)
    }

    @MainActor
    private func fittingSize(_ view: some View, width: CGFloat) -> CGSize {
        // 기대값은 기본 글자 크기 .large 기준이다. 기기 글자 크기 설정에 흔들리지 않게 고정한다.
        let host = UIHostingController(rootView: view.dynamicTypeSize(.large))
        return host.sizeThatFits(in: CGSize(width: width, height: .greatestFiniteMagnitude))
    }
}

/// 글자 스타일 21개. 이름은 실패 메시지에 쓴다.
private let allTextStyles: [(name: String, style: TextStyle)] = [
    ("title1.bold", TextStyle.ds.title1.bold),
    ("title2.regular", TextStyle.ds.title2.regular),
    ("title2.semiBold", TextStyle.ds.title2.semiBold),
    ("title2.bold", TextStyle.ds.title2.bold),
    ("title3.regular", TextStyle.ds.title3.regular),
    ("title3.semiBold", TextStyle.ds.title3.semiBold),
    ("headline.regular", TextStyle.ds.headline.regular),
    ("headline.medium", TextStyle.ds.headline.medium),
    ("headline.semiBold", TextStyle.ds.headline.semiBold),
    ("body.regular", TextStyle.ds.body.regular),
    ("body.medium", TextStyle.ds.body.medium),
    ("body.semiBold", TextStyle.ds.body.semiBold),
    ("subtext.regular", TextStyle.ds.subtext.regular),
    ("subtext.medium", TextStyle.ds.subtext.medium),
    ("caption1.regular", TextStyle.ds.caption1.regular),
    ("caption1.medium", TextStyle.ds.caption1.medium),
    ("caption1.semiBold", TextStyle.ds.caption1.semiBold),
    ("caption1.bold", TextStyle.ds.caption1.bold),
    ("caption2.regular", TextStyle.ds.caption2.regular),
    ("caption2.medium", TextStyle.ds.caption2.medium),
    ("caption2.semiBold", TextStyle.ds.caption2.semiBold),
]
