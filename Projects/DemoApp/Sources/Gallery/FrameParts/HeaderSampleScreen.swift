import MoziDemoKit
import SharedDesignSystem
import SwiftUI

/// 헤더 견본. 변형을 고르면 그 헤더를 단 화면이 쌓이고, 시스템 뒤로 가기(그림 `chevron.left`)로 돌아온다.
struct HeaderSampleScreen: View {
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CGFloat.ds.spacing.md) {
                    ForEach(HeaderSample.allCases) { sample in
                        NavigationLink(value: sample) {
                            FrameSampleRow(title: sample.title)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(CGFloat.ds.layout.margin)
            }
            .background(Color.ds.fill.neutral.default.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    FrameSampleIconButton(image: Image.ds.icon.close.outlined, label: "닫기", action: onClose)
                }
                ToolbarItem(placement: .principal) {
                    DesignToolbarTitle("헤더")
                }
            }
            .navigationDestination(for: HeaderSample.self) { sample in
                HeaderVariantScreen(sample: sample)
            }
        }
    }
}

/// 변형 하나를 단 화면. 왼쪽은 시스템 뒤로 가기 버튼이다.
private struct HeaderVariantScreen: View {
    let sample: HeaderSample

    var body: some View {
        switch sample {
        case .transparent, .filled:
            content.toolbar {
                ToolbarItem(placement: .principal) { DesignToolbarTitle("타이틀") }
                ToolbarItem(placement: .topBarTrailing) { moreButton }
            }
        case .textButton:
            content.toolbar {
                ToolbarItem(placement: .principal) { DesignToolbarTitle("타이틀") }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: { DesignToolbarTitle("편집") }
                }
            }
        case .twoTrailingButtons:
            content.toolbar {
                ToolbarItem(placement: .principal) { DesignToolbarTitle("타이틀") }
                ToolbarItem(placement: .topBarTrailing) { bellButton }
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
                ToolbarItem(placement: .topBarTrailing) { moreButton }
            }
        case .leadingTitle:
            content.toolbar {
                ToolbarItem(placement: .topBarLeading) { DesignToolbarTitle("타이틀").fixedSize() }
                    .sharedBackgroundVisibility(.hidden)
                ToolbarItem(placement: .topBarTrailing) { bellButton }
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
                ToolbarItem(placement: .topBarTrailing) { moreButton }
            }
        }
    }

    private var content: some View {
        FrameSampleScrollContent()
            .navigationBarTitleDisplayMode(.inline)
            .designHeaderBackground(sample.background)
    }

    private var bellButton: some View {
        FrameSampleIconButton(image: Image.ds.icon.bell.outlined, label: "알림")
    }

    private var moreButton: some View {
        FrameSampleIconButton(image: Image.ds.icon.moreHorizontal.outlined, label: "더 보기")
    }
}
