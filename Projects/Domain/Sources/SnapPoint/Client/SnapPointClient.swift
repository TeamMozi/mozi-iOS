import Foundation
import ThirdParty

/// 모임의 스냅 포인트를 다루는 Domain 포트. 모든 동작이 모임 id 를 받는다. 서버 API 가 아직 없다.
@DependencyClient
public struct SnapPointClient: Sendable {
    /// 추가한 순서(`order` 오름차순)로 돌려준다.
    public var snapPoints: @Sendable (_ meetingID: String) async throws -> [SnapPoint]
    /// 모임마다 `SnapPointLimit.maxCount` 개까지다. 넘으면 `.limitExceeded`, 종료된 모임이면 `.meetingEnded` 다.
    public var add: @Sendable (_ meetingID: String, _ draft: SnapPointDraft) async throws -> SnapPoint
    /// 알림을 보낸 스냅 포인트도 고친다. 종료된 모임이면 `.meetingEnded` 다.
    public var update: @Sendable (
        _ meetingID: String,
        _ snapPointID: String,
        _ draft: SnapPointDraft
    ) async throws -> SnapPoint
    /// 알림을 보낸 스냅 포인트는 지우지 않는다(`.sentSnapPointNotDeletable`).
    public var delete: @Sendable (_ meetingID: String, _ snapPointID: String) async throws -> Void
    /// 멤버에게 촬영 알림을 보낸다. 보낸 시각과 참여 수가 찬 스냅 포인트를 돌려준다.
    /// 아무 순서로나 보낸다. 다시 보내기는 없다(화면이 막는다).
    public var sendNotification: @Sendable (_ meetingID: String, _ snapPointID: String) async throws -> SnapPoint
}

extension SnapPointClient: TestDependencyKey {
    public static let testValue = SnapPointClient()
    public static let previewValue = SnapPointClient(
        snapPoints: { meetingID in
            SnapPointPreviewData.snapPoints(meetingID: meetingID)
        },
        add: { meetingID, draft in
            try SnapPointPreviewData.added(draft, meetingID: meetingID)
        },
        update: { meetingID, snapPointID, draft in
            try SnapPointPreviewData.updated(snapPointID, with: draft, meetingID: meetingID)
        },
        delete: { meetingID, snapPointID in
            try SnapPointPreviewData.checkDeletable(snapPointID, meetingID: meetingID)
        },
        sendNotification: { meetingID, snapPointID in
            try SnapPointPreviewData.sent(snapPointID, meetingID: meetingID)
        }
    )
}

public extension DependencyValues {
    var snapPointClient: SnapPointClient {
        get { self[SnapPointClient.self] }
        set { self[SnapPointClient.self] = newValue }
    }
}
