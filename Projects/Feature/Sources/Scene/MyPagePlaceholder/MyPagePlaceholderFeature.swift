import Domain
import Foundation
import ThirdParty

@Reducer
public struct MyPagePlaceholderFeature {
    @ObservableState
    public struct State: Equatable {
        public var isLoggingOut = false
        public var errorMessage: String?

        public init(
            isLoggingOut: Bool = false,
            errorMessage: String? = nil
        ) {
            self.isLoggingOut = isLoggingOut
            self.errorMessage = errorMessage
        }
    }

    public enum Action: Equatable {
        case onAppear
        case logoutTapped
        case logoutResponse(Result<EquatableVoid, AuthError>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
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
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .logoutTapped:
                guard state.isLoggingOut == false else {
                    return .none
                }
                state.isLoggingOut = true
                state.errorMessage = nil
                return .run { [authClient] send in
                    do {
                        // Data 계층 계약:
                        // - 원격 logout 실패는 삼키고 로컬 세션 삭제를 진행
                        // - throw 는 로컬 clear 실패(storage)일 때만 올라온다
                        try await authClient.logout()
                        await send(.logoutResponse(.success(EquatableVoid())))
                    } catch let error as AuthError {
                        await send(.logoutResponse(.failure(error)))
                    } catch {
                        await send(
                            .logoutResponse(
                                .failure(.unknown(message: error.localizedDescription))
                            )
                        )
                    }
                }

            case .logoutResponse(.success):
                state.isLoggingOut = false
                state.errorMessage = nil
                return .send(.delegate(.loggedOut))

            case let .logoutResponse(.failure(error)):
                // 로컬 세션이 남아 있을 수 있으므로 화면을 유지하고 재시도를 유도한다.
                state.isLoggingOut = false
                state.errorMessage = FeatureErrorMessage.logoutFailure(for: error)
                return .none

            case .delegate:
                return .none
            }
        }
        .logged(as: Self.self, children: [])
    }
}
