import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct MeetingFormView: View {
    @Bindable public var store: StoreOf<MeetingFormFeature>

    public init(store: StoreOf<MeetingFormFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: MeetingFormPartsLayout.cardSpacing) {
                previousLine
                categoryCard
                DesignFormGroup {
                    DesignTextField(
                        text: $store.title,
                        placeholder: "모임 이름",
                        maxLength: MeetingLimit.titleMaxLength,
                        style: .row(text: MeetingFormViewLayout.titleText)
                    )
                    .overlay(alignment: .bottom) {
                        DesignFormRowSeparator()
                    }
                    DesignTextArea(
                        text: $store.intro,
                        placeholder: "모임 소개",
                        maxLength: MeetingLimit.introMaxLength,
                        style: .row(height: MeetingFormPartsLayout.introHeight, showsCounter: false)
                    )
                }
                DesignFormGroup {
                    MeetingFormScheduleSection(store: store)
                    MeetingFormConditionSection(store: store)
                }
                MeetingFormDetailSection(store: store)
            }
            .padding(.horizontal, CGFloat.ds.layout.margin)
            // 시안은 머리 줄(72) 바로 아래 0 이다. 시스템 툴바가 시안 머리보다 낮아 16 을 둬 칸 위 끝을 맞춘다
            .padding(.top, CGFloat.ds.spacing.lg)
            .padding(.bottom, MeetingFormPartsLayout.bottomInset)
        }
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    store.send(.closeTapped)
                } label: {
                    DesignToolbarIcon(Image.ds.icon.close.outlined)
                }
                .accessibilityLabel("닫기")
            }
            ToolbarItem(placement: .principal) {
                DesignToolbarTitle("모임 만들기")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.nextTapped)
                } label: {
                    DesignToolbarIcon(Image.ds.icon.arrows.right, isProminent: true)
                }
                .designToolbarProminent()
                .disabled(!store.isComplete)
                .accessibilityLabel("다음")
            }
        }
        .task {
            store.send(.task)
        }
    }

    @ViewBuilder
    private var previousLine: some View {
        if let linked = store.linkedMeeting {
            DesignFormGroup {
                HStack(spacing: CGFloat.ds.spacing.xs) {
                    Image.ds.icon.link.outlined
                        .iconSize(CGFloat.ds.iconSize._28)
                        .foregroundStyle(Color.ds.text.neutral.secondary)
                    DesignText(
                        linked.title,
                        style: TextStyle.ds.body.regular,
                        color: Color.ds.text.neutral.subtle,
                        lineLimit: 1
                    )
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, CGFloat.ds.spacing.lg)
                .frame(height: MeetingFormPartsLayout.rowHeight)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("연결된 모임 \(linked.title)")
        } else if store.hasPreviousMeetings {
            Button {
                store.send(.loadPreviousTapped)
            } label: {
                // 시안 Encore: 높이 32, 좌우 12
                HStack(spacing: CGFloat.ds.spacing.xs) {
                    DesignText(
                        "주최했던 모임을 다시 열어보세요",
                        style: TextStyle.ds.subtext.regular,
                        color: Color.ds.text.neutral.subtle
                    )
                    DesignText(
                        "이전 모임 불러오기",
                        style: TextStyle.ds.caption1.medium,
                        color: Color.ds.button.label.text.accent
                    )
                }
                .padding(.horizontal, CGFloat.ds.spacing.md)
                .frame(maxWidth: .infinity, minHeight: MeetingFormViewLayout.previousLineHeight, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var categoryCard: some View {
        Menu {
            ForEach(store.categories, id: \.id) { category in
                Button {
                    store.send(.categorySelected(category))
                } label: {
                    MeetingFormMenuLabel(title: category.name, isSelected: store.category?.id == category.id)
                }
            }
        } label: {
            DesignFormGroup {
                MeetingFormRow("카테고리", value: store.category?.name)
            }
        }
        .buttonStyle(.plain)
    }
}

private enum MeetingFormViewLayout {
    /// 시안 `1567:42068` 채운 모임 이름: SemiBold 20/600/28 −2% `text/neutral/primary`.
    /// placeholder 는 시안 `1567:41744` 「모임 이름」 16/400/24 −1% `text/neutral/subtle` 로 지금 모양 그대로다.
    static let titleText = DesignRowText(
        textStyle: TextStyle.ds.pretendard(.semiBold, size: 20, lineHeight: 28, letterSpacingEm: -0.02),
        textColor: Color.ds.text.neutral.primary
    )
    /// 시안 Encore 줄 높이(위아래 6 + 글자 20).
    static let previousLineHeight: CGFloat = 32
}
