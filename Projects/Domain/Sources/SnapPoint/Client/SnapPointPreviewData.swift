import Foundation

/// `SnapPointClient.previewValue` 의 가짜 데이터. 모임장 가짜 모임만 추천 여섯을 갖고, 앞의 둘은 알림을 보냈다.
/// 상태를 들지 않는다. 더하고 고친 결과는 돌려주기만 한다.
enum SnapPointPreviewData {
    static let addedSnapPointID = "preview-snap-point-added"
    /// 모임장 가짜 모임의 시작 시각(2030-10-17 19:00 KST)
    static let meetingStart = Date(timeIntervalSince1970: 1_918_461_600)

    static let hostSnapPoints: [SnapPoint] = SnapPointRecommendation.all.enumerated().map { index, draft in
        let isSent = index < 2
        return SnapPoint(
            id: "preview-snap-point-\(index + 1)",
            name: draft.name,
            notificationMessage: draft.notificationMessage,
            order: index + 1,
            sentAt: isSent ? meetingStart.addingTimeInterval(TimeInterval(index + 1) * 600) : nil,
            participantCount: isSent ? 5 - index : nil
        )
    }

    static func snapPoints(meetingID: String) -> [SnapPoint] {
        meetingID == MeetingClient.PreviewID.host ? hostSnapPoints : []
    }

    static func added(_ draft: SnapPointDraft, meetingID: String) throws -> SnapPoint {
        try validate(draft)
        let current = snapPoints(meetingID: meetingID)
        guard current.count < SnapPointLimit.maxCount else {
            throw SnapPointError.limitExceeded
        }
        return SnapPoint(
            id: addedSnapPointID,
            name: draft.name,
            notificationMessage: draft.notificationMessage,
            order: current.count + 1,
            sentAt: nil,
            participantCount: nil
        )
    }

    static func updated(_ snapPointID: String, with draft: SnapPointDraft, meetingID: String) throws -> SnapPoint {
        try validate(draft)
        var snapPoint = try snapPoint(snapPointID, meetingID: meetingID)
        snapPoint.name = draft.name
        snapPoint.notificationMessage = draft.notificationMessage
        return snapPoint
    }

    static func checkDeletable(_ snapPointID: String, meetingID: String) throws {
        if try snapPoint(snapPointID, meetingID: meetingID).isSent {
            throw SnapPointError.sentSnapPointNotDeletable
        }
    }

    static func sent(_ snapPointID: String, meetingID: String) throws -> SnapPoint {
        var snapPoint = try snapPoint(snapPointID, meetingID: meetingID)
        guard !snapPoint.isSent else { return snapPoint }
        snapPoint.sentAt = meetingStart.addingTimeInterval(3600)
        snapPoint.participantCount = 0
        return snapPoint
    }

    private static func snapPoint(_ snapPointID: String, meetingID: String) throws -> SnapPoint {
        guard let snapPoint = snapPoints(meetingID: meetingID).first(where: { $0.id == snapPointID }) else {
            throw SnapPointError.notFound
        }
        return snapPoint
    }

    private static func validate(_ draft: SnapPointDraft) throws {
        let isNameBlank = draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        guard !isNameBlank, draft.notificationMessage.count <= SnapPointLimit.notificationMessageMaxLength else {
            throw SnapPointError.validation(message: "")
        }
    }
}
