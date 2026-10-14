import SwiftUI

/// 목록 줄의 크기 모양.
public enum DesignListRowStyle: Equatable, Sendable {
    /// 지금 모양. 좌우 16·위아래 12, 제목 Body/SemiBold, 보조 Caption1/Regular tertiary.
    case standard
    /// 장소 검색 결과(시안 `5068:94944`). 좌우 20·위아래 10·높이 64, 제목 Headline/SemiBold, 주소 Caption1/Regular tertiary.
    case place
    /// 배경음악 곡(시안 `2891:164841`). 좌우 20·위아래 12·높이 64, 제목 Caption1/SemiBold secondary,
    /// 보조 Caption2/Regular subtle, 고른 줄 바탕 `overlay/gray/10`.
    case music
}

/// 목록 줄. 앞칸(아이콘·그림)·제목·보조 글·끝칸을 한 줄에 둔다. 고른 줄은 바탕을 칠한다.
/// 누르는 일은 쓰는 쪽이 `Button` 으로 감싸서 한다(`.buttonStyle(.plain)`).
public struct DesignListRow<Leading: View, Trailing: View>: View {
    private let title: String
    private let subtitle: String?
    private let isSelected: Bool
    private let style: DesignListRowStyle
    private let leading: Leading
    private let trailing: Trailing

    public init(
        _ title: String,
        subtitle: String? = nil,
        isSelected: Bool = false,
        style: DesignListRowStyle = .standard,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.style = style
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
        let layout = DesignListRowLayout.of(style)
        HStack(spacing: CGFloat.ds.spacing.md) {
            leading
            VStack(alignment: .leading, spacing: layout.textSpacing) {
                DesignText(title, style: layout.titleStyle, color: layout.titleColor.color, lineLimit: 1)
                if let subtitle {
                    DesignText(
                        subtitle,
                        style: layout.subtitleStyle,
                        color: layout.subtitleColor.color,
                        lineLimit: 1
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            trailing
        }
        .padding(.horizontal, layout.horizontalPadding)
        .padding(.vertical, layout.verticalPadding)
        .frame(minHeight: layout.minHeight)
        .background(isSelected ? layout.selectedBackground.color : Color.clear)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

public extension DesignListRow where Trailing == EmptyView {
    /// 끝칸 없는 줄.
    init(
        _ title: String,
        subtitle: String? = nil,
        isSelected: Bool = false,
        style: DesignListRowStyle = .standard,
        @ViewBuilder leading: () -> Leading
    ) {
        self.init(
            title,
            subtitle: subtitle,
            isSelected: isSelected,
            style: style,
            leading: leading,
            trailing: { EmptyView() }
        )
    }
}

/// 목록 줄 모양별 치수·글자·색. 토큰이 없는 값(좌우 20, 높이 64, 글자 사이 6)을 여기 둔다.
struct DesignListRowLayout: Equatable, Sendable {
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    /// nil 이면 내용 높이를 따른다.
    let minHeight: CGFloat?
    let titleStyle: TextStyle
    let titleColor: ThemedColor
    let subtitleStyle: TextStyle
    let subtitleColor: ThemedColor
    let textSpacing: CGFloat
    let selectedBackground: ThemedColor

    private static let wideHorizontalPadding: CGFloat = 20
    private static let tallHeight: CGFloat = 64

    static func of(_ style: DesignListRowStyle) -> DesignListRowLayout {
        switch style {
        case .standard:
            DesignListRowLayout(
                horizontalPadding: CGFloat.ds.layout.margin,
                verticalPadding: CGFloat.ds.spacing.md,
                minHeight: nil,
                titleStyle: TextStyle.ds.body.semiBold,
                titleColor: SemanticColor.text.neutral.primary,
                subtitleStyle: TextStyle.ds.caption1.regular,
                subtitleColor: SemanticColor.text.neutral.tertiary,
                textSpacing: CGFloat.ds.spacing.xs,
                selectedBackground: SemanticColor.fill.neutral.subtle
            )
        case .place:
            DesignListRowLayout(
                horizontalPadding: wideHorizontalPadding,
                verticalPadding: 10,
                minHeight: tallHeight,
                titleStyle: TextStyle.ds.headline.semiBold,
                titleColor: SemanticColor.text.neutral.primary,
                subtitleStyle: TextStyle.ds.caption1.regular,
                subtitleColor: SemanticColor.text.neutral.tertiary,
                textSpacing: CGFloat.ds.spacing.xs,
                selectedBackground: SemanticColor.fill.neutral.subtle
            )
        case .music:
            DesignListRowLayout(
                horizontalPadding: wideHorizontalPadding,
                verticalPadding: CGFloat.ds.spacing.md,
                minHeight: tallHeight,
                titleStyle: TextStyle.ds.caption1.semiBold,
                titleColor: SemanticColor.text.neutral.secondary,
                subtitleStyle: TextStyle.ds.caption2.regular,
                subtitleColor: SemanticColor.text.neutral.subtle,
                textSpacing: 6,
                selectedBackground: SemanticColor.overlay.gray._10
            )
        }
    }
}
