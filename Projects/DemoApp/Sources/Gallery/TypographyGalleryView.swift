import SharedDesignSystem
import SwiftUI

/// 글자 화면. Figma 묶음 8개 아래에 글자 스타일 21개마다 이름, 수치, 여러 줄 견본을 보인다.
/// 견본 뒤 옅은 가로선은 그 스타일의 줄 높이 간격이라, 실제 줄 간격이 줄 높이와 맞는지 눈으로 본다.
struct TypographyGalleryView: View {
    var body: some View {
        GalleryPage(.typography) {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xxl) {
                ForEach(GalleryCatalog.textGroups) { group in
                    TextSampleGroup(group: group)
                }
            }
        }
    }
}

/// Figma 묶음 하나. 제목 아래에 그 묶음의 스타일을 쌓는다.
private struct TextSampleGroup: View {
    let group: GalleryTextGroup

    var body: some View {
        GallerySection(group.title) {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xl) {
                ForEach(group.samples) { sample in
                    TextSampleRow(sample: sample)
                }
            }
        }
    }
}

private struct TextSampleRow: View {
    let sample: GalleryTextSample

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xs) {
                DesignText(
                    sample.shortName,
                    style: TextStyle.ds.caption1.semiBold,
                    color: Color.ds.text.neutral.secondary
                )
                DesignText(
                    sample.metricsLabel,
                    style: TextStyle.ds.caption2.regular,
                    color: Color.ds.text.neutral.tertiary
                )
            }
            DesignText(GalleryCatalog.sampleText, style: sample.style)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    LineHeightGuides(lineHeight: sample.style.lineHeight)
                }
        }
    }
}

/// 글 상자 맨 위부터 줄 높이마다 긋는 가로선. 배경이라 견본 자리를 바꾸지 않는다.
private struct LineHeightGuides: View {
    let lineHeight: CGFloat

    var body: some View {
        GeometryReader { proxy in
            Path { path in
                guard lineHeight > 0 else { return }
                var y: CGFloat = 0
                while y <= proxy.size.height {
                    path.addRect(CGRect(x: 0, y: y, width: proxy.size.width, height: CGFloat.ds.border.thin))
                    y += lineHeight
                }
            }
            .fill(Color.ds.border.neutral._20)
        }
        .accessibilityHidden(true)
    }
}

#Preview("글자") {
    TypographyGalleryView()
}
