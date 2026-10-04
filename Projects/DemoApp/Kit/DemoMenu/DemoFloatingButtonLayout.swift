import CoreGraphics
import SharedDesignSystem

/// 떠 있는 데모 버튼의 크기와 자리. 기본 자리는 안전 영역 오른쪽 아래다.
public enum DemoFloatingButtonLayout {
    public static let diameter: CGFloat = 52
    public static let trailingInset = CGFloat.ds.layout.margin
    public static let bottomInset: CGFloat = 72
    /// 끌어서 옮길 때 안전 영역 가장자리와 남기는 거리.
    static let edgeMargin = CGFloat.ds.spacing.lg

    /// 기본 자리에서 옮긴 거리를 안전 영역 안쪽으로 묶는다.
    public static func clampedOffset(_ offset: CGSize, in container: CGSize) -> CGSize {
        let minX = -(container.width - diameter - trailingInset - edgeMargin)
        let minY = -(container.height - diameter - bottomInset - edgeMargin)
        let maxY = bottomInset - edgeMargin
        return CGSize(
            width: min(0, max(minX, offset.width)),
            height: min(maxY, max(minY, offset.height))
        )
    }
}
