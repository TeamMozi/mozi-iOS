import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

/// 아래 버튼. 승인 대기는 꺼진 「신청완료」, 신청 전은 「신청하기」 다.
struct MeetingDetailBottomArea: View {
    let store: StoreOf<MeetingDetailFeature>

    var body: some View {
        if store.perspective == .pending {
            pendingArea
        } else {
            applyArea
        }
    }

    private var pendingArea: some View {
        BottomButtonArea(showsTopBorder: true) {
            HStack(spacing: CGFloat.ds.spacing.xs) {
                DesignText(
                    "이 모임에 참여 신청했어요",
                    style: TextStyle.ds.caption1.regular,
                    color: Color.ds.text.neutral.tertiary,
                    lineLimit: 1
                )
                Button("확인하기", icon: Image.ds.icon.arrows.rightUp) {}
                    .buttonStyle(.textButton(.accent))
            }
            .frame(maxWidth: .infinity)
        } buttons: {
            Button {} label: {
                Text("신청완료")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.main)
            .controlSize(.large)
            .disabled(true)
        }
    }

    private var applyArea: some View {
        BottomButtonArea(showsTopBorder: true) {
            if let count = store.meeting?.recentApplicantCount, count > 0 {
                // 두 굵기가 섞여 `DesignText` 대신 `Text` 를 쓰고, 줄 상자를 `DesignText` 처럼 줄 높이(18)에 맞춘다.
                Text(recentApplicants(count))
                    .kerning(TextStyle.ds.caption1.regular.letterSpacing)
                    .foregroundStyle(Color.ds.text.accent.default)
                    .lineLimit(1)
                    .padding(.vertical, TextStyle.ds.caption1.regular.lineBoxVerticalPadding)
                    .frame(maxWidth: .infinity)
            }
        } buttons: {
            Button {
                store.send(.joinTapped)
            } label: {
                Text("신청하기")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.main)
            .controlSize(.large)
            .disabled(store.isRequesting)
        }
    }

    /// 「최근 일주일동안 8명이 신청했어요」 에서 「8명」 만 굵게 둔다.
    private func recentApplicants(_ count: Int) -> AttributedString {
        var text = AttributedString(MeetingDisplayFormat.recentApplicants(count))
        text.font = TextStyle.ds.caption1.regular.font
        if let range = text.range(of: "\(count)명") {
            text[range].font = TextStyle.ds.caption1.medium.font
        }
        return text
    }
}
