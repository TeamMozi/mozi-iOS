import CoreGraphics

/// 체크박스 꼴. 시안의 selct · order · vote select.
public enum DesignCheckboxStyle: Equatable, Sendable {
    /// 회색 체크. 20 원.
    case check
    /// 번호. 26 원. 선택되면 숫자를 그린다.
    case order(Int)
    /// 검정 체크. 20 원.
    case vote
}

/// 체크박스 한 상태의 색과 지름. 없는 칠은 nil 이다. `content` 는 체크나 숫자 색이다.
struct DesignCheckboxPalette: Equatable, Sendable {
    let fill: ThemedColor?
    let border: ThemedColor?
    let content: ThemedColor?
    let diameter: CGFloat
}

/// 체크박스 치수. 토큰이 없는 원 지름을 여기 둔다.
enum DesignCheckboxMetrics {
    static let diameter: CGFloat = 20
    static let orderDiameter: CGFloat = 26
    /// 시안 체크는 20 원 안의 10×9 글리프다. 24 상자 아이콘의 글리프 비율로 가장 가까운 토큰 14 를 쓴다.
    static let checkIconSize: CGFloat = CGFloat.ds.iconSize._14
}

/// Figma Checkbox 의 해제·선택 색. 시안이 원시 색 변수를 바로 쓰는 자리는 두 모드에 같은 원시 색을 쓴다.
enum DesignCheckboxStyleResolver {
    static func resolve(style: DesignCheckboxStyle, isOn: Bool) -> DesignCheckboxPalette {
        switch (style, isOn) {
        case (.check, false), (.vote, false):
            DesignCheckboxPalette(
                fill: nil,
                border: SemanticColor.text.neutral.subtle,
                content: nil,
                diameter: DesignCheckboxMetrics.diameter
            )
        case (.check, true):
            DesignCheckboxPalette(
                fill: SemanticColor.text.neutral.tertiary,
                border: nil,
                content: ThemedColor.fixed(PrimitiveColor.neutral._0),
                diameter: DesignCheckboxMetrics.diameter
            )
        case (.vote, true):
            DesignCheckboxPalette(
                fill: ThemedColor.fixed(PrimitiveColor.neutral._1200),
                border: nil,
                content: ThemedColor.fixed(PrimitiveColor.neutral._0),
                diameter: DesignCheckboxMetrics.diameter
            )
        case (.order, false):
            DesignCheckboxPalette(
                fill: ThemedColor.fixed(AlphaColor.overlay.gray._70),
                border: ThemedColor.fixed(PrimitiveColor.neutral._200),
                content: nil,
                diameter: DesignCheckboxMetrics.orderDiameter
            )
        case (.order, true):
            DesignCheckboxPalette(
                fill: ThemedColor.fixed(PrimitiveColor.primary._100),
                border: nil,
                content: ThemedColor.fixed(PrimitiveColor.neutral._1200),
                diameter: DesignCheckboxMetrics.orderDiameter
            )
        }
    }}
