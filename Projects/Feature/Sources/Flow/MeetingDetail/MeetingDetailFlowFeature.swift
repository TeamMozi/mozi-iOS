import Domain
import Foundation
import ThirdParty

/// 모임 상세 흐름. 모임 상세나 위젯 화면을 첫 화면으로 둔다. 탭에 붙지 않고, 상세로 들어오는 화면이 화면 전체로 덮어 띄운다.
/// 모임 상세에서는 사이드바(모임 관리)를 상세 위에 덮어 띄우고, 멤버 관리·스냅 포인트 설정을 덮개 안에 쌓는다.
/// 위젯에서는 멤버 관리·스냅 포인트 설정을 흐름의 쌓기에 쌓는다.
///
/// 화면을 그리지 않는다. 경로와 자식만 갖고, 한 화면에서 바뀐 모임·멤버·스냅 포인트를 다른 화면에 맞춰 넣는다
@Reducer
public struct MeetingDetailFlowFeature {
    /// 쌓이는 화면. 위젯 위 쌓기(`path`)와 사이드바 덮개 안 쌓기(`managementPath`)가 함께 쓴다
    @Reducer
    public enum Route {
        case memberManagement(MemberManagementFeature)
        case snapPointSetting(SnapPointSettingFeature)
    }

    @ObservableState
    public struct State: Equatable {
        /// 첫 화면이 모임 상세면 있다
        public var detail: MeetingDetailFeature.State?
        /// 첫 화면이 위젯이면 있다
        public var widget: MeetingWidgetFeature.State?
        /// 첫 화면 위 쌓기. 위젯에서 연 멤버 관리·스냅 포인트 설정이 쌓인다
        public var path = StackState<Route.State>()
        /// 상세 위를 덮는 사이드바. 뒤의 상세가 흐리게 비친다
        @Presents public var management: MeetingManagementFeature.State?
        /// 사이드바 덮개 안 쌓기
        public var managementPath = StackState<Route.State>()

        /// 모임 상세로 시작한다
        public init(detailOf meetingID: String) {
            detail = MeetingDetailFeature.State(meetingID: meetingID)
        }

        /// 위젯 화면으로 시작한다. 모임장만 연다
        public init(widgetOf meetingID: String) {
            widget = MeetingWidgetFeature.State(meetingID: meetingID)
        }

        /// 첫 화면이 읽은 모임
        var currentMeeting: Meeting? {
            detail?.meeting ?? widget?.meeting
        }
    }

    public enum Action: Equatable {
        case detail(MeetingDetailFeature.Action)
        case widget(MeetingWidgetFeature.Action)
        case management(PresentationAction<MeetingManagementFeature.Action>)
        case path(StackActionOf<Route>)
        case managementPath(StackActionOf<Route>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// 첫 화면에서 닫았다. 띄운 쪽이 흐름을 내린다
            case dismissRequested
            /// 모임을 지웠다. 띄운 쪽이 흐름을 내리고 목록을 고친다
            case meetingDeleted(meetingID: String)
            case chatRequested(meetingID: String)
            case filmRequested(meetingID: String)
            case seriesRequested(seriesID: String)
            /// 모임 관리의 시안 없는 다섯 칸
            case managementRowRequested(MeetingManagementFeature.Row)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        CombineReducers {
            Reduce(rootDelegates)
            Reduce(managementDelegates)
            Reduce(routeDelegates)
        }
        .ifLet(\.detail, action: \.detail) {
            MeetingDetailFeature()
        }
        .ifLet(\.widget, action: \.widget) {
            MeetingWidgetFeature()
        }
        .ifLet(\.$management, action: \.management) {
            MeetingManagementFeature()
        }
        .forEach(\.managementPath, action: \.managementPath)
        .forEach(\.path, action: \.path)
        .logged(as: Self.self, children: ["detail", "widget", "management"])
    }
}

extension MeetingDetailFlowFeature.Route.State: Equatable {}
extension MeetingDetailFlowFeature.Route.Action: Equatable {}

// MARK: - 첫 화면

extension MeetingDetailFlowFeature {
    private func rootDelegates(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .detail(.delegate(delegate)):
            return handleDetail(delegate, state: &state)
        case let .widget(.delegate(delegate)):
            return handleWidget(delegate, state: &state)
        default:
            return .none
        }
    }

    private func handleDetail(
        _ delegate: MeetingDetailFeature.Action.Delegate,
        state: inout State
    ) -> Effect<Action> {
        switch delegate {
        case .closeRequested:
            return .send(.delegate(.dismissRequested))
        case .managementRequested:
            guard let detail = state.detail, let meeting = detail.meeting else { return .none }
            state.managementPath.removeAll()
            let snapPointCount = detail.snapPoints.count
            state.management = MeetingManagementFeature.State(meeting: meeting, snapPointCount: snapPointCount)
            return .none
        case let .chatRequested(meetingID):
            return .send(.delegate(.chatRequested(meetingID: meetingID)))
        case let .filmRequested(meetingID):
            return .send(.delegate(.filmRequested(meetingID: meetingID)))
        case let .seriesRequested(seriesID):
            return .send(.delegate(.seriesRequested(seriesID: seriesID)))
        }
    }

    private func handleWidget(
        _ delegate: MeetingWidgetFeature.Action.Delegate,
        state: inout State
    ) -> Effect<Action> {
        switch delegate {
        case .closeRequested:
            return .send(.delegate(.dismissRequested))
        case .memberManagementRequested:
            pushMemberManagement(onto: \.path, state: &state)
        case .snapPointSettingRequested:
            pushSnapPointSetting(onto: \.path, state: &state)
        case let .meetingChanged(meeting):
            syncMeeting(meeting, state: &state)
        case let .snapPointsChanged(snapPoints):
            syncSnapPoints(snapPoints, state: &state)
        }
        return .none
    }
}

// MARK: - 사이드바 덮개

extension MeetingDetailFlowFeature {
    private func managementDelegates(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .management(.presented(.delegate(delegate))):
            return handleManagement(delegate, state: &state)
        case .management(.dismiss):
            state.managementPath.removeAll()
            return .none
        default:
            return .none
        }
    }

    private func handleManagement(
        _ delegate: MeetingManagementFeature.Action.Delegate,
        state: inout State
    ) -> Effect<Action> {
        switch delegate {
        case .closeRequested:
            // 덮개를 닫으면 덮개 안에 쌓인 화면도 함께 닫힌다
            state.management = nil
            state.managementPath.removeAll()
        case .memberManagementRequested:
            pushMemberManagement(onto: \.managementPath, state: &state)
        case .snapPointSettingRequested:
            pushSnapPointSetting(onto: \.managementPath, state: &state)
        case let .meetingChanged(meeting):
            syncMeeting(meeting, state: &state)
        case let .meetingDeleted(meetingID):
            return .send(.delegate(.meetingDeleted(meetingID: meetingID)))
        case let .rowRequested(row):
            return .send(.delegate(.managementRowRequested(row)))
        }
        return .none
    }
}

// MARK: - 쌓인 화면

extension MeetingDetailFlowFeature {
    private func routeDelegates(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .path(.element(id: id, action: routeAction)):
            handleRoute(routeAction, id: id, stack: \.path, state: &state)
        case let .managementPath(.element(id: id, action: routeAction)):
            handleRoute(routeAction, id: id, stack: \.managementPath, state: &state)
        default:
            break
        }
        return .none
    }

    private func handleRoute(
        _ action: Route.Action,
        id: StackElementID,
        stack: WritableKeyPath<State, StackState<Route.State>>,
        state: inout State
    ) {
        switch action {
        case .memberManagement(.delegate(.closeRequested)):
            // 멤버 관리 X. 사이드바 덮개 안이면 사이드바로, 위젯 위면 위젯으로 돌아간다
            state[keyPath: stack].pop(from: id)
        case let .memberManagement(.delegate(.memberApproved(member))):
            state.detail?.members.append(member)
            state.widget?.members.append(member)
            syncJoinedCount(by: 1, state: &state)
        case let .memberManagement(.delegate(.memberKicked(userID))):
            state.detail?.members.removeAll { $0.userID == userID }
            state.widget?.members.removeAll { $0.userID == userID }
            syncJoinedCount(by: -1, state: &state)
        case let .snapPointSetting(.delegate(.snapPointsChanged(snapPoints))):
            syncSnapPoints(snapPoints, state: &state)
        default:
            break
        }
    }

    private func pushMemberManagement(
        onto stack: WritableKeyPath<State, StackState<Route.State>>,
        state: inout State
    ) {
        guard let meeting = state.currentMeeting else { return }
        let isEnded = meeting.status == .ended
        state[keyPath: stack].append(
            .memberManagement(.init(meetingID: meeting.id, host: meeting.host, isEnded: isEnded))
        )
    }

    private func pushSnapPointSetting(
        onto stack: WritableKeyPath<State, StackState<Route.State>>,
        state: inout State
    ) {
        guard let meeting = state.currentMeeting else { return }
        let isEnded = meeting.status == .ended
        state[keyPath: stack].append(.snapPointSetting(.init(meetingID: meeting.id, isEnded: isEnded)))
    }
}

// MARK: - 값 맞추기

extension MeetingDetailFlowFeature {
    /// 상태를 바꾼 모임을 첫 화면·사이드바·두 쌓기에 넣는다. 관점은 그대로다(상태는 모임장만 바꾼다).
    private func syncMeeting(_ meeting: Meeting, state: inout State) {
        state.detail?.meeting = meeting
        state.widget?.meeting = meeting
        state.management?.meeting = meeting
        let isEnded = meeting.status == .ended
        Self.markEnded(isEnded, in: &state.path)
        Self.markEnded(isEnded, in: &state.managementPath)
    }

    private static func markEnded(_ isEnded: Bool, in stack: inout StackState<Route.State>) {
        for id in stack.ids {
            switch stack[id: id] {
            case .memberManagement?:
                stack[id: id, case: \.memberManagement]?.isEnded = isEnded
            case .snapPointSetting?:
                stack[id: id, case: \.snapPointSetting]?.isEnded = isEnded
            case nil:
                break
            }
        }
    }

    private func syncJoinedCount(by delta: Int, state: inout State) {
        state.detail?.meeting?.joinedCount += delta
        state.widget?.meeting?.joinedCount += delta
        state.management?.meeting.joinedCount += delta
    }

    private func syncSnapPoints(_ snapPoints: [SnapPoint], state: inout State) {
        state.detail?.snapPoints = snapPoints
        state.widget?.snapPoints = snapPoints
        state.management?.snapPointCount = snapPoints.count
    }
}
