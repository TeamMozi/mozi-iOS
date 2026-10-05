import MoziDemoKit
import SharedDesignSystem
import SwiftUI

/// 화면 상태 화면. 네 상태를 골라 견본 화면 위에 띄우고, 「다시 시도」 를 누른 횟수를 센다.
struct ScreenStatusGalleryView: View {
    @State private var sample: GalleryScreenStatusSample = .idle
    @State private var retryCount = 0

    var body: some View {
        GalleryPage(.screenStatus) {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xxl) {
                GallerySection("상태") {
                    Picker("상태", selection: $sample) {
                        ForEach(GalleryScreenStatusSample.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    DesignText(
                        "다시 시도 누른 횟수 \(retryCount)",
                        style: TextStyle.ds.body.regular,
                        color: Color.ds.text.neutral.secondary
                    )
                }

                GallerySection("견본") {
                    sampleScreen
                        .screenStatus(
                            sample.status,
                            onRetry: { retryCount += 1 },
                            onDismiss: { sample = .idle }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius._12))
                }
            }
        }
    }

    private var sampleScreen: some View {
        DesignText("화면 본문", style: TextStyle.ds.headline.medium)
            .frame(
                maxWidth: .infinity,
                minHeight: ScreenStatusGalleryLayout.sampleHeight,
                maxHeight: ScreenStatusGalleryLayout.sampleHeight
            )
            .background(Color.ds.fill.neutral.surface)
    }
}

private enum ScreenStatusGalleryLayout {
    static let sampleHeight: CGFloat = 240
}

#Preview("화면 상태") {
    ScreenStatusGalleryView()
}
