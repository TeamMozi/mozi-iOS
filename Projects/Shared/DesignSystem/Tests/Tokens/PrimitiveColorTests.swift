@testable import SharedDesignSystem
import XCTest

final class PrimitiveColorTests: XCTestCase {
    func test_원시_색_34개_값이_Figma_표와_같다() {
        for item in primitiveCases {
            XCTAssertEqual(rgba(item.token), item.rgba, item.name)
        }
    }

    func test_알파_색_20개_값이_Figma_표와_같다() {
        for item in alphaCases {
            XCTAssertEqual(rgba(item.token), item.rgba, item.name)
        }
    }
}

/// Figma 이름, 코드 토큰, 기대값 `0xRRGGBBAA`.
private struct ColorCase {
    let name: String
    let token: TokenColor
    let rgba: UInt32

    init(_ name: String, _ token: TokenColor, _ rgba: UInt32) {
        self.name = name
        self.token = token
        self.rgba = rgba
    }
}

private let primitiveCases: [ColorCase] = [
    ColorCase("color/primary/0", PrimitiveColor.primary._0, 0xFFFFB9FF),
    ColorCase("color/primary/50", PrimitiveColor.primary._50, 0xF5FE76FF),
    ColorCase("color/primary/100", PrimitiveColor.primary._100, 0xFFF489FF),
    ColorCase("color/primary/200", PrimitiveColor.primary._200, 0xFAE05EFF),
    ColorCase("color/primary/300", PrimitiveColor.primary._300, 0xF6D631FF),
    ColorCase("color/primary/400", PrimitiveColor.primary._400, 0xF7CB3BFF),
    ColorCase("color/primary/500", PrimitiveColor.primary._500, 0xF6BB09FF),
    ColorCase("color/primary/600", PrimitiveColor.primary._600, 0xF1A727FF),
    ColorCase("color/primary/700", PrimitiveColor.primary._700, 0xF29407FF),
    ColorCase("color/primary/800", PrimitiveColor.primary._800, 0xEA8306FF),
    ColorCase("color/primary/900", PrimitiveColor.primary._900, 0xDB7100FF),
    ColorCase("color/neutral/0", PrimitiveColor.neutral._0, 0xFFFFFFFF),
    ColorCase("color/neutral/50", PrimitiveColor.neutral._50, 0xFCFCFCFF),
    ColorCase("color/neutral/100", PrimitiveColor.neutral._100, 0xF2F2F3FF),
    ColorCase("color/neutral/200", PrimitiveColor.neutral._200, 0xEAEAEBFF),
    ColorCase("color/neutral/300", PrimitiveColor.neutral._300, 0xDFDFE2FF),
    ColorCase("color/neutral/400", PrimitiveColor.neutral._400, 0xD5D5DFFF),
    ColorCase("color/neutral/500", PrimitiveColor.neutral._500, 0xCACACEFF),
    ColorCase("color/neutral/600", PrimitiveColor.neutral._600, 0xB0AFB5FF),
    ColorCase("color/neutral/700", PrimitiveColor.neutral._700, 0x7A7887FF),
    ColorCase("color/neutral/800", PrimitiveColor.neutral._800, 0x484753FF),
    ColorCase("color/neutral/900", PrimitiveColor.neutral._900, 0x34333EFF),
    ColorCase("color/neutral/1000", PrimitiveColor.neutral._1000, 0x202027FF),
    ColorCase("color/neutral/1100", PrimitiveColor.neutral._1100, 0x18181CFF),
    ColorCase("color/neutral/1200", PrimitiveColor.neutral._1200, 0x0E0E11FF),
    ColorCase("color/neutral/1300", PrimitiveColor.neutral._1300, 0x000000FF),
    ColorCase("color/system/blue", PrimitiveColor.system.blue, 0x0088FFFF),
    ColorCase("color/system/red", PrimitiveColor.system.red, 0xFF5F57FF),
    ColorCase("color/system/yellow", PrimitiveColor.system.yellow, 0xFEBC2FFF),
    ColorCase("color/system/green", PrimitiveColor.system.green, 0x6CE582FF),
    ColorCase("color/swatch/mint", PrimitiveColor.swatch.mint, 0xC3FACEFF),
    ColorCase("color/swatch/cyan", PrimitiveColor.swatch.cyan, 0xD2F8FEFF),
    ColorCase("color/swatch/lavender", PrimitiveColor.swatch.lavender, 0xE3DBFFFF),
    ColorCase("color/swatch/pink", PrimitiveColor.swatch.pink, 0xFDE1FFFF),
]

private let alphaCases: [ColorCase] = [
    ColorCase("overlay/dark/0", AlphaColor.overlay.dark._0, 0x00000000),
    ColorCase("overlay/dark/10", AlphaColor.overlay.dark._10, 0x0000001A),
    ColorCase("overlay/dark/20", AlphaColor.overlay.dark._20, 0x00000033),
    ColorCase("overlay/dark/40", AlphaColor.overlay.dark._40, 0x00000066),
    ColorCase("overlay/dark/60", AlphaColor.overlay.dark._60, 0x00000099),
    ColorCase("overlay/dark/70", AlphaColor.overlay.dark._70, 0x000000B2),
    ColorCase("overlay/dark/90", AlphaColor.overlay.dark._90, 0x000000E5),
    ColorCase("overlay/light/0", AlphaColor.overlay.light._0, 0xFAFAFA00),
    ColorCase("overlay/light/10", AlphaColor.overlay.light._10, 0xFAFAFA1A),
    ColorCase("overlay/light/20", AlphaColor.overlay.light._20, 0xFAFAFA33),
    ColorCase("overlay/light/40", AlphaColor.overlay.light._40, 0xFAFAFA66),
    ColorCase("overlay/light/60", AlphaColor.overlay.light._60, 0xFAFAFA99),
    ColorCase("overlay/light/70", AlphaColor.overlay.light._70, 0xFAFAFAB2),
    ColorCase("overlay/light/90", AlphaColor.overlay.light._90, 0xFAFAFAE5),
    ColorCase("overlay/light/100", AlphaColor.overlay.light._100, 0xFAFAFAFF),
    ColorCase("overlay/gray/10", AlphaColor.overlay.gray._10, 0xAFAFAF1A),
    ColorCase("overlay/gray/20", AlphaColor.overlay.gray._20, 0xAFAFAF33),
    ColorCase("overlay/gray/40", AlphaColor.overlay.gray._40, 0x706D8266),
    ColorCase("overlay/gray/70", AlphaColor.overlay.gray._70, 0xAFAFAFB2),
    ColorCase("overlay/gray/80", AlphaColor.overlay.gray._80, 0x423F55CC),
]
