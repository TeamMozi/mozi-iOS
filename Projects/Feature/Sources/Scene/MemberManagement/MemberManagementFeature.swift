import Domain
import Foundation
import SharedDesignSystem
import ThirdParty

/// 멤버 관리. 탭 셋(멤버·승인 대기·알림 요청)이다. 알림 요청 탭은 목록만 보인다.
/// 승인 대기 행의 「승인」, 멤버 행의 「내보내기」 는 시안이 나오기 전 임시 버튼이다.
@Reducer
public struct MemberManagementFeature {
    public enum Tab: Equatable, Hashable, CaseIterable, Sendable {
        case members
        case pending
        case notificationRequesters

        public var title: String {
            switch self {
            case .members: "멤버"
            case .pending: "승인 대기"
            case .notificationRequesters: "알림 요청"
            }
        }
    }

    /// 한 번에 읽는 목록 셋
    public struct Lists: Equatable, Sendable {
        public var members: [MeetingMember]
        public var pending: [MeetingMember]
        public var notificationRequesters: [MeetingMember]

        public init(members: [MeetingMember], pending: [MeetingMember], notificationRequesters: [MeetingMember]) {
            self.members = members
            self.pending = pending
            self.notificationRequesters = notificationRequesters
        }
    }

    @ObservableState
    public struct State: Equatable {
        public var meetingID: String
        /// 멤버 탭 맨 위 행. 내보내기 버튼이 없다
        public var host: MeetingHost
        /// 종료된 모임은 승인이 눌리지 않는다. 다른 화면에서 종료하면 흐름이 맞춰 넣는다
        public var isEnded: Bool
        public var tab: Tab
        /// 모임장을 뺀 확정 멤버
        public var members: [MeetingMember] = []
        public var pending: [MeetingMember] = []
        public var notificationRequesters: [MeetingMember] = []
        /// 내보내기 확인 창이 떠 있는 멤버
        public var kickTarget: MeetingMember?
        /// 승인·내보내기 요청 중인 사람
        public var requestingUserIDs: Set<String> = []
        public var hasLoaded = false
        public var screen: ScreenStatus = .idle

        public init(meetingID: String, host: MeetingHost, isEnded: Bool, tab: Tab = .members) {
            self.meetingID = meetingID
            self.host = host
            self.isEnded = isEnded
            self.tab = tab
        }

        /// 승인·내보내기 버튼을 그릴지. 종료된 모임에서는 그리지 않는다.
        /// 버튼은 임시로 글자 버튼(18)이다. 기본 버튼은 가장 작아도 36 이라 시안 행 높이 44 안에 들지 않는다.
        /// 버튼이 없어도 행 높이는 프로필 원(28)이 정해 44 그대로다
        public var showsMemberActions: Bool {
            !isEnded
        }

        public func canApprove(_ member: MeetingMember) -> Bool {
            !isEnded && !requestingUserIDs.contains(member.userID)
        }
    }

    public enum Action: Equatable {
        case task
        case retryTapped
        case listsLoaded(Result<Lists, MeetingError>)
        case tabSelected(Tab)
        case closeTapped
        case approveTapped(userID: String)
        case approved(userID: String)
        case approveFailed(userID: String, MeetingError)
        case kickTapped(userID: String)
        case kickConfirmed
        case kickDismissed
        case kicked(userID: String)
        case kickFailed(userID: String, MeetingError)
        case failureDismissed
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// X. 흐름이 쌓인 화면 하나를 뺀다
            case closeRequested
            /// 승인했다. 흐름이 다른 화면의 참여 인원·참여 멤버를 맞춘다
            case memberApproved(MeetingMember)
            case memberKicked(userID: String)
        }
    }

    @Dependency(\.meetingClient) var meetingClient

    public init() {}

    public var body: some ReducerOf<Self> {
        CombineReducers {
            Reduce(loading)
            Reduce(approving)
            Reduce(kicking)
        }
        .logged(as: Self.self, children: [])
    }
}

// MARK: - 리듀서

extension MemberManagementFeature {
    private func loading(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task, .retryTapped:
            guard !state.hasLoaded, state.screen != .loading else { return .none }
            state.screen = .loading
            return load(meetingID: state.meetingID, hostID: state.host.userID)
        case let .listsLoaded(.success(lists)):
            state.screen = .idle
            state.hasLoaded = true
            state.members = lists.members
            state.pending = lists.pending
            state.notificationRequesters = lists.notificationRequesters
            return .none
        case let .listsLoaded(.failure(error)):
            let message = FeatureErrorMessage.meetingFailure(
                for: error,
                action: FeatureErrorMessage.MeetingAction.membersLoadFailed
            )
            state.screen = .loadFailed(message: message)
            return .none
        case let .tabSelected(tab):
            state.tab = tab
            return .none
        case .closeTapped:
            return .send(.delegate(.closeRequested))
        case .failureDismissed:
            state.screen = .idle
            return .none
        default:
            return .none
        }
    }

    private func approving(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .approveTapped(userID):
            guard let member = state.pending.first(where: { $0.userID == userID }), state.canApprove(member) else {
                return .none
            }
            state.requestingUserIDs.insert(userID)
            return approve(userID: userID, meetingID: state.meetingID)
        case let .approved(userID):
            state.requestingUserIDs.remove(userID)
            guard let index = state.pending.firstIndex(where: { $0.userID == userID }) else { return .none }
            var member = state.pending.remove(at: index)
            member.status = .joined
            state.members.append(member)
            return .send(.delegate(.memberApproved(member)))
        case let .approveFailed(userID, error):
            state.requestingUserIDs.remove(userID)
            let message = FeatureErrorMessage.meetingFailure(
                for: error,
                action: FeatureErrorMessage.MeetingAction.approveFailed,
                conflict: FeatureErrorMessage.MeetingAction.approveCapacityFull
            )
            state.screen = .actionFailed(message: message)
            return .none
        default:
            return .none
        }
    }

    private func kicking(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .kickTapped(userID):
            guard !state.isEnded,
                  userID != state.host.userID,
                  state.kickTarget == nil,
                  !state.requestingUserIDs.contains(userID),
                  let member = state.members.first(where: { $0.userID == userID })
            else { return .none }
            state.kickTarget = member
            return .none
        case .kickConfirmed:
            guard let member = state.kickTarget else { return .none }
            state.kickTarget = nil
            state.requestingUserIDs.insert(member.userID)
            return kick(userID: member.userID, meetingID: state.meetingID)
        case .kickDismissed:
            state.kickTarget = nil
            return .none
        case let .kicked(userID):
            state.requestingUserIDs.remove(userID)
            state.members.removeAll { $0.userID == userID }
            return .send(.delegate(.memberKicked(userID: userID)))
        case let .kickFailed(userID, error):
            state.requestingUserIDs.remove(userID)
            state.screen = .actionFailed(
                message: FeatureErrorMessage.meetingFailure(
                    for: error,
                    action: FeatureErrorMessage.MeetingAction.kickFailed
                )
            )
            return .none
        default:
            return .none
        }
    }
}

// MARK: - 효과

extension MemberManagementFeature {
    private func load(meetingID: String, hostID: String) -> Effect<Action> {
        .run { [meetingClient] send in
            do {
                let joined = try await meetingClient.members(id: meetingID, status: .joined)
                let pending = try await meetingClient.members(id: meetingID, status: .pending)
                let requesters = try await meetingClient.notificationRequesters(id: meetingID)
                let lists = Lists(
                    members: joined.filter { $0.userID != hostID },
                    pending: pending,
                    notificationRequesters: requesters
                )
                await send(.listsLoaded(.success(lists)))
            } catch {
                await send(.listsLoaded(.failure(.wrapping(error))))
            }
        }
    }

    private func approve(userID: String, meetingID: String) -> Effect<Action> {
        .run { [meetingClient] send in
            do {
                try await meetingClient.approve(meetingID: meetingID, userID: userID)
                await send(.approved(userID: userID))
            } catch {
                await send(.approveFailed(userID: userID, .wrapping(error)))
            }
        }
    }

    private func kick(userID: String, meetingID: String) -> Effect<Action> {
        .run { [meetingClient] send in
            do {
                try await meetingClient.kick(meetingID: meetingID, userID: userID)
                await send(.kicked(userID: userID))
            } catch {
                await send(.kickFailed(userID: userID, .wrapping(error)))
            }
        }
    }
}
