import Domain
@testable import Feature
import ThirdParty
import XCTest

@MainActor
final class PosterFeatureTests: XCTestCase {
    private let music = BackgroundMusic(
        id: "music-1",
        title: "kitty on the keyboard",
        albumImageURL: nil,
        durationSeconds: 99,
        useCount: 110
    )

    func test_내_사진_탭을_처음_고르면_권한을_묻고_허용되면_최근_사진을_읽는다() async {
        let items = [PhotoLibraryItem(id: "photo-1", thumbnail: Data([1]))]
        let limits = LockIsolated<[Int]>([])
        var state = PosterFeature.State()
        state.isPhotoSheetPresented = true
        let store = TestStore(initialState: state) {
            PosterFeature()
        } withDependencies: {
            $0.posterPhotoLibrary.requestAccess = { .authorized }
            $0.posterPhotoLibrary.recentPhotos = { limit in
                limits.withValue { $0.append(limit) }
                return items
            }
        }

        await store.send(.photoTabSelected(.library)) {
            $0.photoTab = .library
        }
        await store.receive(.photoAccessResponded(.authorized)) {
            $0.photoAccess = .authorized
        }
        await store.receive(.photosLoaded(.success(items))) {
            $0.photos = items
        }
        XCTAssertEqual(limits.value, [PosterFeature.recentPhotoLimit])
    }

    func test_사진_권한을_거부하면_사진을_읽지_않고_거부_상태가_된다() async {
        var state = PosterFeature.State()
        state.isPhotoSheetPresented = true
        let store = TestStore(initialState: state) {
            PosterFeature()
        } withDependencies: {
            $0.posterPhotoLibrary.requestAccess = { .denied }
        }

        await store.send(.photoTabSelected(.library)) {
            $0.photoTab = .library
        }
        await store.receive(.photoAccessResponded(.denied)) {
            $0.photoAccess = .denied
        }
        XCTAssertTrue(store.state.photos.isEmpty)
    }

    func test_사진을_고르면_그_사진으로_포스터를_바꾸고_시트를_닫는다() async {
        var state = PosterFeature.State()
        state.isPhotoSheetPresented = true
        state.photoTab = .library
        let store = TestStore(initialState: state) {
            PosterFeature()
        } withDependencies: {
            $0.posterPhotoLibrary.posterData = { _ in Data([7]) }
        }

        await store.send(.photoTapped("photo-1"))
        await store.receive(.pickedDataLoaded(id: "photo-1", .success(Data([7])))) {
            $0.selection.image = .picked(id: "photo-1", data: Data([7]))
            $0.isPhotoSheetPresented = false
        }
        let changed = PosterSelection(image: .picked(id: "photo-1", data: Data([7])))
        await store.receive(.delegate(.selectionChanged(changed)))
    }

    func test_기본_견본을_고르면_그_견본으로_포스터를_바꾼다() async {
        var state = PosterFeature.State()
        state.isPhotoSheetPresented = true
        let store = TestStore(initialState: state) {
            PosterFeature()
        } withDependencies: {
            $0.posterPhotoLibrary.swatchData = { _ in Data([9]) }
        }

        await store.send(.swatchTapped(2))
        await store.receive(.pickedDataLoaded(id: "swatch-2", .success(Data([9])))) {
            $0.selection.image = .picked(id: "swatch-2", data: Data([9]))
            $0.isPhotoSheetPresented = false
        }
        let changed = PosterSelection(image: .picked(id: "swatch-2", data: Data([9])))
        await store.receive(.delegate(.selectionChanged(changed)))
    }

    func test_사진을_읽지_못하면_시트를_닫고_오류_창을_띄운다() async {
        var state = PosterFeature.State()
        state.isPhotoSheetPresented = true
        let store = TestStore(initialState: state) {
            PosterFeature()
        } withDependencies: {
            $0.posterPhotoLibrary.posterData = { _ in throw PhotoLibraryError.unreadable }
        }

        await store.send(.photoTapped("photo-1"))
        await store.receive(.pickedDataLoaded(id: "photo-1", .failure(.unreadable))) {
            $0.isPhotoSheetPresented = false
            $0.screen = .actionFailed(message: PosterFeature.photoFailureMessage)
        }
    }

    func test_배경음악을_고르고_확인하면_배경음악을_바꾸고_선택을_올린다() async {
        let track = music
        let store = TestStore(initialState: PosterFeature.State()) {
            PosterFeature()
        } withDependencies: {
            $0.meetingClient.popularBackgroundMusics = { [track] in [track] }
        }

        await store.send(.musicTapped) {
            $0.isMusicSheetPresented = true
        }
        await store.receive(.musicsLoaded(.success([music]))) {
            $0.musics = [self.music]
        }
        await store.send(.musicRowTapped("music-1")) {
            $0.pendingMusic = self.music
        }
        await store.send(.musicConfirmed) {
            $0.selection.music = self.music
            $0.isMusicSheetPresented = false
        }
        await store.receive(.delegate(.selectionChanged(PosterSelection(music: music))))
    }

    func test_배경음악_시트를_닫으면_고르던_곡을_버리고_배경음악은_그대로다() async {
        var state = PosterFeature.State()
        state.musics = [music]
        state.isMusicSheetPresented = true
        state.pendingMusic = music
        let store = TestStore(initialState: state) {
            PosterFeature()
        }

        await store.send(.musicSheetClosed) {
            $0.pendingMusic = nil
            $0.isMusicSheetPresented = false
        }
        XCTAssertNil(store.state.selection.music)
    }

    func test_요청_중이면_다음을_눌러도_올리지_않는다() async {
        let store = TestStore(initialState: PosterFeature.State(isSubmitting: true)) {
            PosterFeature()
        }

        await store.send(.nextTapped)
    }

    func test_요청_중이_아니면_다음을_누를_때_다음을_올린다() async {
        let store = TestStore(initialState: PosterFeature.State()) {
            PosterFeature()
        }

        await store.send(.nextTapped)
        await store.receive(.delegate(.nextRequested))
    }

    func test_고르지_않은_포스터는_포스터_없이_만든다() {
        XCTAssertEqual(PosterSelection().imageInput, .keep)
    }

    func test_지난_포스터는_그_주소를_이어_쓴다() {
        let url = URL(filePath: "/poster.jpg")
        XCTAssertEqual(PosterSelection(image: .previous(url)).imageInput, .reuse(url))
    }

    func test_고른_사진은_새_사진으로_올린다() {
        XCTAssertEqual(PosterSelection(image: .picked(id: "photo-1", data: Data([7]))).imageInput, .new(Data([7])))
    }
}
