import Domain
import Foundation
import XCTest

final class MeetingModelTests: XCTestCase {
    func test_모임_칸이_같으면_같은_모임() {
        XCTAssertEqual(MeetingFixtures.meeting(), MeetingFixtures.meeting())
    }

    func test_모임_참여상태가_다르면_다른_모임() {
        XCTAssertNotEqual(
            MeetingFixtures.meeting(myParticipation: .host),
            MeetingFixtures.meeting(myParticipation: .none)
        )
    }

    func test_입력초안_가입방식을_안_주면_바로가입() {
        XCTAssertEqual(MeetingFixtures.draft().joinType, .instant)
    }

    func test_입력초안_칸이_같으면_같은_초안() {
        XCTAssertEqual(MeetingFixtures.draft(seriesID: "series-1"), MeetingFixtures.draft(seriesID: "series-1"))
        XCTAssertNotEqual(MeetingFixtures.draft(seriesID: "series-1"), MeetingFixtures.draft(seriesID: nil))
    }

    func test_사진입력_같은_데이터면_같고_다른_갈래면_다름() {
        XCTAssertEqual(ImageInput.new(Data([1, 2])), ImageInput.new(Data([1, 2])))
        XCTAssertNotEqual(ImageInput.new(Data([1, 2])), ImageInput.new(Data([3])))
        XCTAssertNotEqual(ImageInput.keep, ImageInput.remove)
    }

    func test_앵콜초안_칸이_같으면_같은_초안() {
        let a = EncoreDraft(
            meeting: MeetingFixtures.draft(),
            previousMeetingID: "meeting-0",
            seriesTitle: "뱅드림 필름 라이브 정주행",
            seriesIntro: nil
        )
        let b = EncoreDraft(
            meeting: MeetingFixtures.draft(),
            previousMeetingID: "meeting-0",
            seriesTitle: "뱅드림 필름 라이브 정주행",
            seriesIntro: nil
        )
        XCTAssertEqual(a, b)
    }

    func test_앵콜결과_시리즈실패는_시리즈생성과_다름() {
        let meeting = MeetingFixtures.meeting()
        XCTAssertEqual(
            EncoreResult.meetingOnly(meeting, .network),
            EncoreResult.meetingOnly(meeting, .network)
        )
        XCTAssertNotEqual(
            EncoreResult.created(meeting, MeetingFixtures.series()),
            EncoreResult.meetingOnly(meeting, .network)
        )
    }

    func test_멤버_칸이_같으면_같은_멤버() {
        let a = MeetingMember(userID: "u1", nickname: "필름덕후", profileImageURL: nil, status: .pending)
        let b = MeetingMember(userID: "u1", nickname: "필름덕후", profileImageURL: nil, status: .pending)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, MeetingMember(userID: "u1", nickname: "필름덕후", profileImageURL: nil, status: .joined))
    }

    func test_연령제한_칸이_같으면_같고_하한이_다르면_다름() {
        XCTAssertEqual(AgeRange(minAge: nil, maxAge: nil), AgeRange(minAge: nil, maxAge: nil))
        XCTAssertNotEqual(AgeRange(minAge: 20, maxAge: nil), AgeRange(minAge: nil, maxAge: nil))
    }

    func test_모임에러_메시지가_다르면_다른_에러() {
        XCTAssertEqual(MeetingError.conflict(message: "정원 초과"), MeetingError.conflict(message: "정원 초과"))
        XCTAssertNotEqual(MeetingError.conflict(message: "정원 초과"), MeetingError.conflict(message: "이미 신청함"))
        XCTAssertNotEqual(MeetingError.joinRestricted, MeetingError.forbidden)
    }

    func test_모임_상한_상수는_스펙_값() {
        XCTAssertEqual(MeetingLimit.titleMaxLength, 20)
        XCTAssertEqual(MeetingLimit.introMaxLength, 50)
        XCTAssertEqual(MeetingLimit.detailMaxLength, 500)
        XCTAssertEqual(MeetingLimit.capacityRange, 2...60)
    }
}
