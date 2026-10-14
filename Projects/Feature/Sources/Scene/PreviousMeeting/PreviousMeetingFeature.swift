import Domain
import Foundation
import SharedDesignSystem
import ThirdParty

/// 이전 모임 불러오기. 「최신순」 은 `MeetingClient.hostedMeetings`, 「시리즈별」 은 `SeriesClient.hostedSeries` 를 쓴다.
/// 고른 모임은 delegate 로 올리고, 입력을 채우는 일은 모임 만들기 흐름이 한다.
@Reducer
public struct PreviousMeetingFeature {
    public enum Tab: Equatable, Sendable {
        case series
        case latest
    }

    @ObservableState
    public struct State: Equatable {
        public var tab: Tab
        public var latest: [Meeting] = []
        /// 최신순 다음 요청. nil 이면 다 읽었다.
        public var latestNext: PageRequest? = MeetingClient.hostedMeetingsFirstPage
        public var isLoadingLatest = false
        public var hostedSeries: [HostedSeries] = []
        /// 시리즈별 다음 요청. nil 이면 다 읽었다.
        public var seriesNext: PageRequest? = .first
        public var isLoadingSeries = false
        public var expandedSeriesIDs: Set<String> = []
        /// 「이 시리즈 모임 더보기」 로 더 읽은 회차. 이미 보인 회차는 뺐다.
        public var moreEpisodes: [String: [Meeting]] = [:]
        /// 「더보기」 다음 요청. 키가 없으면 `SeriesClient.moreEpisodesFirstPage` 부터다.
        public var moreEpisodesNext: [String: PageRequest] = [:]
        /// 「더보기」 를 끝까지 읽은 시리즈.
        public var finishedSeriesIDs: Set<String> = []
        public var selectedMeetingID: String?
        public var screen: ScreenStatus = .idle

        public init(tab: Tab = .latest) {
            self.tab = tab
        }

        public var selectedMeeting: Meeting? {
            guard let selectedMeetingID else { return nil }
            let seriesMeetings = hostedSeries.flatMap { episodes(of: $0) }
            return (latest + seriesMeetings).first { $0.id == selectedMeetingID }
        }

        /// 시리즈 칸에 보이는 회차. 최근 모임 뒤에 「더보기」 로 읽은 회차를 잇는다.
        public func episodes(of hosted: HostedSeries) -> [Meeting] {
            hosted.recentMeetings + (moreEpisodes[hosted.series.id] ?? [])
        }

        public func canLoadMoreEpisodes(of hosted: HostedSeries) -> Bool {
            !finishedSeriesIDs.contains(hosted.series.id)
                && episodes(of: hosted).count < hosted.series.episodeCount
        }
    }

    public enum Action: Equatable {
        case task
        case tabSelected(Tab)
        case lastMeetingAppeared
        case lastSeriesAppeared
        case latestLoaded(Result<Page<Meeting>, MeetingError>)
        case seriesLoaded(Result<Page<HostedSeries>, SeriesError>)
        case seriesToggled(String)
        case moreEpisodesTapped(String)
        case moreEpisodesLoaded(seriesID: String, Result<Page<Meeting>, SeriesError>)
        case meetingTapped(String)
        case nextTapped
        case retryTapped
        case failureDismissed
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// 고른 지난 모임. 모임 만들기 흐름이 입력을 채운다
            case meetingChosen(Meeting)
        }
    }

    static let defaultLoadFailureMessage = "이전 모임을 불러오지 못했어요"

    @Dependency(\.meetingClient) var meetingClient
    @Dependency(\.seriesClient) var seriesClient

    public init() {}

    public var body: some ReducerOf<Self> {
        CombineReducers {
            Reduce(lists)
            Reduce(responses)
            Reduce(seriesEpisodes)
            Reduce(choosing)
        }
        .logged(as: Self.self, children: [])
    }

    private func lists(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task, .retryTapped:
            state.screen = .idle
            return loadFirstPageIfNeeded(state: &state)
        case let .tabSelected(tab):
            state.tab = tab
            return loadFirstPageIfNeeded(state: &state)
        case .lastMeetingAppeared:
            guard !state.isLoadingLatest, !state.latest.isEmpty, let next = state.latestNext else { return .none }
            state.isLoadingLatest = true
            return fetchLatest(next)
        case .lastSeriesAppeared:
            guard !state.isLoadingSeries, !state.hostedSeries.isEmpty, let next = state.seriesNext else {
                return .none
            }
            state.isLoadingSeries = true
            return fetchSeries(next)
        case .failureDismissed:
            state.screen = .idle
            return .none
        default:
            return .none
        }
    }

    private func responses(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .latestLoaded(.success(page)):
            state.isLoadingLatest = false
            let known = Set(state.latest.map(\.id))
            state.latest += page.items.filter { !known.contains($0.id) }
            state.latestNext = page.next
        case let .latestLoaded(.failure(error)):
            state.isLoadingLatest = false
            state.screen = failureStatus(isFirstPage: state.latest.isEmpty, message: Self.message(for: error))
        case let .seriesLoaded(.success(page)):
            state.isLoadingSeries = false
            let known = Set(state.hostedSeries.map(\.series.id))
            state.hostedSeries += page.items.filter { !known.contains($0.series.id) }
            state.seriesNext = page.next
        case let .seriesLoaded(.failure(error)):
            state.isLoadingSeries = false
            state.screen = failureStatus(isFirstPage: state.hostedSeries.isEmpty, message: Self.message(for: error))
        default:
            break
        }
        return .none
    }

    private func seriesEpisodes(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .seriesToggled(id):
            if state.expandedSeriesIDs.contains(id) {
                state.expandedSeriesIDs.remove(id)
            } else {
                state.expandedSeriesIDs.insert(id)
            }
            return .none
        case let .moreEpisodesTapped(id):
            let request = state.moreEpisodesNext[id] ?? SeriesClient.moreEpisodesFirstPage
            return fetchMoreEpisodes(seriesID: id, request: request)
        case let .moreEpisodesLoaded(seriesID: id, .success(page)):
            let hosted = state.hostedSeries.first { $0.series.id == id }
            let shown = Set(hosted.map { state.episodes(of: $0).map(\.id) } ?? [])
            state.moreEpisodes[id, default: []] += page.items.filter { !shown.contains($0.id) }
            if let next = page.next {
                state.moreEpisodesNext[id] = next
            } else {
                state.finishedSeriesIDs.insert(id)
            }
            return .none
        case let .moreEpisodesLoaded(seriesID: _, .failure(error)):
            state.screen = .actionFailed(message: Self.message(for: error))
            return .none
        default:
            return .none
        }
    }

    private func choosing(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .meetingTapped(id):
            state.selectedMeetingID = id
            return .none
        case .nextTapped:
            guard let meeting = state.selectedMeeting else { return .none }
            return .send(.delegate(.meetingChosen(meeting)))
        default:
            return .none
        }
    }

    private func loadFirstPageIfNeeded(state: inout State) -> Effect<Action> {
        switch state.tab {
        case .latest:
            guard !state.isLoadingLatest, state.latest.isEmpty, let next = state.latestNext else { return .none }
            state.isLoadingLatest = true
            return fetchLatest(next)
        case .series:
            guard !state.isLoadingSeries, state.hostedSeries.isEmpty, let next = state.seriesNext else {
                return .none
            }
            state.isLoadingSeries = true
            return fetchSeries(next)
        }
    }

    private func failureStatus(isFirstPage: Bool, message: String) -> ScreenStatus {
        isFirstPage ? .loadFailed(message: message) : .actionFailed(message: message)
    }

    private func fetchLatest(_ request: PageRequest) -> Effect<Action> {
        .run { [meetingClient] send in
            do {
                let page = try await meetingClient.hostedMeetings(page: request)
                await send(.latestLoaded(.success(page)))
            } catch {
                await send(.latestLoaded(.failure((error as? MeetingError) ?? .unknown(message: ""))))
            }
        }
    }

    private func fetchSeries(_ request: PageRequest) -> Effect<Action> {
        .run { [seriesClient] send in
            do {
                let page = try await seriesClient.hostedSeries(page: request)
                await send(.seriesLoaded(.success(page)))
            } catch {
                await send(.seriesLoaded(.failure((error as? SeriesError) ?? .unknown(message: ""))))
            }
        }
    }

    private func fetchMoreEpisodes(seriesID: String, request: PageRequest) -> Effect<Action> {
        .run { [seriesClient] send in
            do {
                let page = try await seriesClient.episodes(seriesID: seriesID, page: request)
                await send(.moreEpisodesLoaded(seriesID: seriesID, .success(page)))
            } catch {
                let failure = (error as? SeriesError) ?? .unknown(message: "")
                await send(.moreEpisodesLoaded(seriesID: seriesID, .failure(failure)))
            }
        }
    }
}

extension PreviousMeetingFeature {
    /// 네트워크·로그인만 공통 표 문구를, 나머지는 불러오기 문구를 띄운다. 서버 message 는 띄우지 않는다.
    static func message(for error: MeetingError) -> String {
        switch error {
        case .forbidden, .notFound, .conflict, .joinRestricted, .validation, .unknown:
            defaultLoadFailureMessage
        case .network, .unauthorized:
            FeatureErrorMessage.message(for: error)
        }
    }

    static func message(for error: SeriesError) -> String {
        switch error {
        case .forbidden, .notFound, .conflict, .validation, .unknown:
            defaultLoadFailureMessage
        case .network, .unauthorized:
            FeatureErrorMessage.message(for: error)
        }
    }
}
