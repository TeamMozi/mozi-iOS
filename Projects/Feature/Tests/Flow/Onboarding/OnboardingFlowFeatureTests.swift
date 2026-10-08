import Domain
import Feature
import Foundation
import ThirdParty
import XCTest

private let onboardingDraft = OnboardingDraft(
    nickname: "수연",
    birthDate: Date(timeIntervalSince1970: 946_684_800),
    gender: .female,
    introduction: nil,
    profileImage: .keep,
    interestIDs: []
)

@MainActor
final class OnboardingFlowFeatureTests: XCTestCase {
    func test_처음에는_프로필_화면이고_쌓인_화면이_없다() {
        let state = OnboardingFlowFeature.State()
        XCTAssertEqual(state.profile, ProfileSettingFeature.State())
        XCTAssertTrue(state.path.isEmpty)
        XCTAssertTrue(state.selectedInterestIDs.isEmpty)
    }

    func test_프로필이_입력값을_올리면_카테고리_화면을_쌓는다() async {
        let store = TestStore(initialState: OnboardingFlowFeature.State()) {
            OnboardingFlowFeature()
        }

        await store.send(.profile(.delegate(.submitted(onboardingDraft)))) {
            $0.path[id: 0] = .interestSetting(InterestSettingFeature.State(draft: onboardingDraft))
        }
    }

    func test_뒤로_갔다_다시_들어오면_고른_칸이_남아_있다() async {
        let store = TestStore(initialState: OnboardingFlowFeature.State()) {
            OnboardingFlowFeature()
        }

        await store.send(.profile(.delegate(.submitted(onboardingDraft)))) {
            $0.path[id: 0] = .interestSetting(InterestSettingFeature.State(draft: onboardingDraft))
        }
        await store.send(.path(.element(id: 0, action: .interestSetting(.interestTapped(id: "2"))))) {
            $0.path[id: 0, case: \.interestSetting]?.selectedIDs = ["2"]
        }
        await store.receive(.path(.element(id: 0, action: .interestSetting(.delegate(.selectionChanged(["2"])))))) {
            $0.selectedInterestIDs = ["2"]
        }
        await store.send(.path(.popFrom(id: 0))) {
            $0.path = StackState()
        }
        await store.send(.profile(.delegate(.submitted(onboardingDraft)))) {
            $0.path[id: 1] = .interestSetting(
                InterestSettingFeature.State(draft: onboardingDraft, selectedIDs: ["2"])
            )
        }
    }

    func test_카테고리_화면이_저장을_끝내면_온보딩_끝을_위로_올린다() async {
        let store = TestStore(
            initialState: OnboardingFlowFeature.State(
                path: StackState([.interestSetting(InterestSettingFeature.State(draft: onboardingDraft))])
            )
        ) {
            OnboardingFlowFeature()
        }

        await store.send(.path(.element(id: 0, action: .interestSetting(.delegate(.finished)))))
        await store.receive(.delegate(.finished))
    }

    func test_프로필_뒤로는_로그아웃하고_성공하면_로그아웃을_위로_올린다() async {
        let store = TestStore(initialState: OnboardingFlowFeature.State()) {
            OnboardingFlowFeature()
        } withDependencies: {
            $0.authClient.logout = {}
        }

        await store.send(.profile(.backTapped))
        await store.receive(.profile(.delegate(.backRequested))) {
            $0.profile.screen = .loading
        }
        await store.receive(.logoutResponse(.success(OnboardingFlowFeature.EquatableVoid()))) {
            $0.profile.screen = .idle
        }
        await store.receive(.delegate(.loggedOut))
    }

    func test_로그아웃에_실패하면_프로필_화면에_실패_알림을_내린다() async {
        let store = TestStore(initialState: OnboardingFlowFeature.State()) {
            OnboardingFlowFeature()
        } withDependencies: {
            $0.authClient.logout = { throw AuthError.storage(message: "keychain") }
        }

        await store.send(.profile(.backTapped))
        await store.receive(.profile(.delegate(.backRequested))) {
            $0.profile.screen = .loading
        }
        await store.receive(.logoutResponse(.failure(.storage(message: "keychain")))) {
            $0.profile.screen = .actionFailed(message: "로그아웃 정보를 지우지 못했어요. 다시 시도해 주세요.")
        }
    }

    func test_로그아웃_중에는_다시_뒤로를_눌러도_무시한다() async {
        let store = TestStore(
            initialState: OnboardingFlowFeature.State(profile: ProfileSettingFeature.State(screen: .loading))
        ) {
            OnboardingFlowFeature()
        }

        await store.send(.profile(.backTapped))
        await store.send(.profile(.delegate(.backRequested)))
    }
}
