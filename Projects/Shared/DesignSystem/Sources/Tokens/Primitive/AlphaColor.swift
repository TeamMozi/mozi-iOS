import Foundation

/// Figma `Sementic Numbers` 컬렉션의 `overlay/*` 알파 색 20개. 모듈 밖에 열지 않는다.
/// 알파는 Figma 의 두 자리 16진 값을 255 로 나눈 값이다.
enum AlphaColor {
    static let overlay = AlphaOverlayColors()
}

struct AlphaOverlayColors: Sendable {
    let dark = AlphaOverlayDarkColors()
    let light = AlphaOverlayLightColors()
    let gray = AlphaOverlayGrayColors()
}

struct AlphaOverlayDarkColors: Sendable {
    let _0 = TokenColor(hexRGB: 0x000000, alpha: 0x00 / 255.0)
    let _10 = TokenColor(hexRGB: 0x000000, alpha: 0x1A / 255.0)
    let _20 = TokenColor(hexRGB: 0x000000, alpha: 0x33 / 255.0)
    let _40 = TokenColor(hexRGB: 0x000000, alpha: 0x66 / 255.0)
    let _60 = TokenColor(hexRGB: 0x000000, alpha: 0x99 / 255.0)
    let _70 = TokenColor(hexRGB: 0x000000, alpha: 0xB2 / 255.0)
    let _90 = TokenColor(hexRGB: 0x000000, alpha: 0xE5 / 255.0)
}

struct AlphaOverlayLightColors: Sendable {
    let _0 = TokenColor(hexRGB: 0xFAFAFA, alpha: 0x00 / 255.0)
    let _10 = TokenColor(hexRGB: 0xFAFAFA, alpha: 0x1A / 255.0)
    let _20 = TokenColor(hexRGB: 0xFAFAFA, alpha: 0x33 / 255.0)
    let _40 = TokenColor(hexRGB: 0xFAFAFA, alpha: 0x66 / 255.0)
    let _60 = TokenColor(hexRGB: 0xFAFAFA, alpha: 0x99 / 255.0)
    let _80 = TokenColor(hexRGB: 0xFAFAFA, alpha: 0xCC / 255.0)
    let _90 = TokenColor(hexRGB: 0xFAFAFA, alpha: 0xE5 / 255.0)
    let _100 = TokenColor(hexRGB: 0xFAFAFA, alpha: 0xFF / 255.0)
}

struct AlphaOverlayGrayColors: Sendable {
    let _10 = TokenColor(hexRGB: 0xAFAFAF, alpha: 0x1A / 255.0)
    let _20 = TokenColor(hexRGB: 0xAFAFAF, alpha: 0x33 / 255.0)
    let _40 = TokenColor(hexRGB: 0x706D82, alpha: 0x66 / 255.0)
    let _70 = TokenColor(hexRGB: 0xAFAFAF, alpha: 0xB2 / 255.0)
    let _80 = TokenColor(hexRGB: 0x423F55, alpha: 0xCC / 255.0)
}
