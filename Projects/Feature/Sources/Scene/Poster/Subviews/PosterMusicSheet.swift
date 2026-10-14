import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

/// 배경음악 시트. 「인기」 곡 목록에서 하나를 고르고 ✓ 로 정한다. ▶ 는 그리기만 하고 재생하지 않는다.
/// 「직접 추가」 탭은 흐리게 둔다.
struct PosterMusicSheet: View {
    @Bindable var store: StoreOf<PosterFeature>

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PosterMusicSheetLayout.nowPlayingToTabs) {
                    if let music = store.pendingMusic {
                        nowPlaying(music)
                    }
                    VStack(spacing: CGFloat.ds.spacing.sm) {
                        HStack(spacing: PosterMusicSheetLayout.tabSpacing) {
                            Button("인기") {}
                                .buttonStyle(.pill)
                                .accessibilityAddTraits(.isSelected)
                            DesignText(
                                "직접 추가",
                                style: TextStyle.ds.subtext.medium,
                                color: Color.ds.text.neutral.faint
                            )
                            .padding(.horizontal, CGFloat.ds.spacing.md)
                        }
                        LazyVStack(spacing: 0) {
                            ForEach(store.musics, id: \.id) { music in
                                musicRow(music)
                            }
                        }
                    }
                }
                // 시안은 지금 곡 그림이 헤더 버튼 줄 사이(시트 위 끝에서 44)에 걸친다. 시스템 헤더 아래에 바로 붙인다
                .padding(.bottom, PosterMusicSheetLayout.bottomPadding)
            }
            .background(Color.ds.fill.neutral.default.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        store.send(.musicSheetClosed)
                    } label: {
                        DesignToolbarIcon(Image.ds.icon.close.outlined)
                    }
                    .accessibilityLabel("닫기")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.musicConfirmed)
                    } label: {
                        DesignToolbarIcon(Image.ds.icon.check.outlined, isProminent: true)
                    }
                    .designToolbarProminent()
                    .accessibilityLabel("고르기")
                }
            }
        }
    }

    private func nowPlaying(_ music: BackgroundMusic) -> some View {
        VStack(spacing: PosterMusicSheetLayout.artToTitle) {
            PosterAlbumArt(url: music.albumImageURL, size: PosterMusicSheetLayout.headerArtSize, isBordered: true)
            HStack(spacing: PosterMusicSheetLayout.playToTitle) {
                Image.ds.icon.playCircle.filled
                    .iconSize(CGFloat.ds.iconSize._28)
                    .foregroundStyle(Color.ds.text.neutral.secondary)
                    .accessibilityHidden(true)
                DesignText(
                    music.title,
                    style: TextStyle.ds.headline.semiBold,
                    color: Color.ds.text.neutral.secondary,
                    lineLimit: 1
                )
                .frame(maxWidth: PosterMusicSheetLayout.titleMaxWidth)
            }
        }
        .padding(.horizontal, CGFloat.ds.layout.margin)
    }

    private func musicRow(_ music: BackgroundMusic) -> some View {
        Button {
            store.send(.musicRowTapped(music.id))
        } label: {
            DesignListRow(
                music.title,
                subtitle: PosterMusicFormat.subtitle(music),
                isSelected: store.pendingMusic?.id == music.id,
                style: .music
            ) {
                PosterAlbumArt(url: music.albumImageURL, size: PosterMusicSheetLayout.rowArtSize, isBordered: true)
            }
        }
        .buttonStyle(.plain)
    }
}

/// 곡 줄 보조 글. 「1:39 · 110회 사용」
enum PosterMusicFormat {
    static func subtitle(_ music: BackgroundMusic) -> String {
        let minutes = music.durationSeconds / 60
        let seconds = String(format: "%02d", music.durationSeconds % 60)
        return "\(minutes):\(seconds) · \(music.useCount)회 사용"
    }
}

private enum PosterMusicSheetLayout {
    static let headerArtSize: CGFloat = 44
    static let rowArtSize: CGFloat = 40
    /// 목록 끝에서 시트 아래까지
    static let bottomPadding: CGFloat = 44
    static let artToTitle: CGFloat = 14
    static let playToTitle: CGFloat = 2
    static let titleMaxWidth: CGFloat = 200
    static let nowPlayingToTabs: CGFloat = 20
    static let tabSpacing: CGFloat = 6
}
