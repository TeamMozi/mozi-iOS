import Domain
import Foundation
import SharedDesignSystem
import ThirdParty

/// 모임 포스터. 사진 한 장과 배경음악만 고른다. 사진은 3:4 를 꽉 채우고 가운데를 남긴다.
/// 고를 때마다 delegate 로 올려 흐름이 들고 있게 한다. → 다음에 할 일(시리즈 정보·만들기)은 흐름이 정한다.
@Reducer
public struct PosterFeature {
    public enum PhotoTab: Equatable, Sendable {
        case basic
        case library
    }

    @ObservableState
    public struct State: Equatable {
        public var selection: PosterSelection
        public var isPhotoSheetPresented = false
        public var photoTab: PhotoTab = .basic
        /// 사진 보관함 권한. 「내 사진」 을 처음 고르기 전에는 비어 있다.
        public var photoAccess: PhotoLibraryAccess?
        public var photos: [PhotoLibraryItem] = []
        public var isMusicSheetPresented = false
        public var musics: [BackgroundMusic] = []
        /// 배경음악 시트에서 고르는 중인 곡. ✓ 를 눌러야 `selection` 에 들어간다.
        public var pendingMusic: BackgroundMusic?
        public var isSubmitting: Bool
        public var screen: ScreenStatus = .idle

        public init(selection: PosterSelection = PosterSelection(), isSubmitting: Bool = false) {
            self.selection = selection
            self.isSubmitting = isSubmitting
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case photoAreaTapped
        case photoTabSelected(PhotoTab)
        case photoAccessResponded(PhotoLibraryAccess)
        case photosLoaded(Result<[PhotoLibraryItem], PhotoLibraryError>)
        case swatchTapped(Int)
        case photoTapped(String)
        case pickedDataLoaded(id: String, Result<Data, PhotoLibraryError>)
        case musicTapped
        case musicsLoaded(Result<[BackgroundMusic], MeetingError>)
        case musicRowTapped(String)
        case musicConfirmed
        case musicSheetClosed
        case nextTapped
        case failureDismissed
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// 사진이나 배경음악을 바꿨다
            case selectionChanged(PosterSelection)
            /// → 를 눌렀다
            case nextRequested
        }
    }

    static let recentPhotoLimit = 90
    static let photoFailureMessage = "사진을 불러오지 못했어요"
    static let musicFailureMessage = "배경음악을 불러오지 못했어요"

    @Dependency(\.posterPhotoLibrary) var photoLibrary
    @Dependency(\.meetingClient) var meetingClient

    public init() {}

    public var body: some ReducerOf<Self> {
        CombineReducers {
            BindingReducer()
            Reduce(photoSheet)
            Reduce(photoPicking)
            Reduce(musicSheet)
            Reduce(navigation)
        }
        .logged(as: Self.self, children: [])
    }

    private func photoSheet(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .photoAreaTapped:
            state.isPhotoSheetPresented = true
            return .none
        case let .photoTabSelected(tab):
            state.photoTab = tab
            guard tab == .library, state.photoAccess == nil else { return .none }
            return .run { [photoLibrary] send in
                await send(.photoAccessResponded(await photoLibrary.requestAccess()))
            }
        case let .photoAccessResponded(access):
            state.photoAccess = access
            guard access != .denied else { return .none }
            return .run { [photoLibrary] send in
                do {
                    let items = try await photoLibrary.recentPhotos(limit: Self.recentPhotoLimit)
                    await send(.photosLoaded(.success(items)))
                } catch {
                    await send(.photosLoaded(.failure((error as? PhotoLibraryError) ?? .unreadable)))
                }
            }
        case let .photosLoaded(.success(items)):
            state.photos = items
            return .none
        case .photosLoaded(.failure):
            // 시트가 떠 있으면 오류 창이 뜨지 않는다. 시트를 닫고 띄운다
            state.isPhotoSheetPresented = false
            state.screen = .actionFailed(message: Self.photoFailureMessage)
            return .none
        default:
            return .none
        }
    }

    private func photoPicking(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .swatchTapped(index):
            let id = PosterSwatch.id(index)
            return .run { [photoLibrary] send in
                do {
                    let data = try await photoLibrary.swatchData(index: index)
                    await send(.pickedDataLoaded(id: id, .success(data)))
                } catch {
                    await send(.pickedDataLoaded(id: id, .failure(.unreadable)))
                }
            }
        case let .photoTapped(id):
            return .run { [photoLibrary] send in
                do {
                    let data = try await photoLibrary.posterData(id: id)
                    await send(.pickedDataLoaded(id: id, .success(data)))
                } catch {
                    await send(.pickedDataLoaded(id: id, .failure((error as? PhotoLibraryError) ?? .unreadable)))
                }
            }
        case let .pickedDataLoaded(id: id, .success(data)):
            state.selection.image = .picked(id: id, data: data)
            state.isPhotoSheetPresented = false
            return .send(.delegate(.selectionChanged(state.selection)))
        case .pickedDataLoaded(id: _, .failure):
            state.isPhotoSheetPresented = false
            state.screen = .actionFailed(message: Self.photoFailureMessage)
            return .none
        default:
            return .none
        }
    }

    private func musicSheet(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .musicTapped:
            state.pendingMusic = state.selection.music
            state.isMusicSheetPresented = true
            guard state.musics.isEmpty else { return .none }
            return .run { [meetingClient] send in
                do {
                    let musics = try await meetingClient.popularBackgroundMusics()
                    await send(.musicsLoaded(.success(musics)))
                } catch {
                    await send(.musicsLoaded(.failure((error as? MeetingError) ?? .unknown(message: ""))))
                }
            }
        case let .musicsLoaded(.success(musics)):
            state.musics = musics
            return .none
        case .musicsLoaded(.failure):
            state.isMusicSheetPresented = false
            state.screen = .actionFailed(message: Self.musicFailureMessage)
            return .none
        case let .musicRowTapped(id):
            state.pendingMusic = state.musics.first { $0.id == id }
            return .none
        case .musicConfirmed:
            state.selection.music = state.pendingMusic
            state.isMusicSheetPresented = false
            return .send(.delegate(.selectionChanged(state.selection)))
        case .musicSheetClosed:
            state.pendingMusic = state.selection.music
            state.isMusicSheetPresented = false
            return .none
        default:
            return .none
        }
    }

    private func navigation(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .nextTapped:
            guard !state.isSubmitting else { return .none }
            return .send(.delegate(.nextRequested))
        case .failureDismissed:
            state.screen = .idle
            return .none
        default:
            return .none
        }
    }
}
