import Domain
import SharedDesignSystem
import SwiftUI

/// 포스터 위 배경음악 알약. 고르기 전에는 「추천 배경음악 +」 다. 고른 뒤 모양은 디자이너 요청 목록에 있다.
struct PosterMusicPill: View {
    let music: BackgroundMusic?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: PosterMusicPillLayout.textToPlus) {
                HStack(spacing: CGFloat.ds.spacing.sm) {
                    PosterAlbumArt(url: music?.albumImageURL, size: PosterMusicPillLayout.artSize)
                    VStack(alignment: .leading, spacing: 0) {
                        if let music {
                            DesignText(music.title, style: TextStyle.ds.caption1.semiBold, lineLimit: 1)
                        }
                        DesignText("추천 배경음악", style: PosterMusicPillLayout.captionStyle)
                    }
                    .frame(
                        width: PosterMusicPillLayout.textWidth,
                        height: PosterMusicPillLayout.textHeight,
                        alignment: .leading
                    )
                }
                Image.ds.icon.plus.filled
                    .iconSize(CGFloat.ds.iconSize._18)
                    .foregroundStyle(Color.ds.text.neutral.primary)
            }
            .padding(.leading, PosterMusicPillLayout.leadingPadding)
            .padding(.trailing, CGFloat.ds.spacing.lg)
            .padding(.vertical, PosterMusicPillLayout.verticalPadding)
            .background(Capsule().fill(Color.ds.overlay.gray.deep))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(music.map { "배경음악 \($0.title)" } ?? "추천 배경음악 고르기")
    }
}

/// 앨범 그림. 주소가 없거나 읽지 못하면 음표 아이콘을 그린다. `isBordered` 면 흰 테두리를 두른다(배경음악 시트).
struct PosterAlbumArt: View {
    let url: URL?
    let size: CGFloat
    var isBordered = false

    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image.resizable().scaledToFill()
            } else {
                Image.ds.icon.music.filled
                    .iconSize(size / 2)
                    .foregroundStyle(Color.ds.text.neutral.subtle)
                    .frame(width: size, height: size)
                    .background(Color.ds.fill.neutral.muted)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius._4))
        .overlay {
            if isBordered {
                RoundedRectangle(cornerRadius: CGFloat.ds.radius._4)
                    .stroke(Color.ds.text.neutral.primary, lineWidth: CGFloat.ds.border.thin)
            }
        }
    }
}

private enum PosterMusicPillLayout {
    static let artSize: CGFloat = 26
    /// 제목·「추천 배경음악」 칸. 시안 bgm `2973:29857` 은 너비 100 고정이다
    static let textWidth: CGFloat = 100
    static let textHeight: CGFloat = 36
    static let textToPlus: CGFloat = 10
    static let leadingPadding: CGFloat = 18
    static let verticalPadding: CGFloat = 6
    /// 「추천 배경음악」 Regular 10/18 −1%. 시안 `2973:29854`
    static let captionStyle = TextStyle.ds.pretendard(.regular, size: 10, lineHeight: 18, letterSpacingEm: -0.01)
}
