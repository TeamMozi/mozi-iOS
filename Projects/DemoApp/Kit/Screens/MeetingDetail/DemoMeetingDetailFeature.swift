import Feature
import ThirdParty

/// 모임 상세 흐름을 데모 화면에 얹는 층. 흐름이 닫기나 모임 삭제를 올리면 데모 화면을 나간다.
@Reducer
public struct DemoMeetingDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var flow: MeetingDetailFlowFeature.State
        public var isFinished = false

        public init(flow: MeetingDetailFlowFeature.State) {
            self.flow = flow
        }
    }

    public enum Action: Equatable {
        case flow(MeetingDetailFlowFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.flow, action: \.flow) {
            MeetingDetailFlowFeature()
        }
        Reduce { state, action in
            switch action {
            case .flow(.delegate(.dismissRequested)), .flow(.delegate(.meetingDeleted)):
                state.isFinished = true
            case .flow:
                break
            }
            return .none
        }
    }
}
