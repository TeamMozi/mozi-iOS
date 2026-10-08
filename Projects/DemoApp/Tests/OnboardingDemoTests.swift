import Domain
import Feature
@testable import MoziDemoKit
import ThirdParty
import XCTest

@MainActor
final class OnboardingDemoTests: XCTestCase {
    func test_프로필_다_채운_화면은_시작하기가_켜져_있다() {
        XCTAssertTrue(ProfileSettingDemoState.filled.profileState.isStartEnabled)
        XCTAssertFalse(ProfileSettingDemoState.empty.profileState.isStartEnabled)
    }

    func test_프로필_로그아웃_실패는_알림이_처음부터_뜬다() {
        XCTAssertEqual(
            ProfileSettingDemoState.logoutFailed.profileState.screen,
            .actionFailed(message: "로그아웃 정보를 지우지 못했어요. 다시 시도해 주세요.")
        )
    }

    func test_카테고리_고른_상태는_시안의_세_칸을_고른다() {
        let state = InterestSettingDemoState.selected.interestState
        let names = InterestClient.previewInterests
            .filter { state.selectedIDs.contains($0.id) }
            .map(\.name)
        XCTAssertEqual(names, ["자기 계발", "여행/나들이", "푸드/드링크"])
    }

    func test_카테고리_저장_중은_목록과_고른_칸이_있고_완료가_꺼져_있다() {
        let state = InterestSettingDemoState.saving.interestState
        XCTAssertEqual(state.interests, InterestClient.previewInterests)
        XCTAssertEqual(state.selectedIDs.count, 3)
        XCTAssertTrue(state.isSaving)
        XCTAssertEqual(state.screen, .loading)
        XCTAssertFalse(state.isCompleteEnabled)
    }

    func test_카테고리_받기_실패는_나타나면_다시_시도_화면이_뜬다() async {
        let store = TestStore(initialState: InterestSettingDemoState.loadFailed.interestState) {
            InterestSettingFeature()
        } withDependencies: {
            $0.interestClient = InterestSettingDemoClient.interestClient(for: .loadFailed)
            $0.userClient = InterestSettingDemoClient.userClient(for: .loadFailed)
        }

        await store.send(.onAppear) {
            $0.screen = .loading
        }
        await store.receive(.interestsResponse(.failure(.network))) {
            $0.screen = .loadFailed(message: "네트워크 연결을 확인해 주세요")
        }
    }

    func test_카테고리_저장_실패는_확인_뒤_완료를_누르면_같은_알림이_다시_뜬다() async {
        let store = TestStore(initialState: InterestSettingDemoState.saveFailed.interestState) {
            InterestSettingFeature()
        } withDependencies: {
            $0.interestClient = InterestSettingDemoClient.interestClient(for: .saveFailed)
            $0.userClient = InterestSettingDemoClient.userClient(for: .saveFailed)
        }

        XCTAssertEqual(store.state.screen, .actionFailed(message: "네트워크 연결을 확인해 주세요"))
        await store.send(.failureDismissed) {
            $0.screen = .idle
        }
        await store.send(.completeTapped) {
            $0.isSaving = true
            $0.screen = .loading
        }
        await store.receive(.completeResponse(.failure(.network))) {
            $0.isSaving = false
            $0.screen = .actionFailed(message: "네트워크 연결을 확인해 주세요")
        }
    }

    func test_흐름_데모는_온보딩이_끝나면_처음_화면으로_돌아간다() async {
        let store = TestStore(initialState: Self.midwayState) {
            DemoOnboardingFlowFeature()
        }

        await store.send(.flow(.delegate(.finished))) {
            $0.flow = OnboardingFlowFeature.State()
        }
    }

    func test_흐름_데모는_로그아웃하면_처음_화면으로_돌아간다() async {
        let store = TestStore(initialState: Self.midwayState) {
            DemoOnboardingFlowFeature()
        }

        await store.send(.flow(.delegate(.loggedOut))) {
            $0.flow = OnboardingFlowFeature.State()
        }
    }

    private static var midwayState: DemoOnboardingFlowFeature.State {
        DemoOnboardingFlowFeature.State(
            flow: OnboardingFlowFeature.State(
                path: StackState([
                    .interestSetting(InterestSettingFeature.State(draft: InterestSettingDemoState.draft)),
                ]),
                selectedInterestIDs: ["preview-interest-hobby"]
            )
        )
    }
}
