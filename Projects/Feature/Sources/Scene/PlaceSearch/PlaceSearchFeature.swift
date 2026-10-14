import Domain
import Foundation
import SharedDesignSystem
import ThirdParty

/// 장소 선택. 검색은 키보드 검색 키를 누를 때 한 번 부른다. 고른 장소는 머리 줄 체크로 올린다.
/// 지도 자리는 비워 둔다. 카카오 지도는 별도 작업이다.
@Reducer
public struct PlaceSearchFeature {
    @ObservableState
    public struct State: Equatable {
        public var query: String
        public var results: [Place] = []
        /// 한 번이라도 검색 결과를 받았는지. 받기 전에는 지도 자리를 보인다.
        public var hasSearched = false
        public var isSearching = false
        /// `results` 안에서 고른 칸. `Place` 는 id 가 없어 자리로 가리킨다.
        public var selectedIndex: Int?
        public var screen: ScreenStatus = .idle

        public init(query: String = "") {
            self.query = query
        }

        public var selectedPlace: Place? {
            guard let selectedIndex, results.indices.contains(selectedIndex) else { return nil }
            return results[selectedIndex]
        }

        /// 머리 줄 체크를 누를 수 있는지. 줄을 골라야 켜진다.
        public var canConfirm: Bool {
            selectedPlace != nil
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case searchSubmitted
        case searchResponse(Result<[Place], PlaceError>)
        case placeTapped(Int)
        case doneTapped
        case failureDismissed
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case placeChosen(Place)
        }
    }

    static let defaultFailureMessage = "장소를 검색하지 못했어요"

    @Dependency(\.placeClient) var placeClient

    public init() {}

    public var body: some ReducerOf<Self> {
        CombineReducers {
            BindingReducer()
            Reduce(searching)
            Reduce(choosing)
        }
        .logged(as: Self.self, children: [])
    }

    private func searching(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .searchSubmitted:
            let query = state.query.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !query.isEmpty, !state.isSearching else { return .none }
            state.isSearching = true
            state.selectedIndex = nil
            return .run { [placeClient] send in
                do {
                    let places = try await placeClient.search(query: query)
                    await send(.searchResponse(.success(places)))
                } catch {
                    await send(.searchResponse(.failure((error as? PlaceError) ?? .unknown(message: ""))))
                }
            }
        case let .searchResponse(.success(places)):
            state.isSearching = false
            state.hasSearched = true
            state.results = places
            return .none
        case let .searchResponse(.failure(error)):
            state.isSearching = false
            state.screen = .actionFailed(message: Self.message(for: error))
            return .none
        default:
            return .none
        }
    }

    private func choosing(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .placeTapped(index):
            guard state.results.indices.contains(index) else { return .none }
            state.selectedIndex = index
            return .none
        case .doneTapped:
            guard let place = state.selectedPlace else { return .none }
            return .send(.delegate(.placeChosen(place)))
        case .failureDismissed:
            state.screen = .idle
            return .none
        default:
            return .none
        }
    }

    /// 공통 표에서 검색 동작 이름이 필요한 종류만 덮어쓴다. 서버 message 는 띄우지 않는다.
    static func message(for error: PlaceError) -> String {
        switch error {
        case .forbidden, .notFound, .conflict, .unknown:
            defaultFailureMessage
        case .network, .unauthorized, .validation:
            FeatureErrorMessage.message(for: error)
        }
    }
}
