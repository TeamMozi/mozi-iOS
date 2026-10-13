import Domain
import Foundation
import SharedDesignSystem
import ThirdParty

/// 모임 상세. 나의 참여 상태(모임장·멤버·승인 대기·신청 전)마다 위 오른쪽 버튼과 아래 버튼이 다르다.
/// 다른 화면으로 가는 일은 delegate 로 올린다. 모임 관리 화면은 모임 상세 흐름이 쌓는다.
@Reducer
public struct MeetingDetailFeature {
    /// 모임을 읽은 뒤 덧붙여 읽는 구간. 실패한 구간은 비운다.
    public struct Extras: Equatable, Sendable {
        public var members: [MeetingMember]
        public var snapPoints: [SnapPoint]
        public var series: Series?
        public var episodes: [Meeting]

        public init(members: [MeetingMember], snapPoints: [SnapPoint], series: Series?, episodes: [Meeting]) {
            self.members = members
            self.snapPoints = snapPoints
            self.series = series
            self.episodes = episodes
        }
    }

    @ObservableState
    public struct State: Equatable {
        public var meetingID: String
        public var meeting: Meeting?
        /// 참여 멤버 구간. 모임장을 뺀 확정 멤버다.
        public var members: [MeetingMember] = []
        public var snapPoints: [SnapPoint] = []
        public var series: Series?
        /// 시리즈 소개의 회차 카드. 최신 회차부터다.
        public var episodes: [Meeting] = []
        /// 가입 질문 시트가 떠 있으면 질문마다 답이 들어 있다.
        public var joinAnswers: [String]?
        public var isRequesting = false
        public var screen: ScreenStatus = .idle

        public init(meetingID: String) {
            self.meetingID = meetingID
        }

        public var perspective: MyParticipation? {
            meeting?.myParticipation
        }

        /// 「신청하기」 를 보일지. 모집 마감·종료·정원 참이면 감춘다.
        public var canApply: Bool {
            guard let meeting, meeting.myParticipation == MyParticipation.none else { return false }
            return meeting.status == .recruiting && meeting.joinedCount < meeting.capacity
        }

        public var showsSnapPoints: Bool {
            perspective == .host || perspective == .member
        }

        public var isSeriesEnabled: Bool {
            meeting?.episode != nil
        }

        /// 멤버의 「모임 나가기」, 승인 대기의 「신청 취소」. 둘 다 `leave` 다.
        public var canLeave: Bool {
            perspective == .member || perspective == .pending
        }

        public var canSubmitJoin: Bool {
            guard let joinAnswers, !isRequesting else { return false }
            return joinAnswers.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        }
    }

    public enum Action: Equatable {
        case task
        case retryTapped
        case meetingLoaded(Result<Meeting, MeetingError>)
        case extrasLoaded(Extras)
        case snapPointsLoaded([SnapPoint])
        case membersLoaded([MeetingMember])
        case backTapped
        case menuTapped
        case chatTapped
        case filmTapped
        case seriesTapped
        case bellTapped
        case notificationToggled(Result<Bool, MeetingError>)
        case joinTapped
        case joinAnswerChanged(index: Int, text: String)
        case joinSheetDismissed
        case joinSubmitTapped
        case joinResponse(Result<MyParticipation, MeetingError>)
        case leaveTapped
        /// 성공 값은 나가기 전 참여 상태다
        case leaveResponse(Result<MyParticipation, MeetingError>)
        case failureDismissed
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// 첫 화면의 뒤로 가기. 흐름이 띄운 쪽에 올린다
            case closeRequested
            /// 모임장의 `≡`. 흐름이 모임 관리를 쌓는다
            case managementRequested
            case chatRequested(meetingID: String)
            case filmRequested(meetingID: String)
            case seriesRequested(seriesID: String)
        }
    }

    @Dependency(\.meetingClient) var meetingClient
    @Dependency(\.seriesClient) var seriesClient
    @Dependency(\.snapPointClient) var snapPointClient

    public init() {}

    public var body: some ReducerOf<Self> {
        CombineReducers {
            Reduce(loading)
            Reduce(navigation)
            Reduce(joinSheet)
            Reduce(requests)
            Reduce(responses)
        }
        .logged(as: Self.self, children: [])
    }
}

// MARK: - 리듀서

extension MeetingDetailFeature {
    private func loading(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task, .retryTapped:
            guard state.meeting == nil, state.screen != .loading else { return .none }
            state.screen = .loading
            return fetchMeeting(id: state.meetingID)
        case let .meetingLoaded(.success(meeting)):
            state.screen = .idle
            state.meeting = meeting
            return fetchExtras(of: meeting)
        case let .meetingLoaded(.failure(error)):
            state.screen = .loadFailed(
                message: FeatureErrorMessage.meetingFailure(
                    for: error,
                    action: FeatureErrorMessage.MeetingAction.loadFailed
                )
            )
            return .none
        case let .extrasLoaded(extras):
            state.members = extras.members
            state.snapPoints = extras.snapPoints
            state.series = extras.series
            state.episodes = extras.episodes
            return .none
        case let .snapPointsLoaded(snapPoints):
            state.snapPoints = snapPoints
            return .none
        case let .membersLoaded(members):
            state.members = members
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
        case .backTapped:
            return .send(.delegate(.closeRequested))
        case .menuTapped:
            guard state.perspective == .host else { return .none }
            return .send(.delegate(.managementRequested))
        case .chatTapped:
            return .send(.delegate(.chatRequested(meetingID: state.meetingID)))
        case .filmTapped:
            return .send(.delegate(.filmRequested(meetingID: state.meetingID)))
        case .seriesTapped:
            guard let seriesID = state.meeting?.episode?.seriesID else { return .none }
            return .send(.delegate(.seriesRequested(seriesID: seriesID)))
        default:
            return .none
        }
    }

    private func joinSheet(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .joinTapped:
            guard state.canApply, !state.isRequesting, let meeting = state.meeting else { return .none }
            if meeting.joinQuestions.isEmpty {
                state.isRequesting = true
                return join(meetingID: meeting.id, answers: [])
            }
            state.joinAnswers = Array(repeating: "", count: meeting.joinQuestions.count)
            return .none
        case let .joinAnswerChanged(index, text):
            guard state.joinAnswers?.indices.contains(index) == true else { return .none }
            state.joinAnswers?[index] = text
            return .none
        case .joinSheetDismissed:
            state.joinAnswers = nil
            return .none
        case .joinSubmitTapped:
            guard state.canSubmitJoin, let answers = state.joinAnswers else { return .none }
            state.isRequesting = true
            let trimmed = answers.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            return join(meetingID: state.meetingID, answers: trimmed)
        default:
            return .none
        }
    }

    private func requests(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .bellTapped:
            guard let meeting = state.meeting, !state.isRequesting else { return .none }
            state.isRequesting = true
            return toggleNotification(meetingID: meeting.id, request: !meeting.isNotificationRequested)
        case .leaveTapped:
            guard state.canLeave, !state.isRequesting, let participation = state.perspective else { return .none }
            state.isRequesting = true
            return leave(meetingID: state.meetingID, from: participation)
        default:
            return .none
        }
    }

    private func responses(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .joinResponse(.success(participation)):
            state.isRequesting = false
            state.joinAnswers = nil
            state.meeting?.myParticipation = participation
            guard participation == .member else { return .none }
            state.meeting?.joinedCount += 1
            return .concatenate(fetchMembers(of: state.meeting), fetchSnapPoints(meetingID: state.meetingID))
        case let .joinResponse(.failure(error)):
            state.isRequesting = false
            state.joinAnswers = nil
            state.screen = Self.failure(error, action: FeatureErrorMessage.MeetingAction.joinFailed)
            return .none
        case let .leaveResponse(.success(previous)):
            state.isRequesting = false
            state.meeting?.myParticipation = MyParticipation.none
            if previous == .member {
                state.meeting?.joinedCount -= 1
            }
            state.snapPoints = []
            // 리듀서는 「나」 의 id 를 몰라 멤버 목록을 다시 읽는다.
            return fetchMembers(of: state.meeting)
        case let .leaveResponse(.failure(error)):
            state.isRequesting = false
            state.screen = Self.failure(error, action: FeatureErrorMessage.MeetingAction.leaveFailed)
            return .none
        case let .notificationToggled(.success(isRequested)):
            state.isRequesting = false
            state.meeting?.isNotificationRequested = isRequested
            state.meeting?.notificationRequestCount += isRequested ? 1 : -1
            return .none
        case let .notificationToggled(.failure(error)):
            state.isRequesting = false
            state.screen = Self.failure(error, action: FeatureErrorMessage.MeetingAction.notificationFailed)
            return .none
        default:
            return .none
        }
    }

    private static func failure(_ error: MeetingError, action: String) -> ScreenStatus {
        .actionFailed(message: FeatureErrorMessage.meetingFailure(for: error, action: action))
    }
}

// MARK: - 효과

extension MeetingDetailFeature {
    private func fetchMeeting(id: String) -> Effect<Action> {
        .run { [meetingClient] send in
            do {
                let meeting = try await meetingClient.meeting(id: id)
                await send(.meetingLoaded(.success(meeting)))
            } catch {
                await send(.meetingLoaded(.failure(.wrapping(error))))
            }
        }
    }

    private func fetchExtras(of meeting: Meeting) -> Effect<Action> {
        let showsSnapPoints = meeting.myParticipation == .host || meeting.myParticipation == .member
        return .run { [meetingClient, seriesClient, snapPointClient] send in
            // 덧붙이는 구간은 실패해도 화면을 막지 않는다. 그 구간만 비운다.
            let members = await Self.joinedMembers(of: meeting, client: meetingClient)
            var snapPoints: [SnapPoint] = []
            if showsSnapPoints {
                snapPoints = (try? await snapPointClient.snapPoints(meetingID: meeting.id)) ?? []
            }
            var series: Series?
            var episodes: [Meeting] = []
            if let seriesID = meeting.episode?.seriesID {
                series = try? await seriesClient.series(id: seriesID)
                episodes = (try? await seriesClient.episodes(seriesID: seriesID, page: .first))?.items ?? []
            }
            let extras = Extras(
                members: members,
                snapPoints: snapPoints,
                series: series,
                episodes: episodes
            )
            await send(.extrasLoaded(extras))
        }
    }

    private func fetchMembers(of meeting: Meeting?) -> Effect<Action> {
        guard let meeting else { return .none }
        return .run { [meetingClient] send in
            await send(.membersLoaded(Self.joinedMembers(of: meeting, client: meetingClient)))
        }
    }

    /// 참여 멤버 구간의 목록. 모임장을 빼고, 못 읽으면 비운다.
    private static func joinedMembers(of meeting: Meeting, client: MeetingClient) async -> [MeetingMember] {
        let members = (try? await client.members(id: meeting.id, status: .joined)) ?? []
        return members.filter { $0.userID != meeting.host.userID }
    }

    private func fetchSnapPoints(meetingID: String) -> Effect<Action> {
        .run { [snapPointClient] send in
            let snapPoints = (try? await snapPointClient.snapPoints(meetingID: meetingID)) ?? []
            await send(.snapPointsLoaded(snapPoints))
        }
    }

    private func join(meetingID: String, answers: [String]) -> Effect<Action> {
        .run { [meetingClient] send in
            do {
                let participation = try await meetingClient.join(id: meetingID, answers: answers)
                await send(.joinResponse(.success(participation)))
            } catch {
                await send(.joinResponse(.failure(.wrapping(error))))
            }
        }
    }

    private func leave(meetingID: String, from participation: MyParticipation) -> Effect<Action> {
        .run { [meetingClient] send in
            do {
                try await meetingClient.leave(id: meetingID)
                await send(.leaveResponse(.success(participation)))
            } catch {
                await send(.leaveResponse(.failure(.wrapping(error))))
            }
        }
    }

    private func toggleNotification(meetingID: String, request: Bool) -> Effect<Action> {
        .run { [meetingClient] send in
            do {
                if request {
                    try await meetingClient.requestNotification(id: meetingID)
                } else {
                    try await meetingClient.cancelNotificationRequest(id: meetingID)
                }
                await send(.notificationToggled(.success(request)))
            } catch {
                await send(.notificationToggled(.failure(.wrapping(error))))
            }
        }
    }
}
