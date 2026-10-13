extension MeetingPreviewData {
    /// 상태 바꾸기를 흉내 낸다. 상태를 들지 않고 바뀐 모임을 돌려주기만 한다.
    /// 종료된 모임은 다른 상태로 바꾸지 않고, 모집 재개는 정원이 차 있으면 막는다.
    /// 모집 중인 모임은 바로 종료하지 않는다. 서버처럼 모집 마감을 거쳐야 한다(409).
    static func meeting(id: String, changingStatusTo status: MeetingStatus) throws -> Meeting {
        var changed = try Self.meeting(id: id)
        if changed.status == .ended, status != .ended {
            throw MeetingError.conflict(message: "")
        }
        if changed.status == .recruiting, status == .ended {
            throw MeetingError.conflict(message: "")
        }
        if status == .recruiting, changed.joinedCount >= changed.capacity {
            throw MeetingError.conflict(message: "")
        }
        changed.status = status
        return changed
    }
}
