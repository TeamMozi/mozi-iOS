import MoziDemoKit
import SharedDesignSystem
import SwiftUI

/// 헤더·탭바 화면. 하단 버튼 영역 다섯 모양을 바로 보이고, 헤더·탭바·바텀시트는 전체 화면 견본으로 연다.
struct FramePartsGalleryView: View {
    var body: some View {
        GalleryPage(.frameParts) {
            FramePartsGalleryContent()
        }
    }
}

/// `GalleryPage` 의 모드 전환이 고른 모드를 읽으려고 내용을 따로 둔다. 전체 화면 견본은 그 모드로 뜬다.
private struct FramePartsGalleryContent: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var openedSample: FrameSample?

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xxl) {
            GallerySection("Bottom Button Area") {
                VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xl) {
                    ForEach(BottomButtonAreaSample.allCases) { sample in
                        VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
                            DesignText(
                                sample.title,
                                style: TextStyle.ds.caption1.medium,
                                color: Color.ds.text.neutral.secondary
                            )
                            // 모음 화면 좌우 여백을 넘어 화면 폭 전체로 보인다.
                            BottomButtonAreaSampleView(sample: sample)
                                .padding(.horizontal, -CGFloat.ds.layout.margin)
                        }
                    }
                }
            }
            GallerySection("전체 화면 견본") {
                ForEach(FrameSample.allCases) { sample in
                    Button {
                        openedSample = sample
                    } label: {
                        Text(sample.title)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.neutral)
                    .controlSize(.large)
                }
            }
        }
        .fullScreenCover(item: $openedSample) { sample in
            FrameSampleScreen(sample: sample) {
                openedSample = nil
            }
            .preferredColorScheme(colorScheme)
        }
    }
}

/// 하단 버튼 영역 견본 한 칸. 버튼은 지금 있는 `DesignButton` 으로 채운다.
private struct BottomButtonAreaSampleView: View {
    let sample: BottomButtonAreaSample

    var body: some View {
        switch sample {
        case .singleBasic:
            BottomButtonArea(sample.arrangement, showsTopBorder: sample.showsTopBorder) {
                mainButton("신청하기")
            }
        case .split5To5:
            BottomButtonArea(sample.arrangement, showsTopBorder: sample.showsTopBorder) {
                subButton("이전")
                mainButton("다음")
            }
        case .split3To7:
            BottomButtonArea(sample.arrangement, showsTopBorder: sample.showsTopBorder) {
                subButton("취소")
                mainButton("신청하기")
            }
        case .singleCaption:
            BottomButtonArea(sample.arrangement, showsTopBorder: sample.showsTopBorder) {
                recentApplicantsCaption
            } buttons: {
                mainButton("신청하기")
            }
        case .singleLink:
            BottomButtonArea(sample.arrangement, showsTopBorder: sample.showsTopBorder) {
                appliedLinkCaption
            } buttons: {
                subButton("신청 취소하기")
            }
        }
    }

    private func mainButton(_ title: String) -> some View {
        Button {} label: {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.main)
        .controlSize(.large)
    }

    private func subButton(_ title: String) -> some View {
        Button {} label: {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.neutral)
        .controlSize(.large)
    }

    // Figma: `text/accent/default`, Caption Regular 14 에 「8명」 만 Medium.
    private var recentApplicantsCaption: some View {
        let style = TextStyle.ds.caption1.regular
        let count = Text("8명").font(TextStyle.ds.caption1.medium.font)
        return Text("최근 일주일동안 \(count)이 신청했어요")
            .font(style.font)
            .kerning(style.letterSpacing)
            .foregroundStyle(Color.ds.text.accent.default)
            .lineLimit(1)
    }

    // Figma: `text/neutral/tertiary` 글 + 글자 버튼 「확인하기 ↗」. 글자 버튼은 버튼 작업 몫이라 모양만 흉내 낸다.
    private var appliedLinkCaption: some View {
        HStack(spacing: CGFloat.ds.spacing.xs) {
            DesignText(
                "이 모임에 참여 신청했어요",
                style: TextStyle.ds.caption1.regular,
                color: Color.ds.text.neutral.tertiary,
                lineLimit: 1
            )
            Button {} label: {
                HStack(spacing: CGFloat.ds.spacing.xs) {
                    DesignText("확인하기", style: TextStyle.ds.caption1.medium, lineLimit: 1)
                    Image.ds.icon.arrows.rightUp
                        .iconSize(CGFloat.ds.iconSize._14)
                        .foregroundStyle(Color.ds.text.neutral.primary)
                }
            }
            .buttonStyle(.plain)
        }
    }
}
