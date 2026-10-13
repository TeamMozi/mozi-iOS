import SwiftUI

/// 칸 묶음 치수·색. 시안 Form Group.
enum DesignFormGroupMetrics {
    /// Figma `radius` 변수에 없는 시안 값 26.
    static let cornerRadius: CGFloat = CGFloat.ds.radius._26
    /// 안쪽 여백은 없다. 줄(시안 Row)이 제 여백을 가진다.
    static let padding: CGFloat = 0
    static let spacing: CGFloat = 0
    /// 알파 색 `overlay/gray/10`. 두 모드에 같다.
    static let fill = SemanticColor.overlay.gray._10
}

/// 줄 구분선 치수·색. 시안 Row 의 Separator.
enum DesignFormRowSeparatorMetrics {
    /// 토큰이 없는 시안 값 14.
    static let leadingInset: CGFloat = 14
    static let trailingInset: CGFloat = CGFloat.ds.spacing.lg
    static let thickness: CGFloat = CGFloat.ds.border.thin
    /// 시안 그대로 `border/neutral/30`. 다크에서 칸 묶음 채움 위로 잘 안 보이는 것은 알고 둔다.
    static let color = SemanticColor.border.neutral._30

    /// 칸 너비에서 좌우 들여씀을 뺀 구분선 길이. 모자라면 0.
    static func length(in width: CGFloat) -> CGFloat {
        max(0, width - leadingInset - trailingInset)
    }
}

/// 둥근 칸 묶음. 시안 Form Group.
/// 줄을 위에서 아래로 사이 간격 없이 쌓고, 너비를 채운 뒤 모서리 26 · `overlay/gray/10` 채움을 깐다.
/// 안쪽 여백은 없다. 줄 높이·여백과 줄 사이 구분선(`DesignFormRowSeparator`)은 쓰는 쪽이 넣는다.
public struct DesignFormGroup<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignFormGroupMetrics.spacing) {
            content
        }
        .padding(DesignFormGroupMetrics.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignFormGroupMetrics.cornerRadius)
                .fill(DesignFormGroupMetrics.fill.color)
        )
    }
}

/// 칸 묶음 안 줄 사이 구분선. 시안 Row 의 Separator.
/// 왼쪽 14 · 오른쪽 16 들여 1pt `border/neutral/30` 을 긋는다. 누름을 받지 않는다.
/// 줄 사이에 그대로 두거나, 줄 아래 끝에 `.overlay(alignment: .bottom) { DesignFormRowSeparator() }` 로 얹는다.
public struct DesignFormRowSeparator: View {
    public init() {}

    public var body: some View {
        Rectangle()
            .fill(DesignFormRowSeparatorMetrics.color.color)
            .frame(height: DesignFormRowSeparatorMetrics.thickness)
            .padding(.leading, DesignFormRowSeparatorMetrics.leadingInset)
            .padding(.trailing, DesignFormRowSeparatorMetrics.trailingInset)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}
