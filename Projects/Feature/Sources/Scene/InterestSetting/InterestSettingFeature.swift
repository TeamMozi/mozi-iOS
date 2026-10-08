import Domain
import Foundation
import SharedDesignSystem
import ThirdParty

/// 온보딩 카테고리 화면. 서버 목록을 받아 1~5개를 고르고, 「완료」 때 프로필·사진·카테고리를 한 번에 저장한다.
@Reducer
public struct InterestSettingFeature {
    /// 빈 목록일 때 「다시 시도」 화면 문구
    static let emptyListMessage = "카테고리를 불러오지 못했어요. 다시 시도해 주세요."

    @ObservableState
    public struct State: Equatable {
        /// 프로필 화면이 넘긴 입력값. `interestIDs` 는 「완료」 때 채운다
        public var draft: OnboardingDraft
        /// 서버가 준 순서 그대로 그린다
        public var interests: [Interest]
        /// 고른 순서대로 쌓는다
        public var selectedIDs: [String]
        public var isSaving: Bool
        public var screen: ScreenStatus

        public init(
            draft: OnboardingDraft,
            interests: [Interest] = [],
            selectedIDs: [String] = [],
            isSaving: Bool = false,
            screen: ScreenStatus = .idle
        ) {
            self.draft = draft
            self.interests = interests
            self.selectedIDs = selectedIDs
            self.isSaving = isSaving
            self.screen = screen
        }

        /// 다시 들어오면 고른 칸만 되살아난 채 목록을 다시 받는다. 목록이 화면에 있을 때만 켠다
        public var isCompleteEnabled: Bool {
            selectedIDs.isEmpty == false && interests.isEmpty == false && isSaving == false && screen != .loading
        }

        public func isSelected(_ interest: Interest) -> Bool {
            selectedIDs.contains(interest.id)
        }
    }

    public enum Action: Equatable {
        case onAppear
        case retryTapped
        case interestsResponse(Result<[Interest], InterestError>)
        case interestTapped(id: String)
        case completeTapped
        case completeResponse(Result<EquatableVoid, UserError>)
        case failureDismissed
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// 고른 칸이 바뀌었다. 온보딩 Flow 가 들고 있다가 이 화면을 다시 쌓을 때 넣는다
            case selectionChanged([String])
            /// 저장 성공. 온보딩이 끝났다
            case finished
        }
    }

    /// Result 성공 값용 빈 마커. Void 는 Equatable 이 아니다.
    public struct EquatableVoid: Equatable, Sendable {
        public init() {}
    }

    @Dependency(\.interestClient) var interestClient
    @Dependency(\.userClient) var userClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce(core)
            .logged(as: Self.self, children: [])
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            // 다시 들어오면 새 State 라 목록을 다시 받는다. 받은 목록이 있거나 다른 상태면 그대로 둔다
            guard state.interests.isEmpty, state.screen == .idle else { return .none }
            return fetchInterests(&state)

        case .retryTapped:
            guard state.isSaving == false, state.screen != .loading else { return .none }
            return fetchInterests(&state)

        case let .interestsResponse(result):
            applyInterests(&state, result: result)
            return .none

        case let .interestTapped(id):
            return toggle(&state, id: id)

        case .completeTapped:
            return complete(&state)

        case let .completeResponse(result):
            return applyCompletion(&state, result: result)

        case .failureDismissed:
            state.screen = .idle
            return .none

        case .delegate:
            return .none
        }
    }

    private func fetchInterests(_ state: inout State) -> Effect<Action> {
        state.screen = .loading
        return .run { [interestClient] send in
            do {
                let interests = try await interestClient.interests()
                await send(.interestsResponse(.success(interests)))
            } catch let error as InterestError {
                await send(.interestsResponse(.failure(error)))
            } catch {
                await send(.interestsResponse(.failure(.unknown(message: error.localizedDescription))))
            }
        }
    }

    private func applyInterests(_ state: inout State, result: Result<[Interest], InterestError>) {
        switch result {
        case let .success(interests) where interests.isEmpty:
            state.screen = .loadFailed(message: Self.emptyListMessage)
        case let .success(interests):
            state.interests = interests
            state.screen = .idle
        case let .failure(error):
            state.screen = .loadFailed(message: FeatureErrorMessage.message(for: error))
        }
    }

    private func toggle(_ state: inout State, id: String) -> Effect<Action> {
        guard state.isSaving == false else { return .none }
        if let index = state.selectedIDs.firstIndex(of: id) {
            state.selectedIDs.remove(at: index)
        } else {
            // 다 고르면 나머지 칸은 눌러도 아무 일이 없다
            guard state.selectedIDs.count < UserLimit.interestMaxCount else { return .none }
            state.selectedIDs.append(id)
        }
        return .send(.delegate(.selectionChanged(state.selectedIDs)))
    }

    private func complete(_ state: inout State) -> Effect<Action> {
        guard state.isCompleteEnabled else { return .none }
        state.isSaving = true
        state.screen = .loading
        var draft = state.draft
        draft.interestIDs = state.selectedIDs
        return .run { [userClient, draft] send in
            do {
                try await userClient.completeOnboarding(draft)
                await send(.completeResponse(.success(EquatableVoid())))
            } catch let error as UserError {
                await send(.completeResponse(.failure(error)))
            } catch {
                await send(.completeResponse(.failure(.unknown(message: error.localizedDescription))))
            }
        }
    }

    private func applyCompletion(_ state: inout State, result: Result<EquatableVoid, UserError>) -> Effect<Action> {
        state.isSaving = false
        switch result {
        case .success:
            state.screen = .idle
            return .send(.delegate(.finished))
        case let .failure(error):
            // 프로필·사진·카테고리 중 하나라도 실패하면 전체 실패다. 다시 누르면 처음부터 다시 보낸다
            state.screen = .actionFailed(message: FeatureErrorMessage.message(for: error))
            return .none
        }
    }
}
