import Domain
import Foundation
import SharedDesignSystem
import ThirdParty

/// 온보딩 구간의 화면 스택. 프로필 설정이 root 이고 그 위로 카테고리 설정을 쌓는다.
/// 프로필 뒤로를 받으면 로그아웃한다. 고른 카테고리를 들고 있다가 카테고리 화면을 다시 쌓을 때 넣는다.
///
/// 화면을 그리지 않는다. 경로와 자식만 갖는다
@Reducer
public struct OnboardingFlowFeature {
    /// 프로필 설정(root) 위로 쌓이는 화면
    @Reducer
    public enum Route {
        case interestSetting(InterestSettingFeature)
    }

    @ObservableState
    public struct State: Equatable {
        public var profile: ProfileSettingFeature.State
        public var path = StackState<Route.State>()
        /// 카테고리 화면에서 고른 칸. 뒤로 갔다 다시 들어와도 남는다
        public var selectedInterestIDs: [String]

        public init(
            profile: ProfileSettingFeature.State = ProfileSettingFeature.State(),
            path: StackState<Route.State> = StackState<Route.State>(),
            selectedInterestIDs: [String] = []
        ) {
            self.profile = profile
            self.path = path
            self.selectedInterestIDs = selectedInterestIDs
        }
    }

    public enum Action: Equatable {
        case path(StackActionOf<Route>)
        case profile(ProfileSettingFeature.Action)
        case logoutResponse(Result<EquatableVoid, AuthError>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// 온보딩 저장 성공. RootFlow 가 메인으로 넘긴다
            case finished
            /// 프로필 뒤로로 로그아웃했다. RootFlow 가 로그인으로 보낸다
            case loggedOut
        }
    }

    /// Result 성공 값용 빈 마커. Void 는 Equatable 이 아니다.
    public struct EquatableVoid: Equatable, Sendable {
        public init() {}
    }

    @Dependency(\.authClient) var authClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.profile, action: \.profile) {
            ProfileSettingFeature()
        }
        Reduce(core)
            .forEach(\.path, action: \.path)
            .logged(as: Self.self, children: ["profile"])
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .profile(.delegate(.submitted(draft))):
            state.path.append(
                .interestSetting(InterestSettingFeature.State(draft: draft, selectedIDs: state.selectedInterestIDs))
            )
            return .none

        case .profile(.delegate(.backRequested)):
            return logout(&state)

        case let .logoutResponse(result):
            return applyLogout(&state, result: result)

        case let .path(.element(id: _, action: .interestSetting(.delegate(.selectionChanged(ids))))):
            state.selectedInterestIDs = ids
            return .none

        case .path(.element(id: _, action: .interestSetting(.delegate(.finished)))):
            return .send(.delegate(.finished))

        case .path, .profile, .delegate:
            return .none
        }
    }

    private func logout(_ state: inout State) -> Effect<Action> {
        guard state.profile.isLoggingOut == false else { return .none }
        state.profile.screen = .loading
        return .run { [authClient] send in
            do {
                // Data 계층 계약: 원격 logout 실패는 삼키고, throw 는 로컬 세션 삭제 실패일 때만 올라온다
                try await authClient.logout()
                await send(.logoutResponse(.success(EquatableVoid())))
            } catch let error as AuthError {
                await send(.logoutResponse(.failure(error)))
            } catch {
                await send(.logoutResponse(.failure(.unknown(message: error.localizedDescription))))
            }
        }
    }

    private func applyLogout(_ state: inout State, result: Result<EquatableVoid, AuthError>) -> Effect<Action> {
        switch result {
        case .success:
            state.profile.screen = .idle
            return .send(.delegate(.loggedOut))
        case let .failure(error):
            // 기기 세션이 남아 있을 수 있으므로 프로필 화면에 남고 다시 누르게 한다
            state.profile.screen = .actionFailed(message: FeatureErrorMessage.logoutFailure(for: error))
            return .none
        }
    }
}

extension OnboardingFlowFeature.Route.State: Equatable {}
extension OnboardingFlowFeature.Route.Action: Equatable {}
