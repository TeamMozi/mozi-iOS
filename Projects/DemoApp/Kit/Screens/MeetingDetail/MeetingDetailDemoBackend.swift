import Domain
import Foundation

/// 모임 상세·위젯 데모의 가짜 서버. 모임 하나와 멤버·알림 요청·스냅 포인트를 메모리에 든다.
/// 데모 화면을 나갈 때까지 남아, 관점을 바꿔도 신청·승인·내보내기·나가기·상태·스냅 포인트 변경이 이어진다.
public actor MeetingDetailDemoBackend {
    /// 데모가 여는 모임. Domain 가짜 데이터의 모임장 모임으로 시작한다
    public static let meetingID = MeetingClient.PreviewID.host
    /// 데모 앱을 쓰는 사람. 모임장이 아닌 관점에서 이 사람이 된다
    static let viewerID = "demo-viewer"
    static let viewerNickname = "나"

    private let sentSnapPointCount: Int
    private let initialStatus: MeetingStatus?
    private let capacity: Int?
    private let photoURL: URL?
    private let now: @Sendable () -> Date
    private var meeting: Meeting?
    private var memberList: [MeetingMember] = []
    private var requesterList: [MeetingMember] = []
    private var snapPointList: [SnapPoint] = []
    private var nextSnapPointNumber = 1
    private var appliedState: MeetingDetailDemoState?

    /// - Parameters:
    ///   - sentSnapPointCount: 처음부터 알림을 보낸 스냅 포인트 수. 위젯 「진행 중」 이 쓴다
    ///   - initialStatus: 모임 상태를 바꿔 시작한다. nil 이면 Domain 가짜 데이터 그대로(모집 중)다. 위젯 데모가 모집 마감을 넘긴다
    ///   - capacity: 정원을 바꿔 시작한다. 정원 참을 볼 때 쓴다
    ///   - photoURL: 모임 포스터와 모임장·멤버·「나」 의 프로필 사진에 같이 쓸 사진. nil 이면 Domain 가짜 데이터 그대로(사진 없음)다
    public init(
        sentSnapPointCount: Int = 0,
        initialStatus: MeetingStatus? = nil,
        capacity: Int? = nil,
        photoURL: URL? = nil,
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.sentSnapPointCount = sentSnapPointCount
        self.initialStatus = initialStatus
        self.capacity = capacity
        self.photoURL = photoURL
        self.now = now
    }

    // MARK: 모임

    func meeting(as state: MeetingDetailDemoState) async throws -> Meeting {
        var current = try await prepared(for: state)
        current.myParticipation = participation(for: state)
        return current
    }

    func join(as state: MeetingDetailDemoState) async throws -> MyParticipation {
        let current = try await prepared(for: state)
        guard participation(for: state) == MyParticipation.none,
              current.status == .recruiting,
              current.joinedCount < current.capacity
        else {
            throw MeetingError.conflict(message: "")
        }
        if current.joinType == .instant {
            placeViewer(as: .joined)
            return .member
        }
        placeViewer(as: .pending)
        return .pending
    }

    func leave(as state: MeetingDetailDemoState) async throws {
        _ = try await prepared(for: state)
        guard state != .host else { throw MeetingError.forbidden }
        placeViewer(as: nil)
    }

    func members(status: MemberStatus?) async throws -> [MeetingMember] {
        try await seedIfNeeded()
        return memberList.filter { status == nil || $0.status == status }
    }

    func allRequesters() async throws -> [MeetingMember] {
        try await seedIfNeeded()
        return requesterList
    }

    func approve(userID: String) async throws {
        let current = try await seeded()
        guard current.status != .ended, current.joinedCount < current.capacity else {
            throw MeetingError.conflict(message: "")
        }
        guard let index = memberList.firstIndex(where: { $0.userID == userID && $0.status == .pending }) else {
            throw MeetingError.notFound
        }
        memberList[index].status = .joined
        meeting?.joinedCount += 1
    }

    func kick(userID: String) async throws {
        let current = try await seeded()
        guard userID != current.host.userID else { throw MeetingError.forbidden }
        guard let index = memberList.firstIndex(where: { $0.userID == userID && $0.status == .joined }) else {
            throw MeetingError.notFound
        }
        memberList.remove(at: index)
        meeting?.joinedCount -= 1
    }

    /// 서버처럼 모집 중 → 종료는 막는다(409). 모집 마감을 거쳐야 종료한다.
    /// 종료는 되돌리지 않고, 정원이 차면 재개하지 않는다.
    func changeStatus(to status: MeetingStatus) async throws -> Meeting {
        var current = try await seeded()
        if current.status == .ended, status != .ended {
            throw MeetingError.conflict(message: "")
        }
        if current.status == .recruiting, status == .ended {
            throw MeetingError.conflict(message: "")
        }
        if status == .recruiting, current.joinedCount >= current.capacity {
            throw MeetingError.conflict(message: "")
        }
        current.status = status
        meeting = current
        current.myParticipation = .host
        return current
    }

    func setNotificationRequested(_ isRequested: Bool) async throws {
        let current = try await seeded()
        guard current.isNotificationRequested != isRequested else { return }
        meeting?.isNotificationRequested = isRequested
        meeting?.notificationRequestCount += isRequested ? 1 : -1
    }

    func deleteMeeting() async throws {
        _ = try await seeded()
    }

    // MARK: 스냅 포인트

    func allSnapPoints() async throws -> [SnapPoint] {
        try await seedIfNeeded()
        return snapPointList
    }

    func addSnapPoint(_ draft: SnapPointDraft) async throws -> SnapPoint {
        try await checkEditable()
        guard snapPointList.count < SnapPointLimit.maxCount else { throw SnapPointError.limitExceeded }
        let snapPoint = SnapPoint(
            id: "demo-snap-point-\(nextSnapPointNumber)",
            name: draft.name,
            notificationMessage: draft.notificationMessage,
            order: (snapPointList.map(\.order).max() ?? 0) + 1,
            sentAt: nil,
            participantCount: nil
        )
        nextSnapPointNumber += 1
        snapPointList.append(snapPoint)
        return snapPoint
    }

    func updateSnapPoint(id: String, draft: SnapPointDraft) async throws -> SnapPoint {
        try await checkEditable()
        guard let index = snapPointList.firstIndex(where: { $0.id == id }) else { throw SnapPointError.notFound }
        snapPointList[index].name = draft.name
        snapPointList[index].notificationMessage = draft.notificationMessage
        return snapPointList[index]
    }

    func deleteSnapPoint(id: String) async throws {
        try await checkEditable()
        guard let index = snapPointList.firstIndex(where: { $0.id == id }) else { throw SnapPointError.notFound }
        guard !snapPointList[index].isSent else { throw SnapPointError.sentSnapPointNotDeletable }
        snapPointList.remove(at: index)
    }

    func sendNotification(id: String) async throws -> SnapPoint {
        let current = try await seeded()
        guard current.status != .ended else { throw SnapPointError.meetingEnded }
        guard let index = snapPointList.firstIndex(where: { $0.id == id }) else { throw SnapPointError.notFound }
        guard !snapPointList[index].isSent else { return snapPointList[index] }
        snapPointList[index].sentAt = now()
        // 참여 수는 가짜다. 지금 참여 인원으로 둔다.
        snapPointList[index].participantCount = current.joinedCount
        return snapPointList[index]
    }

    // MARK: 준비

    private func checkEditable() async throws {
        let current = try await seeded()
        guard current.status != .ended else { throw SnapPointError.meetingEnded }
    }

    private func seeded() async throws -> Meeting {
        try await seedIfNeeded()
        guard let meeting else { throw MeetingError.notFound }
        return meeting
    }

    private func prepared(for state: MeetingDetailDemoState) async throws -> Meeting {
        try await seedIfNeeded()
        apply(state)
        return try await seeded()
    }

    private func seedIfNeeded() async throws {
        guard meeting == nil else { return }
        let preview = MeetingClient.previewValue
        var seed = try await preview.meeting(id: Self.meetingID)
        let seedMembers = try await preview.members(id: Self.meetingID, status: nil)
        let seedRequesters = try await preview.notificationRequesters(id: Self.meetingID)
        // 기다리는 사이 다른 호출이 먼저 채웠으면 그 값을 둔다
        guard meeting == nil else { return }
        if let initialStatus {
            seed.status = initialStatus
        }
        if let capacity {
            seed.capacity = capacity
        }
        memberList = seedMembers
        requesterList = seedRequesters
        if let photoURL {
            seed = MeetingDetailDemoPhoto.applied(photoURL, to: seed)
            memberList = memberList.map { MeetingDetailDemoPhoto.applied(photoURL, to: $0) }
            requesterList = requesterList.map { MeetingDetailDemoPhoto.applied(photoURL, to: $0) }
        }
        snapPointList = Self.seedSnapPoints(sentCount: sentSnapPointCount, joinedCount: seed.joinedCount, now: now())
        nextSnapPointNumber = snapPointList.count + 1
        meeting = seed
    }

    private static func seedSnapPoints(sentCount: Int, joinedCount: Int, now: Date) -> [SnapPoint] {
        SnapPointRecommendation.all.enumerated().map { index, draft in
            let isSent = index < sentCount
            return SnapPoint(
                id: "demo-snap-point-\(index + 1)",
                name: draft.name,
                notificationMessage: draft.notificationMessage,
                order: index + 1,
                // 보낸 것은 지금보다 10분씩 앞서 보냈다
                sentAt: isSent ? now.addingTimeInterval(TimeInterval((index - sentCount) * 600)) : nil,
                participantCount: isSent ? max(joinedCount - index, 0) : nil
            )
        }
    }

    /// 고른 관점에 맞춰 「나」 의 자리를 둔다. 같은 관점이 이어지면 다시 두지 않아, 그 관점에서 한 신청·나가기가 남는다.
    private func apply(_ state: MeetingDetailDemoState) {
        guard appliedState != state else { return }
        appliedState = state
        switch state {
        case .host:
            break
        case .member:
            placeViewer(as: .joined)
        case .pending:
            placeViewer(as: .pending)
        case .applicant:
            placeViewer(as: nil)
        }
    }

    private func placeViewer(as status: MemberStatus?) {
        if memberList.contains(where: { $0.userID == Self.viewerID && $0.status == .joined }) {
            meeting?.joinedCount -= 1
        }
        memberList.removeAll { $0.userID == Self.viewerID }
        guard let status else { return }
        memberList.append(
            MeetingMember(
                userID: Self.viewerID,
                nickname: Self.viewerNickname,
                profileImageURL: photoURL,
                status: status
            )
        )
        if status == .joined {
            meeting?.joinedCount += 1
        }
    }

    private func participation(for state: MeetingDetailDemoState) -> MyParticipation {
        guard state != .host else { return .host }
        switch memberList.first(where: { $0.userID == Self.viewerID })?.status {
        case .joined?:
            return .member
        case .pending?:
            return .pending
        case nil:
            return MyParticipation.none
        }
    }
}
