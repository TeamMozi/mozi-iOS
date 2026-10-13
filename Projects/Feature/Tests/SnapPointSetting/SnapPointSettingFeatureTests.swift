import Domain
import Feature
import Foundation
import ThirdParty
import XCTest

@MainActor
final class SnapPointSettingFeatureTests: XCTestCase {
    private func loadedState(_ snapPoints: [SnapPoint], isEnded: Bool = false) -> SnapPointSettingFeature.State {
        var state = SnapPointSettingFeature.State(meetingID: MeetingDetailFixtures.meetingID, isEnded: isEnded)
        state.snapPoints = snapPoints
        state.hasLoaded = true
        return state
    }

    func test_열면_스냅포인트를_읽는다() async {
        let snapPoints = [MeetingDetailFixtures.snapPoint(1)]
        let store = TestStore(
            initialState: SnapPointSettingFeature.State(meetingID: MeetingDetailFixtures.meetingID, isEnded: false)
        ) {
            SnapPointSettingFeature()
        } withDependencies: {
            $0.snapPointClient.snapPoints = { meetingID in
                XCTAssertEqual(meetingID, MeetingDetailFixtures.meetingID)
                return snapPoints
            }
        }

        await store.send(.task) {
            $0.screen = .loading
        }
        await store.receive(.snapPointsLoaded(.success(snapPoints))) {
            $0.screen = .idle
            $0.hasLoaded = true
            $0.snapPoints = snapPoints
        }
        XCTAssertTrue(store.state.canAdd)
    }

    func test_목록을_못_읽으면_네트워크는_표_문구를_나머지는_불러오기_문구를_띄운다() async {
        let cases: [(SnapPointError, String)] = [
            (.network, "네트워크 연결을 확인해 주세요"),
            (.unauthorized, "로그인이 필요해요. 다시 로그인해 주세요."),
            (.unknown(message: "boom"), "스냅 포인트를 불러오지 못했어요"),
        ]
        for (error, message) in cases {
            let store = TestStore(
                initialState: SnapPointSettingFeature.State(meetingID: MeetingDetailFixtures.meetingID, isEnded: false)
            ) {
                SnapPointSettingFeature()
            } withDependencies: {
                $0.snapPointClient.snapPoints = { _ in throw error }
            }

            await store.send(.task) {
                $0.screen = .loading
            }
            await store.receive(.snapPointsLoaded(.failure(error))) {
                $0.screen = .loadFailed(message: message)
            }
        }
    }

    func test_편집기는_이름이_공백뿐이거나_알림_메시지가_50자를_넘으면_완료가_눌리지_않는다() {
        XCTAssertFalse(SnapPointSettingFeature.Editor().canSave)
        XCTAssertFalse(SnapPointSettingFeature.Editor(name: "   ").canSave)
        XCTAssertTrue(SnapPointSettingFeature.Editor(name: "단체 사진").canSave, "알림 메시지는 비어도 된다")
        let fifty = String(repeating: "가", count: 50)
        XCTAssertTrue(SnapPointSettingFeature.Editor(name: "단체 사진", notificationMessage: fifty).canSave)
        XCTAssertFalse(SnapPointSettingFeature.Editor(name: "단체 사진", notificationMessage: fifty + "가").canSave)
    }

    func test_직접_추가는_빈_편집기를_열고_완료하면_더한_스냅포인트를_목록_끝에_둔다() async {
        let added = MeetingDetailFixtures.snapPoint(2)
        let store = TestStore(initialState: loadedState([MeetingDetailFixtures.snapPoint(1)])) {
            SnapPointSettingFeature()
        } withDependencies: {
            $0.snapPointClient.add = { _, draft in
                XCTAssertEqual(draft, SnapPointDraft(name: "스냅 2", notificationMessage: "안내 2"))
                return added
            }
        }

        await store.send(.addTapped) {
            $0.editor = SnapPointSettingFeature.Editor()
        }
        await store.send(.editorSaveTapped)
        await store.send(.editorNameChanged(" 스냅 2 ")) {
            $0.editor?.name = " 스냅 2 "
        }
        await store.send(.editorNotificationMessageChanged("안내 2")) {
            $0.editor?.notificationMessage = "안내 2"
        }
        await store.send(.editorSaveTapped) {
            $0.isRequesting = true
        }
        await store.receive(.saved(added)) {
            $0.isRequesting = false
            $0.editor = nil
            $0.snapPoints = [MeetingDetailFixtures.snapPoint(1), added]
        }
        await store.receive(.delegate(.snapPointsChanged([MeetingDetailFixtures.snapPoint(1), added])))
    }

    func test_추천_카드를_누르면_그_이름과_문구로_바로_더한다() async throws {
        let recommendation = try XCTUnwrap(SnapPointRecommendation.all.first)
        let added = SnapPoint(
            id: "snap-point-new",
            name: recommendation.name,
            notificationMessage: recommendation.notificationMessage,
            order: 1,
            sentAt: nil,
            participantCount: nil
        )
        let store = TestStore(initialState: loadedState([])) {
            SnapPointSettingFeature()
        } withDependencies: {
            $0.snapPointClient.add = { _, draft in
                XCTAssertEqual(draft, recommendation)
                return added
            }
        }

        await store.send(.recommendationTapped(recommendation)) {
            $0.isRequesting = true
        }
        await store.receive(.saved(added)) {
            $0.isRequesting = false
            $0.snapPoints = [added]
        }
        await store.receive(.delegate(.snapPointsChanged([added])))
    }

    func test_열개가_차면_직접_추가도_추천도_눌리지_않는다() async throws {
        let full = (1...10).map { MeetingDetailFixtures.snapPoint($0) }
        let store = TestStore(initialState: loadedState(full)) {
            SnapPointSettingFeature()
        }
        XCTAssertFalse(store.state.canAdd)
        await store.send(.addTapped)
        await store.send(.recommendationTapped(try XCTUnwrap(SnapPointRecommendation.all.first)))
    }

    func test_알림을_보낸_스냅포인트도_수정은_된다() async {
        let sent = MeetingDetailFixtures.snapPoint(1, sentAt: Date(timeIntervalSince1970: 0), participantCount: 3)
        var updated = sent
        updated.name = "도착 인증"
        let store = TestStore(initialState: loadedState([sent])) {
            SnapPointSettingFeature()
        } withDependencies: {
            $0.snapPointClient.update = { [updated] _, snapPointID, draft in
                XCTAssertEqual(snapPointID, sent.id)
                XCTAssertEqual(draft, SnapPointDraft(name: "도착 인증", notificationMessage: sent.notificationMessage))
                return updated
            }
        }

        await store.send(.editTapped(id: sent.id)) {
            $0.editor = SnapPointSettingFeature.Editor(
                snapPointID: sent.id,
                name: sent.name,
                notificationMessage: sent.notificationMessage
            )
        }
        await store.send(.editorNameChanged("도착 인증")) {
            $0.editor?.name = "도착 인증"
        }
        await store.send(.editorSaveTapped) {
            $0.isRequesting = true
        }
        await store.receive(.saved(updated)) {
            $0.isRequesting = false
            $0.editor = nil
            $0.snapPoints = [updated]
        }
        await store.receive(.delegate(.snapPointsChanged([updated])))
    }

    func test_보내지_않은_스냅포인트는_지우고_보낸_것은_지우지_않는다() async {
        let sent = MeetingDetailFixtures.snapPoint(1, sentAt: Date(timeIntervalSince1970: 0), participantCount: 3)
        let unsent = MeetingDetailFixtures.snapPoint(2)
        let store = TestStore(initialState: loadedState([sent, unsent])) {
            SnapPointSettingFeature()
        } withDependencies: {
            $0.snapPointClient.delete = { _, snapPointID in
                XCTAssertEqual(snapPointID, unsent.id)
            }
        }

        XCTAssertFalse(store.state.canDelete(sent))
        await store.send(.deleteTapped(id: sent.id))
        await store.send(.deleteTapped(id: unsent.id)) {
            $0.isRequesting = true
        }
        await store.receive(.deleted(id: unsent.id)) {
            $0.isRequesting = false
            $0.snapPoints = [sent]
        }
        await store.receive(.delegate(.snapPointsChanged([sent])))
    }

    func test_요청_중에도_카드_메뉴는_그린_채_누르지_못하게_한다() {
        var state = loadedState([MeetingDetailFixtures.snapPoint(1)])
        XCTAssertTrue(state.showsCardMenu)
        XCTAssertTrue(state.canEdit)
        state.isRequesting = true
        XCTAssertTrue(state.showsCardMenu, "요청 중에 메뉴가 사라졌다 돌아오지 않는다")
        XCTAssertFalse(state.canEdit)
    }

    func test_종료된_모임에서는_보기만_한다() async throws {
        let snapPoint = MeetingDetailFixtures.snapPoint(1)
        let store = TestStore(initialState: loadedState([snapPoint], isEnded: true)) {
            SnapPointSettingFeature()
        }
        XCTAssertFalse(store.state.canAdd)
        XCTAssertFalse(store.state.canEdit)
        XCTAssertFalse(store.state.showsCardMenu)
        await store.send(.addTapped)
        await store.send(.recommendationTapped(try XCTUnwrap(SnapPointRecommendation.all.first)))
        await store.send(.editTapped(id: snapPoint.id))
        await store.send(.deleteTapped(id: snapPoint.id))
    }

    func test_더하기가_실패하면_편집기를_닫고_오류를_띄운다() async {
        var state = loadedState([])
        state.editor = SnapPointSettingFeature.Editor(name: "단체 사진")
        let store = TestStore(initialState: state) {
            SnapPointSettingFeature()
        } withDependencies: {
            $0.snapPointClient.add = { _, _ in throw SnapPointError.limitExceeded }
        }

        await store.send(.editorSaveTapped) {
            $0.isRequesting = true
        }
        await store.receive(.requestFailed(.limitExceeded)) {
            $0.isRequesting = false
            $0.editor = nil
            $0.screen = .actionFailed(message: "스냅 포인트는 10개까지 등록할 수 있어요")
        }
    }

    func test_도움말은_물음표로_띄우고_닫는다() async {
        let store = TestStore(initialState: loadedState([])) {
            SnapPointSettingFeature()
        }
        await store.send(.helpTapped) {
            $0.isHelpPresented = true
        }
        await store.send(.helpDismissed) {
            $0.isHelpPresented = false
        }
    }

    func test_편집기를_닫으면_더하지_않는다() async {
        let store = TestStore(initialState: loadedState([])) {
            SnapPointSettingFeature()
        }
        await store.send(.addTapped) {
            $0.editor = SnapPointSettingFeature.Editor()
        }
        await store.send(.editorDismissed) {
            $0.editor = nil
        }
    }
}
