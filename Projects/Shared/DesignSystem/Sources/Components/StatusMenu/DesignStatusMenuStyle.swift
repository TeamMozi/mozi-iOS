import CoreGraphics

/// 상태 드롭다운의 항목 셋. 표시용이고 Domain 의 모집 상태와 다르다. Feature 가 둘을 바꾼다.
public enum DesignRecruitStatus: String, CaseIterable, Identifiable, Sendable {
    case recruiting
    case closed
    case ended

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .recruiting: "모집 중"
        case .closed: "모집 마감"
        case .ended: "종료"
        }
    }
}

/// Figma status dropdown 의 접힌 알약 색. 「모집 마감」은 Figma 에 의미 색이 없어 원시 빨강이다.
enum DesignStatusMenuStyleResolver {
    static let background = SemanticColor.overlay.gray.default
    static let chevron = SemanticColor.text.neutral.subtle

    static func text(for status: DesignRecruitStatus) -> ThemedColor {
        switch status {
        case .recruiting:
            SemanticColor.text.accent.highlight
        case .closed:
            ThemedColor.fixed(PrimitiveColor.system.red)
        case .ended:
            SemanticColor.text.neutral.subtle
        }
    }
}

/// 접힌 알약 치수. 글자 칸 폭이 고정이라 너비는 상태와 상관없이 105 다.
enum DesignStatusMenuMetrics {
    static let cornerRadius: CGFloat = 14
    static let verticalPadding: CGFloat = 6
    static let horizontalPadding: CGFloat = 11
    static let labelWidth: CGFloat = 54
    /// Figma 의 간격 6 + 보이지 않는 구분선 1 + 간격 6.
    static let labelToChevronSpacing: CGFloat = 13
    static let chevronSize: CGFloat = 16
}
