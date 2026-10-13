import SharedDesignSystem
import SwiftUI
import ThirdParty
import UIKit

/// 사진 시트. 「기본」 은 단색 3:4 견본, 「내 사진」 은 사진 보관함 최근 사진이다. 한 장만 고른다.
struct PosterPhotoSheet: View {
    @Bindable var store: StoreOf<PosterFeature>
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: PosterPhotoSheetLayout.tabsToGrid) {
            HStack(spacing: PosterPhotoSheetLayout.tabSpacing) {
                tabButton("기본", tab: .basic)
                tabButton("내 사진", tab: .library)
            }
            ScrollView {
                switch store.photoTab {
                case .basic:
                    basicGrid
                case .library:
                    libraryContent
                }
            }
        }
        .padding(.horizontal, CGFloat.ds.layout.margin)
        .padding(.top, PosterPhotoSheetLayout.topPadding)
    }

    @ViewBuilder
    private func tabButton(_ title: String, tab: PosterFeature.PhotoTab) -> some View {
        if store.photoTab == tab {
            Button(title) {
                store.send(.photoTabSelected(tab))
            }
            .buttonStyle(.pill)
            .accessibilityAddTraits(.isSelected)
        } else {
            Button {
                store.send(.photoTabSelected(tab))
            } label: {
                DesignText(title, style: TextStyle.ds.subtext.medium, color: Color.ds.text.neutral.subtle)
                    .padding(.horizontal, CGFloat.ds.spacing.md)
                    .frame(height: PosterPhotoSheetLayout.tabHeight)
            }
            .buttonStyle(.plain)
        }
    }

    private var basicGrid: some View {
        PosterPhotoGrid(count: PosterSwatch.count) { index in
            Button {
                store.send(.swatchTapped(index))
            } label: {
                PosterSwatch.color(at: index)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("기본 견본 \(index + 1)")
        }
    }

    @ViewBuilder
    private var libraryContent: some View {
        switch store.photoAccess {
        case .denied:
            // 거부 안내 모양은 디자이너 요청 목록에 있다. 임시 모양이다
            VStack(spacing: CGFloat.ds.spacing.md) {
                DesignText(
                    "사진 보관함 접근을 허용하면 내 사진을 고를 수 있어요",
                    style: TextStyle.ds.body.medium,
                    color: Color.ds.text.neutral.secondary,
                    alignment: .center
                )
                Button("설정 열기") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                .buttonStyle(.neutral)
                .controlSize(.small)
            }
            .padding(.top, CGFloat.ds.spacing.xxl)
        case .authorized, .limited:
            PosterPhotoGrid(count: store.photos.count) { index in
                photoButton(store.photos[index])
            }
        case nil:
            ProgressView()
                .padding(.top, CGFloat.ds.spacing.xxl)
        }
    }

    private func photoButton(_ item: PhotoLibraryItem) -> some View {
        Button {
            store.send(.photoTapped(item.id))
        } label: {
            if let image = UIImage(data: item.thumbnail) {
                Image(uiImage: image).resizable().scaledToFill()
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("사진")
    }
}

private enum PosterPhotoSheetLayout {
    /// 시트 위 끝에서 탭 줄까지. 시안 `2867:160969` 은 손잡이 아래 20, 시트 위 끝에서 32 다
    static let topPadding = CGFloat.ds.spacing.xxl
    static let tabSpacing: CGFloat = 6
    /// 고르지 않은 탭 높이. 고른 탭(알약 글자)과 같다
    static let tabHeight: CGFloat = 32
    static let tabsToGrid: CGFloat = 20
}
