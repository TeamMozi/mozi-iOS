import Foundation
import SharedDesignSystem
import ThirdParty

/// 앵콜(2회차)일 때 포스터 다음에 쌓는 「시리즈 정보」. 시리즈명은 꼭 넣는다.
/// 만들기 요청은 모임 만들기 흐름이 보내고, 요청 중 표시와 실패 창은 흐름이 이 화면 상태에 넣는다.
@Reducer
public struct SeriesInfoFeature {
    @ObservableState
    public struct State: Equatable {
        public var title: String
        public var intro: String
        public var isSubmitting: Bool
        public var screen: ScreenStatus

        public init(
            title: String = "",
            intro: String = "",
            isSubmitting: Bool = false,
            screen: ScreenStatus = .idle
        ) {
            self.title = title
            self.intro = intro
            self.isSubmitting = isSubmitting
            self.screen = screen
        }

        public var canProceed: Bool {
            !trimmedTitle.isEmpty && !isSubmitting
        }

        var trimmedTitle: String {
            title.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case nextTapped
        case failureDismissed
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// 시리즈명과 소개. 소개가 비면 nil 이다
            case nextRequested(title: String, intro: String?)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        CombineReducers {
            BindingReducer()
            Reduce { state, action in
                switch action {
                case .nextTapped:
                    guard state.canProceed else { return .none }
                    let intro = state.intro.trimmingCharacters(in: .whitespacesAndNewlines)
                    return .send(.delegate(.nextRequested(
                        title: state.trimmedTitle,
                        intro: intro.isEmpty ? nil : intro
                    )))
                case .failureDismissed:
                    state.screen = .idle
                    return .none
                case .binding, .delegate:
                    return .none
                }
            }
        }
        .logged(as: Self.self, children: [])
    }
}
