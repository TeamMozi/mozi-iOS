import CoreGraphics
import SwiftUI

public struct TextStyle: Sendable, Equatable {
    public let fontName: String
    public let size: CGFloat
    public let lineHeight: CGFloat
    public let letterSpacingEm: CGFloat

    public init(
        fontName: String,
        size: CGFloat,
        lineHeight: CGFloat,
        letterSpacingEm: CGFloat
    ) {
        self.fontName = fontName
        self.size = size
        self.lineHeight = lineHeight
        self.letterSpacingEm = letterSpacingEm
    }

    /// 처음 불릴 때 디자인 시스템 글꼴을 등록한다. 앱·미리보기·테스트는 글꼴을 따로 등록하지 않는다.
    public var font: Font {
        _ = Self.registerFontsOnce
        return Font.custom(fontName, size: size)
    }

    public var letterSpacing: CGFloat {
        size * letterSpacingEm
    }

    /// SwiftUI `.lineSpacing` 은 글꼴 기본 줄 높이 위에 더하므로, 줄 높이에서 기본 줄 높이를 뺀다.
    public var additionalLineSpacing: CGFloat {
        max(0, lineHeight - defaultLineHeight)
    }

    /// 한 줄 상자를 줄 높이에 맞추려고 글자 위아래에 더하는 여백.
    /// 줄 높이가 글꼴 기본 줄 높이 이상이면 n 줄 글자 높이가 n × 줄 높이가 된다. 작으면(caption2) 0 이고 글꼴 높이를 따른다.
    public var lineBoxVerticalPadding: CGFloat {
        max(0, (lineHeight - defaultLineHeight) / 2)
    }

    private var defaultLineHeight: CGFloat {
        size * Self.pretendardLineHeightRatio
    }

    // Pretendard `.otf` 실측: ascender 1950, descender -494, unitsPerEm 2048, lineGap 0. 네 굵기가 같다.
    private static let pretendardLineHeightRatio: CGFloat = (1950 + 494) / 2048

    // 글꼴 파일이 프레임워크 리소스라 Info.plist `UIAppFonts` 로는 등록되지 않는다.
    // 이 접근을 지우면 글꼴이 오류 없이 시스템 글꼴로 바뀐다.
    private static let registerFontsOnce: Void = {
        SharedDesignSystemFontFamily.registerAllCustomFonts()
    }()
}

public extension TextStyle {
    static let ds = DesignSystemTextStyles()
}

/// Figma 글자 스타일 21개. `Title2/SemiBold` → `TextStyle.ds.title2.semiBold`.
public struct DesignSystemTextStyles: Sendable {
    public let title1 = Title1TextStyles()
    public let title2 = Title2TextStyles()
    public let title3 = Title3TextStyles()
    public let headline = HeadlineTextStyles()
    public let body = BodyTextStyles()
    public let subtext = SubtextTextStyles()
    public let caption1 = Caption1TextStyles()
    public let caption2 = Caption2TextStyles()

    public init() {}
}
