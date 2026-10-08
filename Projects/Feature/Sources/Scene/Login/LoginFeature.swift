import Domain
import Foundation
import SharedDesignSystem
import ThirdParty

@Reducer
public struct LoginFeature {
    @ObservableState
    public struct State: Equatable {
        public var screen: ScreenStatus = .idle

        public var isLoading: Bool {
            screen == .loading
        }

        public init(screen: ScreenStatus = .idle) {
            self.screen = screen
        }
    }

    public enum Action: Equatable {
        case onAppear
        case kakaoLoginTapped
        case appleLoginTapped
        case loginResponse(Result<AuthSession, AuthError>)
        case failureDismissed
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case loggedIn(AuthSession)
        }
    }

    @Dependency(\.authClient) var authClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .kakaoLoginTapped:
                return login(state: &state, provider: .kakao)

            case .appleLoginTapped:
                return login(state: &state, provider: .apple)

            case let .loginResponse(.success(session)):
                state.screen = .idle
                return .send(.delegate(.loggedIn(session)))

            case let .loginResponse(.failure(error)):
                // 사용자 취소는 문구가 없다. 피드백 없이 idle 복귀한다.
                guard let message = Self.errorMessage(for: error) else {
                    state.screen = .idle
                    return .none
                }
                state.screen = .actionFailed(message: message)
                return .none

            case .failureDismissed:
                state.screen = .idle
                return .none

            case .delegate:
                return .none
            }
        }
        .logged(as: Self.self, children: [])
    }

    private func login(
        state: inout State,
        provider: AuthProvider
    ) -> Effect<Action> {
        guard state.isLoading == false else {
            return .none
        }

        state.screen = .loading

        return .run { [authClient] send in
            do {
                let session = try await authClient.login(provider)
                await send(.loginResponse(.success(session)))
            } catch let error as AuthError {
                await send(.loginResponse(.failure(error)))
            } catch {
                await send(.loginResponse(.failure(.unknown(message: error.localizedDescription))))
            }
        }
    }

    /// 공통 표에서 로그인 동작 이름이 필요한 두 종류만 덮어쓴다.
    private static func errorMessage(for error: AuthError) -> String? {
        switch error {
        case .unauthorized:
            "로그인에 실패했어요"
        case .storage:
            "로그인 정보를 저장하지 못했어요."
        case .cancelled, .notConfigured, .loginFailed, .network, .unknown:
            FeatureErrorMessage.message(for: error)
        }
    }
}
