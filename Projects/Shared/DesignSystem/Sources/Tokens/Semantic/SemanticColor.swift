import Foundation

/// Figma 의미 색 63개, Figma 알파 색을 두 모드에 같이 건 `overlay.gray._10`, Figma 밖 상태 글자색 둘(`text.status`). 다크·라이트 두 모드의 원시 색 쌍을 Figma 별칭 그대로 적는다.
/// 공개 길은 `Color.ds` 다. 여기 값은 부품과 테스트가 쓴다.
enum SemanticColor {
    static let text = SemanticTextColors()
    static let fill = SemanticFillColors()
    static let border = SemanticBorderColors()
    static let button = SemanticButtonColors()
    static let overlay = SemanticOverlayColors()
}

struct SemanticTextColors: Sendable {
    let neutral = SemanticTextNeutralColors()
    let accent = SemanticTextAccentColors()
    let status = SemanticTextStatusColors()
}

struct SemanticTextNeutralColors: Sendable {
    let primary = ThemedColor(dark: PrimitiveColor.neutral._50, light: PrimitiveColor.neutral._1200)
    let secondary = ThemedColor(dark: PrimitiveColor.neutral._500, light: PrimitiveColor.neutral._800)
    let tertiary = ThemedColor(dark: PrimitiveColor.neutral._600, light: PrimitiveColor.neutral._700)
    let subtle = ThemedColor(dark: PrimitiveColor.neutral._700, light: PrimitiveColor.neutral._600)
    let faint = ThemedColor(dark: PrimitiveColor.neutral._800, light: PrimitiveColor.neutral._500)
    let inverse = ThemedColor(dark: PrimitiveColor.neutral._1300, light: PrimitiveColor.neutral._0)
}

struct SemanticTextAccentColors: Sendable {
    let `default` = ThemedColor(dark: PrimitiveColor.primary._100, light: PrimitiveColor.primary._500)
    let subtle = ThemedColor(dark: PrimitiveColor.primary._200, light: PrimitiveColor.primary._400)
    let highlight = ThemedColor(dark: PrimitiveColor.primary._50, light: PrimitiveColor.primary._700)
    let strong = ThemedColor(dark: PrimitiveColor.primary._0, light: PrimitiveColor.primary._600)
}

/// Figma 에 의미 색이 없어 원시 색 `color/system/green`·`color/system/red` 를 두 모드에 같이 건다.
/// 시안의 「모집 중」 초록, 「종료」·「모임 삭제」 빨강 글자다.
struct SemanticTextStatusColors: Sendable {
    let positive = ThemedColor(dark: PrimitiveColor.system.green, light: PrimitiveColor.system.green)
    let negative = ThemedColor(dark: PrimitiveColor.system.red, light: PrimitiveColor.system.red)
}

struct SemanticFillColors: Sendable {
    let neutral = SemanticFillNeutralColors()
    let accent = SemanticFillAccentColors()
}

struct SemanticFillNeutralColors: Sendable {
    let `default` = ThemedColor(dark: PrimitiveColor.neutral._1300, light: PrimitiveColor.neutral._50)
    let surface = ThemedColor(dark: PrimitiveColor.neutral._1300, light: PrimitiveColor.neutral._0)
    let subtle = ThemedColor(dark: PrimitiveColor.neutral._1100, light: PrimitiveColor.neutral._100)
    let raised = ThemedColor(dark: PrimitiveColor.neutral._1000, light: PrimitiveColor.neutral._200)
    let strong = ThemedColor(dark: PrimitiveColor.neutral._900, light: PrimitiveColor.neutral._400)
    let muted = ThemedColor(dark: PrimitiveColor.neutral._900, light: PrimitiveColor.neutral._300)
    let heavy = ThemedColor(dark: PrimitiveColor.neutral._800, light: PrimitiveColor.neutral._700)
    let inverse = ThemedColor(dark: PrimitiveColor.neutral._50, light: PrimitiveColor.neutral._1200)
}

struct SemanticFillAccentColors: Sendable {
    let `default` = ThemedColor(dark: PrimitiveColor.primary._100, light: PrimitiveColor.primary._200)
    let vivid = ThemedColor(dark: PrimitiveColor.primary._50, light: PrimitiveColor.primary._300)
    let muted = ThemedColor(dark: PrimitiveColor.primary._0, light: PrimitiveColor.primary._200)
}

struct SemanticBorderColors: Sendable {
    let neutral = SemanticBorderNeutralColors()
    let accent = SemanticBorderAccentColors()
}

struct SemanticBorderNeutralColors: Sendable {
    let _0 = ThemedColor(dark: PrimitiveColor.neutral._1300, light: PrimitiveColor.neutral._50)
    let _10 = ThemedColor(dark: PrimitiveColor.neutral._1200, light: PrimitiveColor.neutral._200)
    let _20 = ThemedColor(dark: PrimitiveColor.neutral._900, light: PrimitiveColor.neutral._400)
    let _30 = ThemedColor(dark: PrimitiveColor.neutral._1100, light: PrimitiveColor.neutral._200)
    let _40 = ThemedColor(dark: PrimitiveColor.neutral._1000, light: PrimitiveColor.neutral._500)
    let _50 = ThemedColor(dark: PrimitiveColor.neutral._700, light: PrimitiveColor.neutral._800)
    let inverse = ThemedColor(dark: PrimitiveColor.neutral._50, light: PrimitiveColor.neutral._1200)
}

struct SemanticBorderAccentColors: Sendable {
    let basic = ThemedColor(dark: PrimitiveColor.primary._100, light: PrimitiveColor.primary._400)
    let dark = ThemedColor(dark: PrimitiveColor.primary._100, light: PrimitiveColor.primary._200)
    let darker = ThemedColor(dark: PrimitiveColor.neutral._0, light: PrimitiveColor.neutral._0)
}

struct SemanticButtonColors: Sendable {
    let background = SemanticButtonBackgroundColors()
    let label = SemanticButtonLabelColors()
}

struct SemanticButtonBackgroundColors: Sendable {
    let main = SemanticButtonBackgroundMainColors()
    let neutral = SemanticButtonBackgroundNeutralColors()
    let ghost = SemanticButtonBackgroundGhostColors()
    let icon = SemanticButtonBackgroundIconColors()
}

struct SemanticButtonBackgroundMainColors: Sendable {
    let `default` = ThemedColor(dark: PrimitiveColor.primary._100, light: PrimitiveColor.primary._100)
    let pressed = ThemedColor(dark: PrimitiveColor.primary._400, light: PrimitiveColor.primary._400)
    let disabled = ThemedColor(dark: PrimitiveColor.neutral._1100, light: PrimitiveColor.neutral._200)
}

struct SemanticButtonBackgroundNeutralColors: Sendable {
    let `default` = ThemedColor(dark: PrimitiveColor.neutral._1000, light: PrimitiveColor.neutral._100)
    let pressed = ThemedColor(dark: PrimitiveColor.neutral._1100, light: PrimitiveColor.neutral._400)
    let disabled = ThemedColor(dark: PrimitiveColor.neutral._1100, light: PrimitiveColor.neutral._200)
}

struct SemanticButtonBackgroundGhostColors: Sendable {
    let `default` = ThemedColor(dark: PrimitiveColor.neutral._1300, light: PrimitiveColor.neutral._50)
    let pressed = ThemedColor(dark: PrimitiveColor.neutral._1100, light: PrimitiveColor.neutral._200)
    let disabled = ThemedColor(dark: PrimitiveColor.neutral._1300, light: PrimitiveColor.neutral._50)
}

struct SemanticButtonBackgroundIconColors: Sendable {
    let `default` = ThemedColor(dark: AlphaColor.overlay.gray._20, light: AlphaColor.overlay.light._60)
}

struct SemanticButtonLabelColors: Sendable {
    let main = SemanticButtonLabelMainColors()
    let neutral = SemanticButtonLabelNeutralColors()
    let ghost = SemanticButtonLabelGhostColors()
    let text = SemanticButtonLabelTextColors()
}

struct SemanticButtonLabelMainColors: Sendable {
    let `default` = ThemedColor(dark: PrimitiveColor.neutral._1200, light: PrimitiveColor.neutral._1200)
    let pressed = ThemedColor(dark: PrimitiveColor.neutral._1200, light: PrimitiveColor.neutral._1200)
    let disabled = ThemedColor(dark: PrimitiveColor.neutral._700, light: PrimitiveColor.neutral._600)
}

struct SemanticButtonLabelNeutralColors: Sendable {
    let `default` = ThemedColor(dark: PrimitiveColor.neutral._600, light: PrimitiveColor.neutral._700)
    let pressed = ThemedColor(dark: PrimitiveColor.neutral._600, light: PrimitiveColor.neutral._700)
    let disabled = ThemedColor(dark: PrimitiveColor.neutral._700, light: PrimitiveColor.neutral._600)
}

struct SemanticButtonLabelGhostColors: Sendable {
    let `default` = ThemedColor(dark: PrimitiveColor.primary._100, light: PrimitiveColor.primary._400)
    let pressed = ThemedColor(dark: PrimitiveColor.primary._100, light: PrimitiveColor.primary._400)
    let disabled = ThemedColor(dark: PrimitiveColor.neutral._700, light: PrimitiveColor.neutral._600)
}

struct SemanticButtonLabelTextColors: Sendable {
    let accent = ThemedColor(dark: PrimitiveColor.primary._50, light: PrimitiveColor.primary._700)
    let neutral = ThemedColor(dark: PrimitiveColor.neutral._700, light: PrimitiveColor.neutral._600)
}

struct SemanticOverlayColors: Sendable {
    let dim = SemanticOverlayDimColors()
    let inverse = SemanticOverlayInverseColors()
    let gray = SemanticOverlayGrayColors()
}

struct SemanticOverlayDimColors: Sendable {
    let _0 = ThemedColor(dark: AlphaColor.overlay.dark._0, light: AlphaColor.overlay.light._0)
    let _20 = ThemedColor(dark: AlphaColor.overlay.dark._20, light: AlphaColor.overlay.light._20)
    let _40 = ThemedColor(dark: AlphaColor.overlay.dark._40, light: AlphaColor.overlay.light._40)
    let _60 = ThemedColor(dark: AlphaColor.overlay.dark._60, light: AlphaColor.overlay.light._60)
    let _70 = ThemedColor(dark: AlphaColor.overlay.dark._70, light: AlphaColor.overlay.light._80)
    let _90 = ThemedColor(dark: AlphaColor.overlay.dark._90, light: AlphaColor.overlay.light._90)
}

struct SemanticOverlayInverseColors: Sendable {
    let _10 = ThemedColor(dark: AlphaColor.overlay.light._10, light: AlphaColor.overlay.dark._10)
    let _20 = ThemedColor(dark: AlphaColor.overlay.light._20, light: AlphaColor.overlay.dark._20)
    let _40 = ThemedColor(dark: AlphaColor.overlay.light._40, light: AlphaColor.overlay.dark._40)
}

struct SemanticOverlayGrayColors: Sendable {
    let `default` = ThemedColor(dark: AlphaColor.overlay.gray._40, light: AlphaColor.overlay.gray._20)
    let plain = ThemedColor(dark: AlphaColor.overlay.dark._40, light: PrimitiveColor.neutral._50)
    /// Figma `overlay/gray/10`(`Sementic Numbers` 의 한 모드 알파 색)을 시안이 그대로 쓴다. 두 모드에 같은 색이다.
    /// 다크 사이드바 `2798:102194` 의 행 묶음(Form Group)도 같은 변수에 묶여 있다.
    let _10 = ThemedColor(dark: AlphaColor.overlay.gray._10, light: AlphaColor.overlay.gray._10)
}
