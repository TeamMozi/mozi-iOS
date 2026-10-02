import SharedDesignSystem
import XCTest

final class TypographyTests: XCTestCase {
    func test_글자_스타일_21개_값이_Figma_표와_같다() {
        for item in textStyleCases {
            XCTAssertEqual(item.style.fontName, item.font, item.name)
            XCTAssertEqual(item.style.size, item.size, item.name)
            XCTAssertEqual(item.style.lineHeight, item.lineHeight, item.name)
            XCTAssertEqual(item.style.letterSpacingEm, item.em, accuracy: 0.0001, item.name)
        }
    }

    func test_자간과_줄_간격은_글자_크기와_줄_높이에서_나온다() {
        let title = TextStyle.ds.title1.bold
        XCTAssertEqual(title.letterSpacing, -0.56, accuracy: 0.0001)
        XCTAssertEqual(title.additionalLineSpacing, 0.586, accuracy: 0.01)

        let caption = TextStyle.ds.caption2.regular
        XCTAssertEqual(caption.letterSpacing, -0.12, accuracy: 0.0001)
        XCTAssertEqual(caption.additionalLineSpacing, 0)
    }

    /// Pretendard 기본 줄 높이는 글자 크기 × 1.193359375 다. 줄 높이와의 차이를 위아래로 반씩 나눈다.
    func test_한_줄_상자_여백은_줄_높이와_글꼴_기본_줄_높이_차이의_절반이다() {
        XCTAssertEqual(TextStyle.ds.body.regular.additionalLineSpacing, 4.906, accuracy: 0.01)
        XCTAssertEqual(TextStyle.ds.body.regular.lineBoxVerticalPadding, 2.453, accuracy: 0.01)
        XCTAssertEqual(TextStyle.ds.title1.bold.lineBoxVerticalPadding, 0.293, accuracy: 0.01)
        XCTAssertEqual(TextStyle.ds.caption2.regular.lineBoxVerticalPadding, 0)
    }
}

/// 코드 이름, 스타일, 기대값. 자간은 Figma 백분율을 100 으로 나눈 값이다.
private struct TextStyleCase {
    let name: String
    let style: TextStyle
    let font: String
    let size: CGFloat
    let lineHeight: CGFloat
    let em: CGFloat

    init(_ name: String, _ style: TextStyle, font: String, size: CGFloat, lineHeight: CGFloat, em: CGFloat) {
        self.name = name
        self.style = style
        self.font = font
        self.size = size
        self.lineHeight = lineHeight
        self.em = em
    }
}

private let textStyleCases: [TextStyleCase] = [
    TextStyleCase(
        "title1.bold", TextStyle.ds.title1.bold,
        font: "Pretendard-Bold", size: 28, lineHeight: 34, em: -0.02
    ),
    TextStyleCase(
        "title2.regular", TextStyle.ds.title2.regular,
        font: "Pretendard-Regular", size: 22, lineHeight: 28, em: -0.02
    ),
    TextStyleCase(
        "title2.semiBold", TextStyle.ds.title2.semiBold,
        font: "Pretendard-SemiBold", size: 22, lineHeight: 28, em: -0.02
    ),
    TextStyleCase(
        "title2.bold", TextStyle.ds.title2.bold,
        font: "Pretendard-Bold", size: 22, lineHeight: 28, em: -0.02
    ),
    TextStyleCase(
        "title3.regular", TextStyle.ds.title3.regular,
        font: "Pretendard-Regular", size: 18, lineHeight: 24, em: -0.02
    ),
    TextStyleCase(
        "title3.semiBold", TextStyle.ds.title3.semiBold,
        font: "Pretendard-SemiBold", size: 18, lineHeight: 24, em: -0.02
    ),
    TextStyleCase(
        "headline.regular", TextStyle.ds.headline.regular,
        font: "Pretendard-Regular", size: 16, lineHeight: 22, em: -0.02
    ),
    TextStyleCase(
        "headline.medium", TextStyle.ds.headline.medium,
        font: "Pretendard-Medium", size: 16, lineHeight: 22, em: -0.02
    ),
    TextStyleCase(
        "headline.semiBold", TextStyle.ds.headline.semiBold,
        font: "Pretendard-SemiBold", size: 16, lineHeight: 22, em: -0.02
    ),
    TextStyleCase(
        "body.regular", TextStyle.ds.body.regular,
        font: "Pretendard-Regular", size: 16, lineHeight: 24, em: -0.01
    ),
    TextStyleCase(
        "body.medium", TextStyle.ds.body.medium,
        font: "Pretendard-Medium", size: 16, lineHeight: 24, em: -0.01
    ),
    TextStyleCase(
        "body.semiBold", TextStyle.ds.body.semiBold,
        font: "Pretendard-SemiBold", size: 16, lineHeight: 24, em: -0.01
    ),
    TextStyleCase(
        "subtext.regular", TextStyle.ds.subtext.regular,
        font: "Pretendard-Regular", size: 14, lineHeight: 20, em: -0.01
    ),
    TextStyleCase(
        "subtext.medium", TextStyle.ds.subtext.medium,
        font: "Pretendard-Medium", size: 14, lineHeight: 20, em: -0.01
    ),
    TextStyleCase(
        "caption1.regular", TextStyle.ds.caption1.regular,
        font: "Pretendard-Regular", size: 14, lineHeight: 18, em: -0.01
    ),
    TextStyleCase(
        "caption1.medium", TextStyle.ds.caption1.medium,
        font: "Pretendard-Medium", size: 14, lineHeight: 18, em: -0.01
    ),
    TextStyleCase(
        "caption1.semiBold", TextStyle.ds.caption1.semiBold,
        font: "Pretendard-SemiBold", size: 14, lineHeight: 18, em: -0.01
    ),
    TextStyleCase(
        "caption1.bold", TextStyle.ds.caption1.bold,
        font: "Pretendard-Bold", size: 14, lineHeight: 18, em: -0.01
    ),
    TextStyleCase(
        "caption2.regular", TextStyle.ds.caption2.regular,
        font: "Pretendard-Regular", size: 12, lineHeight: 14, em: -0.01
    ),
    TextStyleCase(
        "caption2.medium", TextStyle.ds.caption2.medium,
        font: "Pretendard-Medium", size: 12, lineHeight: 14, em: -0.01
    ),
    TextStyleCase(
        "caption2.semiBold", TextStyle.ds.caption2.semiBold,
        font: "Pretendard-SemiBold", size: 12, lineHeight: 14, em: -0.01
    ),
]
