import Domain
import Foundation
import SharedDesignSystem
import ThirdParty

/// 모임 관리(사이드바). 모임장만 연다. 상태 칩·멤버 관리·스냅 포인트 설정·모임 삭제만 동작하고,
/// 시안이 없는 다섯 칸은 delegate 로 올리기만 한다.
@Reducer
public struct MeetingManagementFeature {
    /// 시안이 없어 누르면 delegate 로만 올리는 칸
    public enum Row: Equatable, Sendable {
        case posterEdit
        case infoEdit
        case joinQuestions
        case joinType
        case capacity
    }

    /// 띄워 둔 확인 창
    public enum Confirmation: Equatable, Sendable {
        case endMeeting
        case deleteMeeting
    }

    @ObservableState
    public struct State: Equatable {
        public var meeting: Meeting
        /// 「스냅 포인트 설정」 칸 옆 숫자
        public var snapPointCount: Int
        public var confirmation: Confirmation?
        public var isRequesting = false
        public var screen: ScreenStatus = .idle

        public init(meeting: Meeting, snapPointCount: Int) {
            self.meeting = meeting
            self.snapPointCount = snapPointCount
        }

        /// 종료 뒤에는 상태 칩이 눌리지 않는다
        public var isEnded: Bool {
            meeting.status == .ended
        }
    }

    public enum Action: Equatable {
        case closeTapped
        case statusSelected(MeetingStatus)
        case memberManagementTapped
        case snapPointSettingTapped
        case rowTapped(Row)
        case deleteTapped
        case confirmationConfirmed
        case confirmationDismissed
        case statusChanged(MeetingStatus, Result<Meeting, MeetingError>)
        case deleteSucceeded
        case deleteFailed(MeetingError)
        case failureDismissed
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case closeRequested
            case memberManagementRequested
            case snapPointSettingRequested
            case rowRequested(Row)
            /// 상태를 바꿨다. 흐름이 다른 화면에 맞춰 넣는다
            case meetingChanged(Meeting)
            /// 모임을 지웠다. 흐름을 끝낸다
            case meetingDeleted(meetingID: String)
        }
    }

    @Dependency(\.meetingClient) var meetingClient

    public init() {}

    /// 상태 칩에서 고를 수 있는 상태. 모집 중이면 종료를 뺀다. 모집 마감을 거쳐야 종료한다(서버도 409 로 막는다).
    /// 종료된 모임은 칩이 막혀 있어 셋을 그대로 돌려준다.
    public static func selectableStatuses(from current: MeetingStatus) -> [MeetingStatus] {
        current.canEnd || current == .ended ? [.recruiting, .closed, .ended] : [.recruiting, .closed]
    }

    public var body: some ReducerOf<Self> {
        CombineReducers {
            Reduce(navigation)
            Reduce(statusAndDelete)
            Reduce(responses)
        }
        .logged(as: Self.self, children: [])
    }
}

// MARK: - 리듀서

extension MeetingManagementFeature {
    private func navigation(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .closeTapped:
            return .send(.delegate(.closeRequested))
        case .memberManagementTapped:
            return .send(.delegate(.memberManagementRequested))
        case .snapPointSettingTapped:
            return .send(.delegate(.snapPointSettingRequested))
        case let .rowTapped(row):
            return .send(.delegate(.rowRequested(row)))
        case .failureDismissed:
            state.screen = .idle
            return .none
        default:
            return .none
        }
    }

    private func statusAndDelete(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .statusSelected(status):
            guard !state.isEnded, !state.isRequesting, status != state.meeting.status,
                  Self.selectableStatuses(from: state.meeting.status).contains(status)
            else { return .none }
            if status == .ended {
                state.confirmation = .endMeeting
                return .none
            }
            if status == .recruiting, state.meeting.joinedCount >= state.meeting.capacity {
                state.screen = .actionFailed(message: FeatureErrorMessage.MeetingAction.reopenCapacityFull)
                return .none
            }
            state.isRequesting = true
            return changeStatus(to: status, meetingID: state.meeting.id)
        case .deleteTapped:
            guard !state.isRequesting else { return .none }
            state.confirmation = .deleteMeeting
            return .none
        case .confirmationConfirmed:
            guard let confirmation = state.confirmation, !state.isRequesting else { return .none }
            state.confirmation = nil
            state.isRequesting = true
            switch confirmation {
            case .endMeeting:
                return changeStatus(to: .ended, meetingID: state.meeting.id)
            case .deleteMeeting:
                return deleteMeeting(id: state.meeting.id)
            }
        case .confirmationDismissed:
            state.confirmation = nil
            return .none
        default:
            return .none
        }
    }

    private func responses(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .statusChanged(_, .success(meeting)):
            state.isRequesting = false
            state.meeting = meeting
            return .send(.delegate(.meetingChanged(meeting)))
        case let .statusChanged(status, .failure(error)):
            state.isRequesting = false
            let message = FeatureErrorMessage.meetingFailure(
                for: error,
                action: FeatureErrorMessage.MeetingAction.statusChangeFailed(status),
                conflict: status == .recruiting ? FeatureErrorMessage.MeetingAction.reopenCapacityFull : nil
            )
            state.screen = .actionFailed(message: message)
            return .none
        case .deleteSucceeded:
            state.isRequesting = false
            return .send(.delegate(.meetingDeleted(meetingID: state.meeting.id)))
        case let .deleteFailed(error):
            state.isRequesting = false
            let action = FeatureErrorMessage.MeetingAction.deleteFailed
            state.screen = .actionFailed(message: FeatureErrorMessage.meetingFailure(for: error, action: action))
            return .none
        default:
            return .none
        }
    }
}

// MARK: - 효과

extension MeetingManagementFeature {
    private func changeStatus(to status: MeetingStatus, meetingID: String) -> Effect<Action> {
        .run { [meetingClient] send in
            do {
                let meeting: Meeting
                switch status {
                case .recruiting:
                    meeting = try await meetingClient.reopenRecruitment(id: meetingID)
                case .closed:
                    meeting = try await meetingClient.closeRecruitment(id: meetingID)
                case .ended:
                    meeting = try await meetingClient.end(id: meetingID)
                }
                await send(.statusChanged(status, .success(meeting)))
            } catch {
                await send(.statusChanged(status, .failure(.wrapping(error))))
            }
        }
    }

    private func deleteMeeting(id: String) -> Effect<Action> {
        .run { [meetingClient] send in
            do {
                try await meetingClient.delete(id: id)
                await send(.deleteSucceeded)
            } catch {
                await send(.deleteFailed(.wrapping(error)))
            }
        }
    }
}
