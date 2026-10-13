import Domain
import Foundation
import SharedDesignSystem
import ThirdParty

/// 위젯 화면(「위젯 / 스냅포인트」). 모임장만 연다. 거르는 일은 위젯을 연 쪽이 한다.
/// 스냅 포인트마다 촬영 알림을 아무 순서로 한 번씩 보낸다. 「모임 종료」 는 모임 관리와 같은 확인 창을 띄운다.
@Reducer
public struct MeetingWidgetFeature {
    public struct Loaded: Equatable, Sendable {
        public var meeting: Meeting
        public var snapPoints: [SnapPoint]
        public var members: [MeetingMember]

        public init(meeting: Meeting, snapPoints: [SnapPoint], members: [MeetingMember]) {
            self.meeting = meeting
            self.snapPoints = snapPoints
            self.members = members
        }
    }

    @ObservableState
    public struct State: Equatable {
        public var meetingID: String
        public var meeting: Meeting?
        public var snapPoints: [SnapPoint] = []
        /// 멤버 타일을 고르면 보이는 사진 격자. 모임장을 뺀 확정 멤버다
        public var members: [MeetingMember] = []
        public var isMemberGridShown = false
        /// 알림을 보내는 중인 스냅 포인트
        public var sendingSnapPointID: String?
        public var isEndConfirmationPresented = false
        public var isRequesting = false
        public var screen: ScreenStatus = .idle

        public init(meetingID: String) {
            self.meetingID = meetingID
        }

        public var isEnded: Bool {
            meeting?.status == .ended
        }

        /// `•••` 의 「모임 종료」·「스냅포인트 편집」. 종료 뒤에는 막는다
        public var canManage: Bool {
            meeting != nil && !isEnded && !isRequesting
        }

        /// `•••` 의 「모임 종료」 를 보일지. 모집 중이면 감춘다. 모집 마감을 거쳐야 종료한다(서버 409).
        /// 종료된 모임과 아직 못 읽은 모임은 보이되 막는다
        public var isEndMenuShown: Bool {
            meeting?.status != .recruiting
        }

        /// 「모임 종료」 를 누를 수 있는지. 모집 마감에서만 된다
        public var canEnd: Bool {
            canManage && meeting?.status.canEnd == true
        }

        /// 「알림」. 보낸 것은 다시 보내지 않고, 한 번에 하나만 보낸다
        public func canNotify(_ snapPoint: SnapPoint) -> Bool {
            meeting != nil && !isEnded && !snapPoint.isSent && sendingSnapPointID == nil
        }

        /// 참여 멤버 줄에 쓸 인원. 보내지 않았거나 참여가 0명(또는 모름)이면 비워 줄을 그리지 않는다(시안 2973:37711)
        public func shownParticipantCount(_ snapPoint: SnapPoint) -> Int? {
            guard snapPoint.isSent, let count = snapPoint.participantCount, count > 0 else { return nil }
            return count
        }
    }

    public enum Action: Equatable {
        case task
        case retryTapped
        case loaded(Result<Loaded, MeetingError>)
        case closeTapped
        case memberTileTapped
        case memberAllTapped
        case notifyTapped(id: String)
        case notified(SnapPoint)
        case notifyFailed(SnapPointError)
        case endMenuTapped
        case endConfirmed
        case endDismissed
        case ended(Result<Meeting, MeetingError>)
        case editMenuTapped
        case failureDismissed
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// X. 흐름이 띄운 쪽에 올린다
            case closeRequested
            /// 「멤버 전체보기 >」. 흐름이 멤버 관리를 쌓는다
            case memberManagementRequested
            /// 「스냅포인트 편집」. 흐름이 스냅 포인트 설정을 쌓는다
            case snapPointSettingRequested
            case meetingChanged(Meeting)
            case snapPointsChanged([SnapPoint])
        }
    }

    @Dependency(\.meetingClient) var meetingClient
    @Dependency(\.snapPointClient) var snapPointClient

    public init() {}

    public var body: some ReducerOf<Self> {
        CombineReducers {
            Reduce(loading)
            Reduce(navigation)
            Reduce(notifying)
            Reduce(ending)
        }
        .logged(as: Self.self, children: [])
    }
}

// MARK: - 리듀서

extension MeetingWidgetFeature {
    private func loading(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task, .retryTapped:
            guard state.meeting == nil, state.screen != .loading else { return .none }
            state.screen = .loading
            return load(meetingID: state.meetingID)
        case let .loaded(.success(loaded)):
            state.screen = .idle
            state.meeting = loaded.meeting
            state.snapPoints = loaded.snapPoints
            state.members = loaded.members
            return .none
        case let .loaded(.failure(error)):
            state.screen = .loadFailed(
                message: FeatureErrorMessage.meetingFailure(
                    for: error,
                    action: FeatureErrorMessage.MeetingAction.loadFailed
                )
            )
            return .none
        case .failureDismissed:
            state.screen = .idle
            return .none
        default:
            return .none
        }
    }

    private func navigation(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .closeTapped:
            return .send(.delegate(.closeRequested))
        case .memberTileTapped:
            state.isMemberGridShown.toggle()
            return .none
        case .memberAllTapped:
            return .send(.delegate(.memberManagementRequested))
        case .editMenuTapped:
            guard state.canManage else { return .none }
            return .send(.delegate(.snapPointSettingRequested))
        default:
            return .none
        }
    }

    private func notifying(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .notifyTapped(id):
            guard let snapPoint = state.snapPoints.first(where: { $0.id == id }), state.canNotify(snapPoint) else {
                return .none
            }
            state.sendingSnapPointID = id
            return sendNotification(snapPointID: id, meetingID: state.meetingID)
        case let .notified(snapPoint):
            state.sendingSnapPointID = nil
            if let index = state.snapPoints.firstIndex(where: { $0.id == snapPoint.id }) {
                state.snapPoints[index] = snapPoint
            }
            return .send(.delegate(.snapPointsChanged(state.snapPoints)))
        case let .notifyFailed(error):
            state.sendingSnapPointID = nil
            state.screen = .actionFailed(message: FeatureErrorMessage.message(for: error))
            return .none
        default:
            return .none
        }
    }

    private func ending(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .endMenuTapped:
            // 모집 중에서 온 종료는 확인 창도 요청도 없이 무시한다. 메뉴가 감춰 있어도 막아 둔다
            guard state.canEnd else { return .none }
            state.isEndConfirmationPresented = true
            return .none
        case .endConfirmed:
            guard state.isEndConfirmationPresented, state.canEnd else { return .none }
            state.isEndConfirmationPresented = false
            state.isRequesting = true
            return end(meetingID: state.meetingID)
        case .endDismissed:
            state.isEndConfirmationPresented = false
            return .none
        case let .ended(.success(meeting)):
            state.isRequesting = false
            state.meeting = meeting
            return .send(.delegate(.meetingChanged(meeting)))
        case let .ended(.failure(error)):
            state.isRequesting = false
            state.screen = .actionFailed(
                message: FeatureErrorMessage.meetingFailure(
                    for: error,
                    action: FeatureErrorMessage.MeetingAction.statusChangeFailed(.ended)
                )
            )
            return .none
        default:
            return .none
        }
    }
}

// MARK: - 효과

extension MeetingWidgetFeature {
    private func load(meetingID: String) -> Effect<Action> {
        .run { [meetingClient, snapPointClient] send in
            do {
                let meeting = try await meetingClient.meeting(id: meetingID)
                // 스냅 포인트·멤버는 실패해도 화면을 막지 않는다. 그 구간만 비운다.
                let snapPoints = (try? await snapPointClient.snapPoints(meetingID: meetingID)) ?? []
                let members = (try? await meetingClient.members(id: meetingID, status: .joined)) ?? []
                let loaded = Loaded(
                    meeting: meeting,
                    snapPoints: snapPoints,
                    members: members.filter { $0.userID != meeting.host.userID }
                )
                await send(.loaded(.success(loaded)))
            } catch {
                await send(.loaded(.failure(.wrapping(error))))
            }
        }
    }

    private func sendNotification(snapPointID: String, meetingID: String) -> Effect<Action> {
        .run { [snapPointClient] send in
            do {
                let snapPoint = try await snapPointClient.sendNotification(
                    meetingID: meetingID,
                    snapPointID: snapPointID
                )
                await send(.notified(snapPoint))
            } catch {
                await send(.notifyFailed(.wrapping(error)))
            }
        }
    }

    private func end(meetingID: String) -> Effect<Action> {
        .run { [meetingClient] send in
            do {
                let meeting = try await meetingClient.end(id: meetingID)
                await send(.ended(.success(meeting)))
            } catch {
                await send(.ended(.failure(.wrapping(error))))
            }
        }
    }
}
