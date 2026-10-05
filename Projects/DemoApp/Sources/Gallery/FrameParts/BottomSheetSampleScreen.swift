import MoziDemoKit
import SharedDesignSystem
import SwiftUI

/// 바텀시트 견본. 줄을 고르면 시스템 시트 안 `NavigationStack` + 툴바로 그린 바텀시트 헤더가 Figma 딤 위로 뜬다.
struct BottomSheetSampleScreen: View {
    let onClose: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var presented: BottomSheetSample?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CGFloat.ds.spacing.md) {
                    ForEach(BottomSheetSample.allCases) { sample in
                        Button {
                            presented = sample
                        } label: {
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
                    DesignToolbarTitle("바텀시트")
                }
            }
        }
        .designSheet(item: $presented, detents: { [$0.detent] }) { sample in
            BottomSheetSampleContent(sample: sample) {
                presented = nil
            }
            .preferredColorScheme(colorScheme)
        }
    }
}

/// 시트 안 화면. 기본은 가운데 제목, 왼쪽 정렬 제목은 닫기 버튼 옆에 제목을 둔다.
private struct BottomSheetSampleContent: View {
    let sample: BottomSheetSample
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            if sample.isLeadingTitle {
                content.toolbar {
                    ToolbarItem(placement: .topBarLeading) { closeButton }
                    ToolbarItem(placement: .topBarLeading) { DesignToolbarTitle("가입 질문").fixedSize() }
                        .sharedBackgroundVisibility(.hidden)
                    ToolbarItem(placement: .topBarTrailing) { moreButton }
                }
            } else {
                content.toolbar {
                    ToolbarItem(placement: .topBarLeading) { closeButton }
                    ToolbarItem(placement: .principal) { DesignToolbarTitle("모임 만들기") }
                    ToolbarItem(placement: .topBarTrailing) { moreButton }
                }
            }
        }
    }

    private var content: some View {
        FrameSampleScrollContent()
            .navigationBarTitleDisplayMode(.inline)
    }

    private var closeButton: some View {
        FrameSampleIconButton(image: Image.ds.icon.close.outlined, label: "닫기", action: onClose)
    }

    private var moreButton: some View {
        FrameSampleIconButton(image: Image.ds.icon.moreHorizontal.outlined, label: "더 보기")
    }
}
