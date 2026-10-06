/// 앵콜 모임 입력. 새 모임을 만든 뒤 `previousMeetingID` 모임과 묶어 시리즈를 만든다.
/// `meeting.seriesID` 는 무시한다. 시리즈는 이 동작이 새로 만든다.
public struct EncoreDraft: Equatable, Sendable {
    public var meeting: MeetingDraft
    public var previousMeetingID: String
    public var seriesTitle: String
    public var seriesIntro: String?

    public init(
        meeting: MeetingDraft,
        previousMeetingID: String,
        seriesTitle: String,
        seriesIntro: String?
    ) {
        self.meeting = meeting
        self.previousMeetingID = previousMeetingID
        self.seriesTitle = seriesTitle
        self.seriesIntro = seriesIntro
    }
}
