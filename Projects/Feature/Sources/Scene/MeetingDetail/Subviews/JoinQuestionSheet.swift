import SharedDesignSystem
import SwiftUI
import ThirdParty

/// 가입 질문 시트. 질문마다 답을 받고, 모든 답이 차야 「신청하기」 가 눌린다.
/// 시트 높이는 내용에 맞춘다. 헤더·질문 묶음·하단 버튼 영역 높이를 재어 합을 `onFittingHeightChange` 로 올린다.
struct JoinQuestionSheet: View {
    let store: StoreOf<MeetingDetailFeature>
    var onFittingHeightChange: (CGFloat) -> Void = { _ in }

    @State private var headerHeight: CGFloat = 0
    @State private var questionsHeight: CGFloat = 0
    @State private var bottomAreaHeight: CGFloat = 0

    var body: some View {
        NavigationStack {
            questions
                // 공용 `.bottomButtonArea` 는 영역을 키보드 뒤에 남긴다. 시트는 키보드 위로 올라가므로
                // 버튼이 키보드에 가리지 않게 영역을 키보드를 따르는 아래 안쪽 여백으로 붙인다.
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    bottomArea
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.height
                        } action: { height in
                            bottomAreaHeight = height
                        }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        DesignToolbarTitle("가입 질문")
                            .fixedSize()
                    }
                    .sharedBackgroundVisibility(.hidden)
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            store.send(.joinSheetDismissed)
                        } label: {
                            DesignToolbarIcon(Image.ds.icon.close.outlined)
                        }
                        .accessibilityLabel("닫기")
                    }
                }
        }
        .onChange(of: fittingHeight, initial: true) { _, height in
            guard height > 0 else { return }
            onFittingHeightChange(height)
        }
    }

    /// 시트 높이(아래 안전 영역 제외). 키보드와 상관없는 높이만 더한다.
    private var fittingHeight: CGFloat {
        JoinQuestionSheetLayout.fittingHeight(
            header: headerHeight,
            questions: questionsHeight,
            bottomArea: bottomAreaHeight
        )
    }

    private var bottomArea: some View {
        BottomButtonArea {
            Button {
                store.send(.joinSubmitTapped)
            } label: {
                Text("신청하기")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.main)
            .controlSize(.large)
            .disabled(!store.canSubmitJoin)
        }
    }

    private var questions: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JoinQuestionSheetLayout.questionSpacing) {
                let questions = store.meeting?.joinQuestions ?? []
                ForEach(Array(questions.enumerated()), id: \.offset) { index, question in
                    VStack(alignment: .leading, spacing: JoinQuestionSheetLayout.labelSpacing) {
                        DesignText(question, style: TextStyle.ds.headline.medium)
                        DesignTextField(
                            text: answer(at: index),
                            placeholder: "답변을 입력해주세요",
                            maxLength: .max
                        )
                    }
                }
            }
            .padding(.horizontal, CGFloat.ds.layout.margin)
            .padding(.bottom, JoinQuestionSheetLayout.questionsToBottomArea)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                questionsHeight = height
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        // 위 안전 영역이 헤더 높이다. 아래 안전 영역은 키보드에 따라 바뀌므로 읽지 않는다.
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.safeAreaInsets.top
        } action: { height in
            headerHeight = height
        }
    }

    private func answer(at index: Int) -> Binding<String> {
        Binding(
            get: {
                guard let answers = store.joinAnswers, answers.indices.contains(index) else { return "" }
                return answers[index]
            },
            set: { store.send(.joinAnswerChanged(index: index, text: $0)) }
        )
    }
}

enum JoinQuestionSheetLayout {
    static let questionSpacing: CGFloat = 28
    static let labelSpacing: CGFloat = 10
    /// 마지막 질문과 하단 버튼 영역 사이. 시안 `2798:100140` 은 질문 묶음 끝(150)과 영역 위 끝(170) 사이가 20 이다.
    static let questionsToBottomArea: CGFloat = 20

    /// 내용에 맞춘 시트 높이. 셋 중 하나라도 아직 재지 않았으면 0 이다. 시스템 시트 높이(`.height`)는 아래 안전 영역을 빼고 재므로 그것을 더하지 않는다.
    /// 화면보다 크면 시스템이 줄이고, 질문 묶음은 스크롤된다.
    static func fittingHeight(header: CGFloat, questions: CGFloat, bottomArea: CGFloat) -> CGFloat {
        guard header > 0, questions > 0, bottomArea > 0 else { return 0 }
        return (header + questions + bottomArea).rounded(.up)
    }
}
