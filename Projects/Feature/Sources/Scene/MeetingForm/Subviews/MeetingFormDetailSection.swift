import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

/// 「상세 정보」(모임 정보) 칸. 칩을 누르면 커서 자리에 머리말 한 줄을 넣는다.
struct MeetingFormDetailSection: View {
    @Bindable var store: StoreOf<MeetingFormFeature>

    var body: some View {
        // 시안 Form Group: 제목 줄(54) · 칩 줄(위 4·좌우 16·아래 16, 아래 끝 구분선) · 입력 줄(304)
        DesignFormGroup {
            MeetingFormRow("상세 정보", value: nil)
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
                HStack(spacing: CGFloat.ds.spacing.sm) {
                    ForEach(Array(MeetingDetailHeading.allCases.prefix(4)), id: \.self) { heading in
                        headingChip(heading)
                    }
                }
                HStack(spacing: CGFloat.ds.spacing.sm) {
                    ForEach(Array(MeetingDetailHeading.allCases.dropFirst(4)), id: \.self) { heading in
                        headingChip(heading)
                    }
                }
            }
            .meetingFormExpandedPadding(top: CGFloat.ds.spacing.xs)
            .overlay(alignment: .bottom) {
                DesignFormRowSeparator()
            }
            DesignTextArea(
                text: $store.detail,
                placeholder: "상세 정보(선택)",
                maxLength: MeetingLimit.detailMaxLength,
                style: .row(height: MeetingFormPartsLayout.detailHeight, showsCounter: true, text: Self.detailText),
                cursor: $store.detailCursor
            )
        }
    }

    /// 시안 `1567:42068` 채운 상세 정보·`1567:41744` 「상세 정보(선택)」: 둘 다 Regular 16/26 −2% `text/neutral/tertiary`.
    private static let detailText: DesignRowText = {
        let style = TextStyle.ds.pretendard(.regular, size: 16, lineHeight: 26, letterSpacingEm: -0.02)
        return DesignRowText(
            textStyle: style,
            textColor: Color.ds.text.neutral.tertiary,
            placeholderStyle: style,
            placeholderColor: Color.ds.text.neutral.tertiary
        )
    }()

    private func headingChip(_ heading: MeetingDetailHeading) -> some View {
        // `isEditing` 을 넘겨야 누르는 칩 생성자가 골라진다(닫기 칩 생성자와 겹친다)
        DesignChip(heading.title, style: .outlined, isEditing: false) {
            store.send(.detailHeadingTapped(heading))
        }
    }
}
