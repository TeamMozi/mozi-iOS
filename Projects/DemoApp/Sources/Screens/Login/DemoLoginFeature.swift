import Feature
import ThirdParty

/// 로그인 화면 위에 토스트 층을 겹친다. 본 앱에서 RootFlowFeature 가 하던 토스트 연결만 가져온다.
@Reducer
struct DemoLoginFeature {
    @ObservableState
    struct State: Equatable {
        var login: LoginFeature.State
        var overlay: OverlayFeature.State

        init(demoState: LoginDemoState) {
            switch demoState {
            case .idle:
                login = LoginFeature.State()
                overlay = OverlayFeature.State()
            case .loading:
                login = LoginFeature.State(isLoading: true)
                overlay = OverlayFeature.State()
            case .networkError:
                login = LoginFeature.State()
                overlay = OverlayFeature.State(toastMessage: LoginDemoState.networkErrorMessage)
            }
        }
    }

    enum Action: Equatable {
        case login(LoginFeature.Action)
        case overlay(OverlayFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }
        Scope(state: \.overlay, action: \.overlay) {
            OverlayFeature()
        }
        Reduce { _, action in
            switch action {
            case let .login(.delegate(.presentToast(message))):
                return .send(.overlay(.showToast(message)))
            case let .login(.delegate(.presentAlert(message))):
                return .send(.overlay(.showAlert(message)))
            case .login, .overlay:
                return .none
            }
        }
    }
}
