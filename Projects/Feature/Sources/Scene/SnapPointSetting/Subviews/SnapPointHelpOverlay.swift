import SharedDesignSystem
import SwiftUI

/// `?` 로 띄우는 도움말 덮개. 어디를 눌러도 닫힌다. 헤더는 덮개 위에 남는다.
struct SnapPointHelpOverlay: View {
    let onDismiss: () -> Void

    /// 그림 안 글자(「이게모지?」 등)는 그림에 들어 있어 따로 그리지 않는다. 아래 설명만 글자로 그린다.
    private static let steps: [(picture: Image, caption: String)] = [
        (Image.ds.snapPoint.help01, "활동 알림을 받고"),
        (Image.ds.snapPoint.help02, "스냅 포인트를 따라\n영상을 찍으면"),
        (Image.ds.snapPoint.help03, "모두의 스냅이\n필름에 모여요"),
    ]

    var body: some View {
        VStack(spacing: SnapPointHelpOverlayLayout.titleToStepsSpacing) {
            DesignText(
                "모임 멤버들에게 스냅 촬영 알림을 보낼 수 있어요.",
                style: TextStyle.ds.caption1.medium,
                color: Color.ds.text.accent.highlight,
                alignment: .center
            )
            HStack(alignment: .top, spacing: SnapPointHelpOverlayLayout.stepSpacing) {
                ForEach(Self.steps, id: \.caption) { item in
                    step(picture: item.picture, caption: item.caption)
                }
            }
        }
        .padding(.top, SnapPointHelpOverlayLayout.topInset)
        .padding(.horizontal, CGFloat.ds.layout.margin)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Color.ds.overlay.dim._70)
                .ignoresSafeArea()
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onDismiss)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("누르면 도움말을 닫아요")
    }

    private func step(picture: Image, caption: String) -> some View {
        VStack(spacing: SnapPointHelpOverlayLayout.pictureToCaptionSpacing) {
            picture
                .resizable()
                .frame(
                    width: SnapPointHelpOverlayLayout.pictureSize.width,
                    height: SnapPointHelpOverlayLayout.pictureSize.height
                )
                .accessibilityHidden(true)
            DesignText(
                caption,
                style: TextStyle.ds.caption2.regular,
                color: Color.ds.text.neutral.tertiary,
                alignment: .center
            )
            .frame(width: SnapPointHelpOverlayLayout.pictureSize.width)
        }
    }
}

/// 시안 `2836:142745` 의 `설명그림영역` 값
private enum SnapPointHelpOverlayLayout {
    /// 시안은 화면 위에서 120 이다. 헤더(99) 아래부터 잰 값이다
    static let topInset: CGFloat = 21
    static let titleToStepsSpacing: CGFloat = 23
    static let stepSpacing: CGFloat = CGFloat.ds.spacing.sm
    static let pictureToCaptionSpacing: CGFloat = CGFloat.ds.spacing.sm
    static let pictureSize = CGSize(width: 102, height: 124)
}
