import SharedDesignSystem
import SwiftUI

/// 포스터 도구 줄 다섯 칸. 「오디오」 만 배경음악 시트를 열고, 넷은 흐리고 눌리지 않는다(편집 도구는 별도 작업).
struct PosterToolBar: View {
    let onAudio: () -> Void

    var body: some View {
        HStack(spacing: PosterToolBarLayout.spacing) {
            tool("배경", icon: Image.ds.icon.image.outlined, action: nil)
            tool("텍스트", icon: Image.ds.icon.text.outlined, action: nil)
            tool("스티커", icon: Image.ds.icon.overlay.outlined, action: nil)
            tool("콜라주", icon: Image.ds.icon.frame.outlined, action: nil)
            tool("오디오", icon: Image.ds.icon.music.outlined, action: onAudio)
        }
    }

    private func tool(_ title: String, icon: Image, action: (() -> Void)?) -> some View {
        Button {
            action?()
        } label: {
            VStack(spacing: PosterToolBarLayout.iconToLabel) {
                icon
                    .iconSize(CGFloat.ds.iconSize._24)
                    .foregroundStyle(Color.ds.text.neutral.primary)
                DesignText(title, style: PosterToolBarLayout.labelStyle)
            }
            .frame(width: PosterToolBarLayout.toolWidth)
            .padding(.vertical, CGFloat.ds.spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: CGFloat.ds.radius._10)
                    .fill(Color.ds.fill.neutral.subtle)
            )
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .opacity(action == nil ? PosterToolBarLayout.disabledOpacity : 1)
    }
}

private enum PosterToolBarLayout {
    static let disabledOpacity: Double = 0.4
    /// 칸 너비. 시안 ToolButton `2973:29955`
    static let toolWidth: CGFloat = 66
    static let spacing: CGFloat = 6
    static let iconToLabel: CGFloat = 2
    /// 도구 이름 ExtraLight 10/14 −1%. 시안 `2973:29949`
    static let labelStyle = TextStyle.ds.pretendard(.extraLight, size: 10, lineHeight: 14, letterSpacingEm: -0.01)
}
