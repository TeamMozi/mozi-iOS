import Domain
import Foundation
import SharedDesignSystem
import ThirdParty

/// 모임 만들기 시트 안의 화면 스택. 입력 화면이 root 이고 그 위로 `Route` 화면을 쌓는다.
/// 입력·포스터 선택을 모아 만들기 요청을 보내고, 요청 중 표시와 실패 창은 요청을 보낸 화면 상태에 넣는다.
///
/// 화면을 그리지 않는다. 경로와 자식만 갖는다
@Reducer
public struct CreateMeetingFlowFeature {
    /// 입력(root) 위로 쌓이는 화면
    @Reducer
    public enum Route {
        case previousMeeting(PreviousMeetingFeature)
        case placeSearch(PlaceSearchFeature)
        case poster(PosterFeature)
        case seriesInfo(SeriesInfoFeature)
    }

    @ObservableState
    public struct State: Equatable {
        public var form: MeetingFormFeature.State
        public var path: StackState<Route.State>
        /// 포스터 화면에서 고른 것. 화면을 오가도 잃지 않게 흐름이 든다.
        public var poster: PosterSelection
        /// 만들기 요청을 보낸 화면. 요청 중이면 다시 보내지 않는다.
        public var submittingID: StackElementID?

        public init(
            form: MeetingFormFeature.State = MeetingFormFeature.State(),
            path: StackState<Route.State> = StackState<Route.State>(),
            poster: PosterSelection = PosterSelection(),
            submittingID: StackElementID? = nil
        ) {
            self.form = form
            self.path = path
            self.poster = poster
            self.submittingID = submittingID
        }

        /// 불러온 지난 모임이 시리즈에 묶여 있지 않으면 앵콜(2회차)이다. 포스터 다음에 시리즈 정보를 받는다.
        public var isEncore: Bool {
            form.linkedMeeting.map { $0.episode == nil } ?? false
        }
    }

    public enum Action: Equatable {
        case form(MeetingFormFeature.Action)
        case path(StackActionOf<Route>)
        case createResponse(Result<Meeting, MeetingError>)
        case encoreResponse(Result<EncoreResult, MeetingError>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// 만들었다. 탭 묶음이 시트를 닫는다
            case created(Meeting)
            /// 앵콜에서 모임은 만들고 시리즈만 실패했다. 다시 누르면 모임이 하나 더 생기므로 시트를 닫는다
            case createdWithoutSeries(Meeting)
            /// X. 확인 없이 닫고 입력을 버린다
            case closed
        }
    }

    public static let seriesFailedNotice = "모임은 만들었지만 시리즈 연결에 실패했어요"
    static let defaultFailureMessage = "모임을 만들지 못했어요. 잠시 후 다시 시도해 주세요"

    @Dependency(\.meetingClient) var meetingClient
    @Dependency(\.calendar) var calendar

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.form, action: \.form) {
            MeetingFormFeature()
        }
        CombineReducers {
            Reduce(navigation)
            Reduce(submission)
        }
        .forEach(\.path, action: \.path)
        .logged(as: Self.self, children: ["form"])
    }

    private func navigation(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .form(.delegate(.closeRequested)):
            return .send(.delegate(.closed))
        case .form(.delegate(.previousMeetingsRequested)):
            state.path.append(.previousMeeting(PreviousMeetingFeature.State()))
        case .form(.delegate(.placeRequested)):
            state.path.append(.placeSearch(PlaceSearchFeature.State()))
        case .form(.delegate(.nextRequested)):
            state.path.append(.poster(PosterFeature.State(selection: state.poster)))
        case let .path(.element(id: id, action: .previousMeeting(.delegate(.meetingChosen(meeting))))):
            state.form.load(from: meeting)
            state.poster = PosterSelection(
                image: meeting.posterURL.map { PosterImage.previous($0) } ?? PosterImage.empty,
                music: meeting.backgroundMusic
            )
            state.path.pop(from: id)
        case let .path(.element(id: id, action: .placeSearch(.delegate(.placeChosen(place))))):
            state.form.place = place
            state.path.pop(from: id)
        case let .path(.element(id: _, action: .poster(.delegate(.selectionChanged(selection))))):
            state.poster = selection
        default:
            break
        }
        return .none
    }

    private func submission(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .path(.element(id: id, action: .poster(.delegate(.nextRequested)))):
            guard !state.isEncore else {
                state.path.append(.seriesInfo(SeriesInfoFeature.State()))
                return .none
            }
            return submit(state: &state, from: id, series: nil)
        case let .path(.element(id: id, action: .seriesInfo(.delegate(.nextRequested(title, intro))))):
            return submit(state: &state, from: id, series: (title, intro))
        case let .createResponse(.success(meeting)),
             let .encoreResponse(.success(.created(meeting, _))):
            state.submittingID = nil
            return .send(.delegate(.created(meeting)))
        case let .encoreResponse(.success(.meetingOnly(meeting, _))):
            state.submittingID = nil
            return .send(.delegate(.createdWithoutSeries(meeting)))
        case let .createResponse(.failure(error)), let .encoreResponse(.failure(error)):
            let message = FeatureErrorMessage.meetingFailure(for: error, action: Self.defaultFailureMessage)
            fail(state: &state, message: message)
            return .none
        default:
            return .none
        }
    }

    /// 만들기 요청을 보낸다. `series` 가 있으면 앵콜이다. 요청 중이거나 입력이 다 차지 않았으면 보내지 않는다.
    private func submit(
        state: inout State,
        from id: StackElementID,
        series: (title: String, intro: String?)?
    ) -> Effect<Action> {
        guard state.submittingID == nil,
              let draft = state.form.draft(
                  in: calendar,
                  poster: state.poster.imageInput,
                  backgroundMusicID: state.poster.music?.id,
                  seriesID: state.form.linkedMeeting?.episode?.seriesID
              )
        else { return .none }
        state.submittingID = id
        setSubmitting(true, at: id, in: &state)
        if let series, let previous = state.form.linkedMeeting {
            let encore = EncoreDraft(
                meeting: draft,
                previousMeetingID: previous.id,
                seriesTitle: series.title,
                seriesIntro: series.intro
            )
            return .run { [meetingClient] send in
                do {
                    await send(.encoreResponse(.success(try await meetingClient.createEncore(draft: encore))))
                } catch {
                    await send(.encoreResponse(.failure(Self.meetingError(error))))
                }
            }
        }
        return .run { [meetingClient] send in
            do {
                await send(.createResponse(.success(try await meetingClient.create(draft: draft))))
            } catch {
                await send(.createResponse(.failure(Self.meetingError(error))))
            }
        }
    }

    /// 요청을 보낸 화면(포스터 또는 시리즈 정보)의 상태를 고친다.
    /// 다른 case 로 `path[id:case:]` 에 쓰면 TCA 가 오류로 알리므로 case 를 먼저 가른다.
    private func setSubmitting(
        _ isSubmitting: Bool,
        failure: ScreenStatus? = nil,
        at id: StackElementID,
        in state: inout State
    ) {
        switch state.path[id: id] {
        case .poster:
            state.path[id: id, case: \.poster]?.isSubmitting = isSubmitting
            if let failure { state.path[id: id, case: \.poster]?.screen = failure }
        case .seriesInfo:
            state.path[id: id, case: \.seriesInfo]?.isSubmitting = isSubmitting
            if let failure { state.path[id: id, case: \.seriesInfo]?.screen = failure }
        default:
            break
        }
    }

    /// 시트에 남는다. 요청을 보낸 화면에 오류 창을 띄운다.
    private func fail(state: inout State, message: String) {
        guard let id = state.submittingID else { return }
        state.submittingID = nil
        setSubmitting(false, failure: .actionFailed(message: message), at: id, in: &state)
    }

    /// Client 가 Domain 오류가 아닌 것을 던지면(본 앱의 등록되지 않은 Client 등) 빈 문구의 알 수 없는 오류로 본다.
    static func meetingError(_ error: any Error) -> MeetingError {
        (error as? MeetingError) ?? .unknown(message: "")
    }
}

extension CreateMeetingFlowFeature.Route.State: Equatable {}
extension CreateMeetingFlowFeature.Route.Action: Equatable {}
