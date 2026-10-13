import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty
import UIKit

public struct PosterView: View {
    @Bindable public var store: StoreOf<PosterFeature>

    public init(store: StoreOf<PosterFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: PosterLayout.cardToToolBar) {
            posterCard
            PosterToolBar {
                store.send(.musicTapped)
            }
        }
        .padding(.top, PosterLayout.headerToCard)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                DesignToolbarTitle("모임 포스터")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.nextTapped)
                } label: {
                    DesignToolbarIcon(Image.ds.icon.arrows.right, isProminent: true)
                }
                .designToolbarProminent()
                .disabled(store.isSubmitting)
                .accessibilityLabel("다음")
            }
        }
        .designSheet(isPresented: $store.isPhotoSheetPresented) {
            PosterPhotoSheet(store: store)
        }
        .designSheet(isPresented: $store.isMusicSheetPresented, detents: [.height(PosterLayout.musicSheetHeight)]) {
            PosterMusicSheet(store: store)
        }
        .screenStatus(store.screen) {
            store.send(.failureDismissed)
        }
    }

    private var posterCard: some View {
        Button {
            store.send(.photoAreaTapped)
        } label: {
            Color.ds.fill.neutral.subtle
                .aspectRatio(3 / 4, contentMode: .fit)
                .overlay {
                    posterImage
                }
                .clipShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius._12))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("사진 불러오기")
        .overlay(alignment: .top) {
            PosterMusicPill(music: store.selection.music) {
                store.send(.musicTapped)
            }
            .padding(.top, PosterLayout.musicPillTop)
        }
    }

    @ViewBuilder
    private var posterImage: some View {
        switch store.selection.image {
        case .empty:
            DesignText("사진 불러오기", style: TextStyle.ds.headline.semiBold, alignment: .center)
        case let .previous(url):
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ProgressView()
            }
        case let .picked(_, data):
            if let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill()
            }
        }
    }
}

private enum PosterLayout {
    /// 헤더 아래 끝에서 포스터 위 끝까지
    static let headerToCard: CGFloat = 30
    /// 포스터 아래 끝에서 도구 줄까지
    static let cardToToolBar: CGFloat = 46
    /// 포스터 위 끝에서 배경음악 알약까지
    static let musicPillTop: CGFloat = 15
    /// 배경음악 시트 높이. 시안 `2891:161680` 의 시트 몸통
    static let musicSheetHeight: CGFloat = 658
}
