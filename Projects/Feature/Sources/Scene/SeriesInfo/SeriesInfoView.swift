import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct SeriesInfoView: View {
    @Bindable public var store: StoreOf<SeriesInfoFeature>
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<SeriesInfoFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: SeriesInfoLayout.sectionSpacing) {
                // 시안 `2238:127709`·`2238:127503`: 둥근 바탕까지 든 그림이라 바탕을 따로 그리지 않는다
                Image.ds.illustration.seriesInfo
                    .resizable()
                    .frame(
                        width: SeriesInfoLayout.illustrationSize.width,
                        height: SeriesInfoLayout.illustrationSize.height
                    )
                // 시안 Name 줄: 둘레 8, 14/400/20 `text/neutral/subtle`
                DesignText(
                    "모임을 앵콜해 하나의 시리즈로 연결해요",
                    style: TextStyle.ds.subtext.regular,
                    color: Color.ds.text.neutral.subtle
                )
                .padding(CGFloat.ds.spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                inputCard
            }
            .padding(.horizontal, CGFloat.ds.layout.margin)
            // 시안은 머리 줄(72) 바로 아래 0 이다. 시스템 툴바가 시안 머리보다 낮아 16 을 둬 그림 위 끝을 맞춘다
            .padding(.top, CGFloat.ds.spacing.lg)
            .padding(.bottom, SeriesInfoLayout.bottomInset)
        }
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                // 쌓인 화면이라 이 화면만 닫고 포스터로 돌아간다
                Button {
                    dismiss()
                } label: {
                    DesignToolbarIcon(Image.ds.icon.close.outlined)
                }
                .disabled(store.isSubmitting)
                .accessibilityLabel("닫기")
            }
            ToolbarItem(placement: .principal) {
                DesignToolbarTitle("시리즈 정보")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.nextTapped)
                } label: {
                    DesignToolbarIcon(Image.ds.icon.arrows.right, isProminent: true)
                }
                .designToolbarProminent()
                .disabled(!store.canProceed)
                .accessibilityLabel("다음")
            }
        }
        .screenStatus(store.screen) {
            store.send(.failureDismissed)
        }
    }

    /// 시안 Form Group: 시리즈명 줄(54)·구분선·시리즈 소개 줄(116).
    private var inputCard: some View {
        DesignFormGroup {
            DesignTextField(
                text: $store.title,
                placeholder: "시리즈명",
                maxLength: SeriesLimit.titleMaxLength,
                style: .row(text: SeriesInfoLayout.titleText)
            )
            .overlay(alignment: .bottom) {
                DesignFormRowSeparator()
            }
            DesignTextArea(
                text: $store.intro,
                placeholder: "시리즈 소개",
                maxLength: SeriesLimit.introMaxLength,
                style: .row(height: SeriesInfoLayout.introHeight, showsCounter: false)
            )
        }
    }
}

private enum SeriesInfoLayout {
    /// 시안 본문 칸 사이 간격(그림·안내 줄·입력 칸).
    static let sectionSpacing: CGFloat = 10
    /// 시안 본문 아래 여백.
    static let bottomInset: CGFloat = 60
    /// 시안 설명 그림 크기.
    static let illustrationSize = CGSize(width: 342, height: 397)
    /// 시안 Row text 의 소개 줄: 위아래 10 + 글자 영역 96.
    static let introHeight: CGFloat = 116
    /// 시안 Row text 의 입력 글자: Pretendard SemiBold 20/28, 자간 −2%, `text/neutral/primary`.
    /// placeholder 는 시안도 Body/Regular·`text/neutral/subtle` 이라 기본값 그대로 둔다.
    static let titleText = DesignRowText(
        textStyle: TextStyle.ds.pretendard(.semiBold, size: 20, lineHeight: 28, letterSpacingEm: -0.02),
        textColor: Color.ds.text.neutral.primary
    )
}
