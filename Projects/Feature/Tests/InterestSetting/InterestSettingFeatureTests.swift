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

private let sampleInterests = [
    Interest(id: "1", name: "취미/오락"),
    Interest(id: "2", name: "자기 계발"),
    Interest(id: "3", name: "문화/예술"),
    Interest(id: "4", name: "액티비티/스포츠"),
    Interest(id: "5", name: "친구/또래"),
    Interest(id: "6", name: "여행/나들이"),
]

@MainActor
final class InterestSettingFeatureTests: XCTestCase {
    func test_처음_나타나면_목록을_받아_그린다() async {
        let store = TestStore(initialState: InterestSettingFeature.State(draft: onboardingDraft)) {
            InterestSettingFeature()
        } withDependencies: {
            $0.interestClient.interests = { sampleInterests }
        }

        await store.send(.onAppear) {
            $0.screen = .loading
        }
        await store.receive(.interestsResponse(.success(sampleInterests))) {
            $0.interests = sampleInterests
            $0.screen = .idle
        }
    }

    func test_목록을_이미_받았으면_다시_나타나도_받지_않는다() async {
        let store = TestStore(
            initialState: InterestSettingFeature.State(draft: onboardingDraft, interests: sampleInterests)
        ) {
            InterestSettingFeature()
        }

        await store.send(.onAppear)
    }

    func test_목록_받기에_실패하면_다시_시도_화면에_표_문구를_쓴다() async {
        let store = TestStore(initialState: InterestSettingFeature.State(draft: onboardingDraft)) {
            InterestSettingFeature()
        } withDependencies: {
            $0.interestClient.interests = { throw InterestError.network }
        }

        await store.send(.onAppear) {
            $0.screen = .loading
        }
        await store.receive(.interestsResponse(.failure(.network))) {
            $0.screen = .loadFailed(message: "네트워크 연결을 확인해 주세요")
        }
    }

    func test_빈_목록이면_다시_시도_화면을_띄운다() async {
        let store = TestStore(initialState: InterestSettingFeature.State(draft: onboardingDraft)) {
            InterestSettingFeature()
        } withDependencies: {
            $0.interestClient.interests = { [] }
        }

        await store.send(.onAppear) {
            $0.screen = .loading
        }
        await store.receive(.interestsResponse(.success([]))) {
            $0.screen = .loadFailed(message: "카테고리를 불러오지 못했어요. 다시 시도해 주세요.")
        }
    }

    func test_다시_시도를_누르면_목록을_다시_받는다() async {
        let store = TestStore(
            initialState: InterestSettingFeature.State(
                draft: onboardingDraft,
                screen: .loadFailed(message: "네트워크 연결을 확인해 주세요")
            )
        ) {
            InterestSettingFeature()
        } withDependencies: {
            $0.interestClient.interests = { sampleInterests }
        }

        await store.send(.retryTapped) {
            $0.screen = .loading
        }
        await store.receive(.interestsResponse(.success(sampleInterests))) {
            $0.interests = sampleInterests
            $0.screen = .idle
        }
    }

    func test_칸을_누르면_고르고_다시_누르면_풀린다() async {
        let store = TestStore(
            initialState: InterestSettingFeature.State(draft: onboardingDraft, interests: sampleInterests)
        ) {
            InterestSettingFeature()
        }

        await store.send(.interestTapped(id: "2")) {
            $0.selectedIDs = ["2"]
        }
        await store.receive(.delegate(.selectionChanged(["2"])))
        XCTAssertTrue(store.state.isSelected(sampleInterests[1]))
        await store.send(.interestTapped(id: "2")) {
            $0.selectedIDs = []
        }
        await store.receive(.delegate(.selectionChanged([])))
    }

    func test_5개를_고르면_나머지_칸은_눌러도_아무_일이_없다() async {
        let store = TestStore(
            initialState: InterestSettingFeature.State(
                draft: onboardingDraft,
                interests: sampleInterests,
                selectedIDs: ["1", "2", "3", "4", "5"]
            )
        ) {
            InterestSettingFeature()
        }

        await store.send(.interestTapped(id: "6"))
        await store.send(.interestTapped(id: "5")) {
            $0.selectedIDs = ["1", "2", "3", "4"]
        }
        await store.receive(.delegate(.selectionChanged(["1", "2", "3", "4"])))
    }

    func test_완료는_목록이_있고_하나_이상_골랐고_받는_중도_저장_중도_아닐_때만_켜진다() {
        XCTAssertFalse(
            InterestSettingFeature.State(draft: onboardingDraft, interests: sampleInterests).isCompleteEnabled
        )
        XCTAssertTrue(
            InterestSettingFeature.State(draft: onboardingDraft, interests: sampleInterests, selectedIDs: ["1"])
                .isCompleteEnabled
        )
        XCTAssertFalse(
            InterestSettingFeature.State(
                draft: onboardingDraft,
                interests: sampleInterests,
                selectedIDs: ["1"],
                isSaving: true
            ).isCompleteEnabled
        )
        XCTAssertFalse(InterestSettingFeature.State(draft: onboardingDraft, selectedIDs: ["1"]).isCompleteEnabled)
        XCTAssertFalse(
            InterestSettingFeature.State(
                draft: onboardingDraft,
                interests: sampleInterests,
                selectedIDs: ["1"],
                screen: .loading
            ).isCompleteEnabled
        )
    }

    func test_고른_칸을_되살린_채_목록을_받는_중에는_완료를_눌러도_저장하지_않는다() async {
        // 받기가 「완료」 뒤에 끝나도록 막아 둔다
        let (gate, gateOpener) = AsyncStream<Void>.makeStream()
        let store = TestStore(
            initialState: InterestSettingFeature.State(draft: onboardingDraft, selectedIDs: ["2"])
        ) {
            InterestSettingFeature()
        } withDependencies: {
            $0.interestClient.interests = {
                for await _ in gate { break }
                return sampleInterests
            }
        }

        await store.send(.onAppear) {
            $0.screen = .loading
        }
        await store.send(.completeTapped)
        gateOpener.yield()
        await store.receive(.interestsResponse(.success(sampleInterests))) {
            $0.interests = sampleInterests
            $0.screen = .idle
        }
    }

    func test_고른_칸을_되살린_채_목록_받기에_실패하면_완료를_눌러도_저장하지_않는다() async {
        let store = TestStore(
            initialState: InterestSettingFeature.State(draft: onboardingDraft, selectedIDs: ["2"])
        ) {
            InterestSettingFeature()
        } withDependencies: {
            $0.interestClient.interests = { throw InterestError.network }
        }

        await store.send(.onAppear) {
            $0.screen = .loading
        }
        await store.receive(.interestsResponse(.failure(.network))) {
            $0.screen = .loadFailed(message: "네트워크 연결을 확인해 주세요")
        }
        await store.send(.completeTapped)
    }

    func test_고른_칸이_없으면_완료를_눌러도_저장하지_않는다() async {
        let store = TestStore(
            initialState: InterestSettingFeature.State(draft: onboardingDraft, interests: sampleInterests)
        ) {
            InterestSettingFeature()
        }

        await store.send(.completeTapped)
    }

    func test_완료를_누르면_고른_칸을_담아_한_번_저장하고_끝을_올린다() async {
        let received = LockIsolated<[OnboardingDraft]>([])
        let store = TestStore(
            initialState: InterestSettingFeature.State(
                draft: onboardingDraft,
                interests: sampleInterests,
                selectedIDs: ["2", "6"]
            )
        ) {
            InterestSettingFeature()
        } withDependencies: {
            $0.userClient.completeOnboarding = { draft in
                received.withValue { $0.append(draft) }
            }
        }

        await store.send(.completeTapped) {
            $0.isSaving = true
            $0.screen = .loading
        }
        await store.receive(.completeResponse(.success(InterestSettingFeature.EquatableVoid()))) {
            $0.isSaving = false
            $0.screen = .idle
        }
        await store.receive(.delegate(.finished))

        var expected = onboardingDraft
        expected.interestIDs = ["2", "6"]
        XCTAssertEqual(received.value, [expected])
    }

    func test_저장에_실패하면_고른_칸을_두고_표_문구_알림을_띄운다() async {
        let store = TestStore(
            initialState: InterestSettingFeature.State(
                draft: onboardingDraft,
                interests: sampleInterests,
                selectedIDs: ["2"]
            )
        ) {
            InterestSettingFeature()
        } withDependencies: {
            $0.userClient.completeOnboarding = { _ in throw UserError.validation(message: "닉네임 길이 초과") }
        }

        await store.send(.completeTapped) {
            $0.isSaving = true
            $0.screen = .loading
        }
        await store.receive(.completeResponse(.failure(.validation(message: "닉네임 길이 초과")))) {
            $0.isSaving = false
            $0.screen = .actionFailed(message: "입력한 내용을 확인해 주세요.")
        }
        await store.send(.failureDismissed) {
            $0.screen = .idle
        }
    }

    func test_저장_중에는_칸과_완료와_다시_시도를_무시한다() async {
        let store = TestStore(
            initialState: InterestSettingFeature.State(
                draft: onboardingDraft,
                interests: sampleInterests,
                selectedIDs: ["2"],
                isSaving: true,
                screen: .loading
            )
        ) {
            InterestSettingFeature()
        }

        await store.send(.interestTapped(id: "3"))
        await store.send(.interestTapped(id: "2"))
        await store.send(.completeTapped)
        await store.send(.retryTapped)
    }
}
