import MoziDemoKit
import SharedDesignSystem
import SwiftUI

/// 전체 화면 견본 하나. 모두 왼쪽 위 닫기 버튼으로 「헤더·탭바」 화면에 돌아간다.
struct FrameSampleScreen: View {
    let sample: FrameSample
    let onClose: () -> Void

    var body: some View {
        switch sample {
        case .header:
            HeaderSampleScreen(onClose: onClose)
        case .tabBar:
            TabBarSampleScreen(onClose: onClose)
        case .bottomSheet:
            BottomSheetSampleScreen(onClose: onClose)
        }
    }
}

/// 툴바 아이콘 버튼. 시스템이 44pt 유리 원을 그리고, 안에 디자인 시스템 아이콘 24 를 놓는다.
struct FrameSampleIconButton: View {
    let image: Image
    let label: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            DesignToolbarIcon(image)
        }
        .accessibilityLabel(label)
    }
}

/// 견본 안 목록 줄. 누르면 다음 화면이나 시트를 연다.
struct FrameSampleRow: View {
    let title: String

    var body: some View {
        DemoRow {
            DesignText(title, style: TextStyle.ds.body.semiBold)
        } trailing: {
            DemoChevron()
        }
        .background(
            Color.ds.fill.neutral.subtle,
            in: RoundedRectangle(cornerRadius: CGFloat.ds.radius._12, style: .continuous)
        )
    }
}

/// 헤더 뒤로 지나가는 본문. 스크롤하면 투명 헤더의 가장자리 효과와 채움 헤더의 바탕이 보인다.
struct FrameSampleScrollContent: View {
    var body: some View {
        ScrollView {
            VStack(spacing: CGFloat.ds.spacing.md) {
                ForEach(1...FrameSampleLayout.rowCount, id: \.self) { index in
                    DesignText("본문 \(index)", style: TextStyle.ds.body.medium)
                        .frame(maxWidth: .infinity, minHeight: FrameSampleLayout.rowHeight)
                        .background(
                            index.isMultiple(of: 2) ? Color.ds.fill.neutral.raised : Color.ds.fill.neutral.strong,
                            in: RoundedRectangle(cornerRadius: CGFloat.ds.radius._12, style: .continuous)
                        )
                }
            }
            .padding(.horizontal, CGFloat.ds.layout.margin)
        }
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
    }
}

private enum FrameSampleLayout {
    static let rowCount = 20
    static let rowHeight: CGFloat = 80
}
