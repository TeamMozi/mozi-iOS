import Domain
import Feature
import SharedDesignSystem
import ThirdParty

/// 데모 「만들기」 층. 탭 묶음 대신 모임 만들기 시트를 띄우고, 올라온 모임을 한 줄로 보인다.
/// 시리즈만 실패하면 탭 묶음처럼 시트를 닫고 안내를 한 번 띄운다.
@Reducer
public struct DemoCreateMeetingFeature {
    @ObservableState
    public struct State: Equatable {
        @Presents public var flow: CreateMeetingFlowFeature.State?
        public var createdMeetingTitle: String?
        public var screen: ScreenStatus

        public init(
            flow: CreateMeetingFlowFeature.State? = CreateMeetingFlowFeature.State(),
            createdMeetingTitle: String? = nil,
            screen: ScreenStatus = .idle
        ) {
            self.flow = flow
            self.createdMeetingTitle = createdMeetingTitle
            self.screen = screen
        }

        /// 「만든 모임 · 홀사이즈 케이크 먹는 모임」
        public var createdLine: String? {
            createdMeetingTitle.map { "만든 모임 · \($0)" }
        }
    }

    public enum Action: Equatable {
        case openTapped
        case flow(PresentationAction<CreateMeetingFlowFeature.Action>)
        case noticeDismissed
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .openTapped:
                state.flow = CreateMeetingFlowFeature.State()
                return .none
            case let .flow(.presented(.delegate(.created(meeting)))):
                state.flow = nil
                state.createdMeetingTitle = meeting.title
                return .none
            case let .flow(.presented(.delegate(.createdWithoutSeries(meeting)))):
                state.flow = nil
                state.createdMeetingTitle = meeting.title
                state.screen = .actionFailed(message: CreateMeetingFlowFeature.seriesFailedNotice)
                return .none
            case .flow(.presented(.delegate(.closed))):
                state.flow = nil
                return .none
            case .noticeDismissed:
                state.screen = .idle
                return .none
            case .flow:
                return .none
            }
        }
        .ifLet(\.$flow, action: \.flow) {
            CreateMeetingFlowFeature()
        }
    }
}
