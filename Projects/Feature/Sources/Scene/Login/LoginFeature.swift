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
                // 사용자 취소는 피드백 없이 idle 복귀한다.
                if case .cancelled = error {
                    state.screen = .idle
                    return .none
                }
                state.screen = .actionFailed(message: Self.errorMessage(for: error))
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

    private static func errorMessage(for error: AuthError) -> String {
        switch error {
        case .cancelled:
            return ""
        case .notConfigured:
            return "로그인 설정이 완료되지 않았어요."
        case .loginFailed:
            return "로그인에 실패했어요"
        case .network:
            return "네트워크 연결을 확인해 주세요"
        case .unauthorized:
            return "로그인에 실패했어요"
        case .storage:
            return "로그인 정보를 저장하지 못했어요."
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        }
    }
}
