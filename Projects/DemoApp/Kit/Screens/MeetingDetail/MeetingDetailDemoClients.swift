import Domain
import Foundation

/// 모임 상세·위젯 데모의 가짜 Client. 고른 관점의 「나」 로 가짜 서버를 부른다.
/// 데모가 쓰지 않는 칸은 Domain 가짜 데이터(`previewValue`) 그대로다.
public enum MeetingDetailDemoClients {
    public static func meetingClient(
        _ backend: MeetingDetailDemoBackend,
        as state: MeetingDetailDemoState
    ) -> MeetingClient {
        var client = MeetingClient.previewValue
        client.meeting = { _ in try await backend.meeting(as: state) }
        client.delete = { _ in try await backend.deleteMeeting() }
        client.join = { _, _ in try await backend.join(as: state) }
        client.leave = { _ in try await backend.leave(as: state) }
        client.members = { _, status in try await backend.members(status: status) }
        client.approve = { _, userID in try await backend.approve(userID: userID) }
        client.kick = { _, userID in try await backend.kick(userID: userID) }
        client.closeRecruitment = { _ in try await backend.changeStatus(to: .closed) }
        client.reopenRecruitment = { _ in try await backend.changeStatus(to: .recruiting) }
        client.end = { _ in try await backend.changeStatus(to: .ended) }
        client.requestNotification = { _ in try await backend.setNotificationRequested(true) }
        client.cancelNotificationRequest = { _ in try await backend.setNotificationRequested(false) }
        client.notificationRequesters = { _ in try await backend.allRequesters() }
        return client
    }

    /// 시리즈 회차 카드의 포스터와 모임장 사진도 데모 사진으로 바꾼다. `photoURL` 이 nil 이면 Domain 가짜 데이터 그대로다.
    public static func seriesClient(photoURL: URL?) -> SeriesClient {
        var client = SeriesClient.previewValue
        guard let photoURL else { return client }
        let episodes = client.episodes
        client.episodes = { seriesID, page in
            var result = try await episodes(seriesID, page)
            result.items = result.items.map { MeetingDetailDemoPhoto.applied(photoURL, to: $0) }
            return result
        }
        return client
    }

    public static func snapPointClient(_ backend: MeetingDetailDemoBackend) -> SnapPointClient {
        SnapPointClient(
            snapPoints: { _ in try await backend.allSnapPoints() },
            add: { _, draft in try await backend.addSnapPoint(draft) },
            update: { _, snapPointID, draft in try await backend.updateSnapPoint(id: snapPointID, draft: draft) },
            delete: { _, snapPointID in try await backend.deleteSnapPoint(id: snapPointID) },
            sendNotification: { _, snapPointID in try await backend.sendNotification(id: snapPointID) }
        )
    }
}
