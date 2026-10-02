@testable import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

final class SemanticColorTests: XCTestCase {
    func test_의미_색_63개의_다크_라이트_쌍이_Figma_별칭_값이다() {
        for item in semanticCases {
            XCTAssertEqual(rgba(item.theme.dark), item.dark, "\(item.name) dark")
            XCTAssertEqual(rgba(item.theme.light), item.light, "\(item.name) light")
        }
    }

    @MainActor
    func test_공개_색을_다크_trait_으로_풀면_다크_값이다() {
        for item in semanticCases {
            XCTAssertEqual(rgba(UIColor(item.color), in: .dark), item.dark, item.name)
        }
    }

    @MainActor
    func test_공개_색을_라이트_trait_으로_풀면_라이트_값이다() {
        for item in semanticCases {
            XCTAssertEqual(rgba(UIColor(item.color), in: .light), item.light, item.name)
        }
    }

    @MainActor
    func test_공개_색을_모드가_정해지지_않은_trait_으로_풀면_다크_값이다() {
        for item in semanticCases {
            XCTAssertEqual(rgba(UIColor(item.color), in: .unspecified), item.dark, item.name)
        }
    }

    @MainActor
    func test_소셜_색_다섯은_두_모드에서_같은_브랜드_색이다() {
        let cases: [(Color, UInt32)] = [
            (Color.ds.social.kakao, 0xFEE500FF),
            (Color.ds.social.kakaoContent, 0x000000FF),
            (Color.ds.social.appleBackground, 0xFFFFFFFF),
            (Color.ds.social.appleBorder, 0x000000FF),
            (Color.ds.social.appleContent, 0x000000FF),
        ]
        for (color, expected) in cases {
            XCTAssertEqual(rgba(UIColor(color), in: .dark), expected)
            XCTAssertEqual(rgba(UIColor(color), in: .light), expected)
        }
    }
}

/// Figma 이름, 내부 쌍, 공개 색, 기대값 `0xRRGGBBAA` 두 개.
private struct SemanticCase {
    let name: String
    let theme: ThemedColor
    let color: Color
    let dark: UInt32
    let light: UInt32

    init(_ name: String, _ theme: ThemedColor, _ color: Color, dark: UInt32, light: UInt32) {
        self.name = name
        self.theme = theme
        self.color = color
        self.dark = dark
        self.light = light
    }
}

private let semanticCases: [SemanticCase] = [
    SemanticCase(
        "text/neutral/primary",
        SemanticColor.text.neutral.primary,
        Color.ds.text.neutral.primary,
        dark: 0xFCFCFCFF,
        light: 0x0E0E11FF
    ),
    SemanticCase(
        "text/neutral/secondary",
        SemanticColor.text.neutral.secondary,
        Color.ds.text.neutral.secondary,
        dark: 0xCACACEFF,
        light: 0x484753FF
    ),
    SemanticCase(
        "text/neutral/tertiary",
        SemanticColor.text.neutral.tertiary,
        Color.ds.text.neutral.tertiary,
        dark: 0xB0AFB5FF,
        light: 0x7A7887FF
    ),
    SemanticCase(
        "text/neutral/subtle",
        SemanticColor.text.neutral.subtle,
        Color.ds.text.neutral.subtle,
        dark: 0x7A7887FF,
        light: 0xB0AFB5FF
    ),
    SemanticCase(
        "text/neutral/faint",
        SemanticColor.text.neutral.faint,
        Color.ds.text.neutral.faint,
        dark: 0x484753FF,
        light: 0xCACACEFF
    ),
    SemanticCase(
        "text/neutral/inverse",
        SemanticColor.text.neutral.inverse,
        Color.ds.text.neutral.inverse,
        dark: 0x000000FF,
        light: 0xFFFFFFFF
    ),
    SemanticCase(
        "text/accent/default",
        SemanticColor.text.accent.default,
        Color.ds.text.accent.default,
        dark: 0xFFF489FF,
        light: 0xF6BB09FF
    ),
    SemanticCase(
        "text/accent/subtle",
        SemanticColor.text.accent.subtle,
        Color.ds.text.accent.subtle,
        dark: 0xFAE05EFF,
        light: 0xF7CB3BFF
    ),
    SemanticCase(
        "text/accent/highlight",
        SemanticColor.text.accent.highlight,
        Color.ds.text.accent.highlight,
        dark: 0xF5FE76FF,
        light: 0xF29407FF
    ),
    SemanticCase(
        "text/accent/strong",
        SemanticColor.text.accent.strong,
        Color.ds.text.accent.strong,
        dark: 0xFFFFB9FF,
        light: 0xF1A727FF
    ),
    SemanticCase(
        "fill/neutral/default",
        SemanticColor.fill.neutral.default,
        Color.ds.fill.neutral.default,
        dark: 0x000000FF,
        light: 0xFCFCFCFF
    ),
    SemanticCase(
        "fill/neutral/surface",
        SemanticColor.fill.neutral.surface,
        Color.ds.fill.neutral.surface,
        dark: 0x000000FF,
        light: 0xFFFFFFFF
    ),
    SemanticCase(
        "fill/neutral/subtle",
        SemanticColor.fill.neutral.subtle,
        Color.ds.fill.neutral.subtle,
        dark: 0x18181CFF,
        light: 0xF2F2F3FF
    ),
    SemanticCase(
        "fill/neutral/raised",
        SemanticColor.fill.neutral.raised,
        Color.ds.fill.neutral.raised,
        dark: 0x202027FF,
        light: 0xEAEAEBFF
    ),
    SemanticCase(
        "fill/neutral/strong",
        SemanticColor.fill.neutral.strong,
        Color.ds.fill.neutral.strong,
        dark: 0x34333EFF,
        light: 0xD5D5DFFF
    ),
    SemanticCase(
        "fill/neutral/muted",
        SemanticColor.fill.neutral.muted,
        Color.ds.fill.neutral.muted,
        dark: 0x34333EFF,
        light: 0xDFDFE2FF
    ),
    SemanticCase(
        "fill/neutral/heavy",
        SemanticColor.fill.neutral.heavy,
        Color.ds.fill.neutral.heavy,
        dark: 0x484753FF,
        light: 0x7A7887FF
    ),
    SemanticCase(
        "fill/neutral/inverse",
        SemanticColor.fill.neutral.inverse,
        Color.ds.fill.neutral.inverse,
        dark: 0xFCFCFCFF,
        light: 0x0E0E11FF
    ),
    SemanticCase(
        "fill/accent/default",
        SemanticColor.fill.accent.default,
        Color.ds.fill.accent.default,
        dark: 0xFFF489FF,
        light: 0xFAE05EFF
    ),
    SemanticCase(
        "fill/accent/vivid",
        SemanticColor.fill.accent.vivid,
        Color.ds.fill.accent.vivid,
        dark: 0xF5FE76FF,
        light: 0xF6D631FF
    ),
    SemanticCase(
        "fill/accent/muted",
        SemanticColor.fill.accent.muted,
        Color.ds.fill.accent.muted,
        dark: 0xFFFFB9FF,
        light: 0xFAE05EFF
    ),
    SemanticCase(
        "border/neutral/0",
        SemanticColor.border.neutral._0,
        Color.ds.border.neutral._0,
        dark: 0x000000FF,
        light: 0xFCFCFCFF
    ),
    SemanticCase(
        "border/neutral/10",
        SemanticColor.border.neutral._10,
        Color.ds.border.neutral._10,
        dark: 0x0E0E11FF,
        light: 0xEAEAEBFF
    ),
    SemanticCase(
        "border/neutral/20",
        SemanticColor.border.neutral._20,
        Color.ds.border.neutral._20,
        dark: 0x34333EFF,
        light: 0xD5D5DFFF
    ),
    SemanticCase(
        "border/neutral/30",
        SemanticColor.border.neutral._30,
        Color.ds.border.neutral._30,
        dark: 0x18181CFF,
        light: 0xEAEAEBFF
    ),
    SemanticCase(
        "border/neutral/40",
        SemanticColor.border.neutral._40,
        Color.ds.border.neutral._40,
        dark: 0x202027FF,
        light: 0xCACACEFF
    ),
    SemanticCase(
        "border/neutral/50",
        SemanticColor.border.neutral._50,
        Color.ds.border.neutral._50,
        dark: 0x7A7887FF,
        light: 0x484753FF
    ),
    SemanticCase(
        "border/neutral/inverse",
        SemanticColor.border.neutral.inverse,
        Color.ds.border.neutral.inverse,
        dark: 0xFCFCFCFF,
        light: 0x0E0E11FF
    ),
    SemanticCase(
        "border/accent/basic",
        SemanticColor.border.accent.basic,
        Color.ds.border.accent.basic,
        dark: 0xFFF489FF,
        light: 0xF7CB3BFF
    ),
    SemanticCase(
        "border/accent/dark",
        SemanticColor.border.accent.dark,
        Color.ds.border.accent.dark,
        dark: 0xFFF489FF,
        light: 0xFAE05EFF
    ),
    SemanticCase(
        "border/accent/darker",
        SemanticColor.border.accent.darker,
        Color.ds.border.accent.darker,
        dark: 0xFFFFFFFF,
        light: 0xFFFFFFFF
    ),
    SemanticCase(
        "button/background/main/default",
        SemanticColor.button.background.main.default,
        Color.ds.button.background.main.default,
        dark: 0xFFF489FF,
        light: 0xFFF489FF
    ),
    SemanticCase(
        "button/background/main/pressed",
        SemanticColor.button.background.main.pressed,
        Color.ds.button.background.main.pressed,
        dark: 0xF7CB3BFF,
        light: 0xF7CB3BFF
    ),
    SemanticCase(
        "button/background/main/disabled",
        SemanticColor.button.background.main.disabled,
        Color.ds.button.background.main.disabled,
        dark: 0x18181CFF,
        light: 0xEAEAEBFF
    ),
    SemanticCase(
        "button/background/neutral/default",
        SemanticColor.button.background.neutral.default,
        Color.ds.button.background.neutral.default,
        dark: 0x202027FF,
        light: 0xF2F2F3FF
    ),
    SemanticCase(
        "button/background/neutral/pressed",
        SemanticColor.button.background.neutral.pressed,
        Color.ds.button.background.neutral.pressed,
        dark: 0x18181CFF,
        light: 0xD5D5DFFF
    ),
    SemanticCase(
        "button/background/neutral/disabled",
        SemanticColor.button.background.neutral.disabled,
        Color.ds.button.background.neutral.disabled,
        dark: 0x18181CFF,
        light: 0xEAEAEBFF
    ),
    SemanticCase(
        "button/background/ghost/default",
        SemanticColor.button.background.ghost.default,
        Color.ds.button.background.ghost.default,
        dark: 0x000000FF,
        light: 0xFCFCFCFF
    ),
    SemanticCase(
        "button/background/ghost/pressed",
        SemanticColor.button.background.ghost.pressed,
        Color.ds.button.background.ghost.pressed,
        dark: 0x18181CFF,
        light: 0xEAEAEBFF
    ),
    SemanticCase(
        "button/background/ghost/disabled",
        SemanticColor.button.background.ghost.disabled,
        Color.ds.button.background.ghost.disabled,
        dark: 0x000000FF,
        light: 0xFCFCFCFF
    ),
    SemanticCase(
        "button/background/icon/default",
        SemanticColor.button.background.icon.default,
        Color.ds.button.background.icon.default,
        dark: 0xAFAFAF33,
        light: 0xFAFAFA99
    ),
    SemanticCase(
        "button/label/main/default",
        SemanticColor.button.label.main.default,
        Color.ds.button.label.main.default,
        dark: 0x0E0E11FF,
        light: 0x0E0E11FF
    ),
    SemanticCase(
        "button/label/main/pressed",
        SemanticColor.button.label.main.pressed,
        Color.ds.button.label.main.pressed,
        dark: 0x0E0E11FF,
        light: 0x0E0E11FF
    ),
    SemanticCase(
        "button/label/main/disabled",
        SemanticColor.button.label.main.disabled,
        Color.ds.button.label.main.disabled,
        dark: 0x7A7887FF,
        light: 0xB0AFB5FF
    ),
    SemanticCase(
        "button/label/neutral/default",
        SemanticColor.button.label.neutral.default,
        Color.ds.button.label.neutral.default,
        dark: 0xB0AFB5FF,
        light: 0x7A7887FF
    ),
    SemanticCase(
        "button/label/neutral/pressed",
        SemanticColor.button.label.neutral.pressed,
        Color.ds.button.label.neutral.pressed,
        dark: 0xB0AFB5FF,
        light: 0x7A7887FF
    ),
    SemanticCase(
        "button/label/neutral/disabled",
        SemanticColor.button.label.neutral.disabled,
        Color.ds.button.label.neutral.disabled,
        dark: 0x7A7887FF,
        light: 0xB0AFB5FF
    ),
    SemanticCase(
        "button/label/ghost/default",
        SemanticColor.button.label.ghost.default,
        Color.ds.button.label.ghost.default,
        dark: 0xFFF489FF,
        light: 0xF7CB3BFF
    ),
    SemanticCase(
        "button/label/ghost/pressed",
        SemanticColor.button.label.ghost.pressed,
        Color.ds.button.label.ghost.pressed,
        dark: 0xFFF489FF,
        light: 0xF7CB3BFF
    ),
    SemanticCase(
        "button/label/ghost/disabled",
        SemanticColor.button.label.ghost.disabled,
        Color.ds.button.label.ghost.disabled,
        dark: 0x7A7887FF,
        light: 0xB0AFB5FF
    ),
    SemanticCase(
        "button/label/text/accent",
        SemanticColor.button.label.text.accent,
        Color.ds.button.label.text.accent,
        dark: 0xF5FE76FF,
        light: 0xF29407FF
    ),
    SemanticCase(
        "button/label/text/neutral",
        SemanticColor.button.label.text.neutral,
        Color.ds.button.label.text.neutral,
        dark: 0x7A7887FF,
        light: 0xB0AFB5FF
    ),
    SemanticCase(
        "overlay/dim/0",
        SemanticColor.overlay.dim._0,
        Color.ds.overlay.dim._0,
        dark: 0x00000000,
        light: 0xFAFAFA00
    ),
    SemanticCase(
        "overlay/dim/20",
        SemanticColor.overlay.dim._20,
        Color.ds.overlay.dim._20,
        dark: 0x00000033,
        light: 0xFAFAFA33
    ),
    SemanticCase(
        "overlay/dim/40",
        SemanticColor.overlay.dim._40,
        Color.ds.overlay.dim._40,
        dark: 0x00000066,
        light: 0xFAFAFA66
    ),
    SemanticCase(
        "overlay/dim/60",
        SemanticColor.overlay.dim._60,
        Color.ds.overlay.dim._60,
        dark: 0x00000099,
        light: 0xFAFAFA99
    ),
    SemanticCase(
        "overlay/dim/70",
        SemanticColor.overlay.dim._70,
        Color.ds.overlay.dim._70,
        dark: 0x000000B2,
        light: 0xFAFAFACC
    ),
    SemanticCase(
        "overlay/dim/90",
        SemanticColor.overlay.dim._90,
        Color.ds.overlay.dim._90,
        dark: 0x000000E5,
        light: 0xFAFAFAE5
    ),
    SemanticCase(
        "overlay/inverse/10",
        SemanticColor.overlay.inverse._10,
        Color.ds.overlay.inverse._10,
        dark: 0xFAFAFA1A,
        light: 0x0000001A
    ),
    SemanticCase(
        "overlay/inverse/20",
        SemanticColor.overlay.inverse._20,
        Color.ds.overlay.inverse._20,
        dark: 0xFAFAFA33,
        light: 0x00000033
    ),
    SemanticCase(
        "overlay/inverse/40",
        SemanticColor.overlay.inverse._40,
        Color.ds.overlay.inverse._40,
        dark: 0xFAFAFA66,
        light: 0x00000066
    ),
    SemanticCase(
        "overlay/gray/default",
        SemanticColor.overlay.gray.default,
        Color.ds.overlay.gray.default,
        dark: 0x706D8233,
        light: 0xAFAFAF33
    ),
    SemanticCase(
        "overlay/gray/plain",
        SemanticColor.overlay.gray.plain,
        Color.ds.overlay.gray.plain,
        dark: 0x00000066,
        light: 0xFCFCFCFF
    ),
]
