import Foundation

/// Figma `color/*` 원시 색 34개. 모듈 밖에 열지 않는다. 의미 색과 부품만 쓴다.
enum PrimitiveColor {
    static let primary = PrimitivePrimaryColors()
    static let neutral = PrimitiveNeutralColors()
    static let system = PrimitiveSystemColors()
    static let swatch = PrimitiveSwatchColors()
}

struct PrimitivePrimaryColors: Sendable {
    let _0 = TokenColor(hexRGB: 0xFFFFB9)
    let _50 = TokenColor(hexRGB: 0xF5FE76)
    let _100 = TokenColor(hexRGB: 0xFFF489)
    let _200 = TokenColor(hexRGB: 0xFAE05E)
    let _300 = TokenColor(hexRGB: 0xF6D631)
    let _400 = TokenColor(hexRGB: 0xF7CB3B)
    let _500 = TokenColor(hexRGB: 0xF6BB09)
    let _600 = TokenColor(hexRGB: 0xF1A727)
    let _700 = TokenColor(hexRGB: 0xF29407)
    let _800 = TokenColor(hexRGB: 0xEA8306)
    let _900 = TokenColor(hexRGB: 0xDB7100)
}

struct PrimitiveNeutralColors: Sendable {
    let _0 = TokenColor(hexRGB: 0xFFFFFF)
    let _50 = TokenColor(hexRGB: 0xFCFCFC)
    let _100 = TokenColor(hexRGB: 0xF2F2F3)
    let _200 = TokenColor(hexRGB: 0xEAEAEB)
    let _300 = TokenColor(hexRGB: 0xDFDFE2)
    let _400 = TokenColor(hexRGB: 0xD5D5DF)
    let _500 = TokenColor(hexRGB: 0xCACACE)
    let _600 = TokenColor(hexRGB: 0xB0AFB5)
    let _700 = TokenColor(hexRGB: 0x7A7887)
    let _800 = TokenColor(hexRGB: 0x484753)
    let _900 = TokenColor(hexRGB: 0x34333E)
    let _1000 = TokenColor(hexRGB: 0x202027)
    let _1100 = TokenColor(hexRGB: 0x18181C)
    let _1200 = TokenColor(hexRGB: 0x0E0E11)
    let _1300 = TokenColor(hexRGB: 0x000000)
}

struct PrimitiveSystemColors: Sendable {
    let blue = TokenColor(hexRGB: 0x0088FF)
    let red = TokenColor(hexRGB: 0xFF5F57)
    let yellow = TokenColor(hexRGB: 0xFEBC2F)
    let green = TokenColor(hexRGB: 0x6CE582)
}

struct PrimitiveSwatchColors: Sendable {
    let mint = TokenColor(hexRGB: 0xC3FACE)
    let cyan = TokenColor(hexRGB: 0xD2F8FE)
    let lavender = TokenColor(hexRGB: 0xE3DBFF)
    let pink = TokenColor(hexRGB: 0xFDE1FF)
}
