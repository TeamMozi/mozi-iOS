import Domain
import XCTest

final class UserModelTests: XCTestCase {
    func test_성별은_남자_여자_둘이고_rawValue는_소문자다() {
        XCTAssertEqual(Gender.male.rawValue, "male")
        XCTAssertEqual(Gender.female.rawValue, "female")
        XCTAssertEqual([Gender.male, .female].map(label), ["남자", "여자"])
    }

    func test_성별_codable_왕복() throws {
        let data = try JSONEncoder().encode(Gender.female)
        XCTAssertEqual(try JSONDecoder().decode(Gender.self, from: data), .female)
    }

    func test_관심사_동등성_비교() {
        let a = Interest(id: "sports", name: "운동")
        let b = Interest(id: "sports", name: "운동")
        XCTAssertEqual(a, b)
    }

    func test_관심사_codable_왕복() throws {
        let original = Interest(id: "music", name: "음악")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Interest.self, from: data)
        XCTAssertEqual(decoded, original)
    }

    func test_프로필_동등성_비교() {
        let birthDate = Date(timeIntervalSince1970: 0)
        let a = UserProfile(
            nickname: "모지",
            gender: .female,
            birthDate: birthDate,
            interestIDs: ["sports", "music"]
        )
        let b = UserProfile(
            nickname: "모지",
            gender: .female,
            birthDate: birthDate,
            interestIDs: ["sports", "music"]
        )
        XCTAssertEqual(a, b)
    }

    func test_프로필_codable_왕복() throws {
        let original = UserProfile(
            nickname: "모지",
            gender: .male,
            birthDate: Date(timeIntervalSince1970: 1_000),
            interestIDs: ["travel"]
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(UserProfile.self, from: data)
        XCTAssertEqual(decoded, original)
    }

    func test_온보딩초안은_입력값을_그대로_담는다() {
        let draft = OnboardingDraft(
            nickname: "수연",
            birthDate: Date(timeIntervalSince1970: 2_000),
            gender: .female,
            introduction: nil,
            profileImage: .keep,
            interestIDs: ["1", "5"]
        )
        XCTAssertEqual(draft.nickname, "수연")
        XCTAssertEqual(draft.birthDate, Date(timeIntervalSince1970: 2_000))
        XCTAssertEqual(draft.gender, .female)
        XCTAssertNil(draft.introduction)
        XCTAssertEqual(draft.profileImage, .keep)
        XCTAssertEqual(draft.interestIDs, ["1", "5"])
    }

    func test_온보딩초안_사진이_다르면_다르다() {
        let kept = OnboardingDraft(
            nickname: "수연",
            birthDate: Date(timeIntervalSince1970: 2_000),
            gender: .female,
            introduction: "안녕하세요",
            profileImage: .keep,
            interestIDs: []
        )
        var picked = kept
        picked.profileImage = .new(Data([1, 2, 3]))
        XCTAssertNotEqual(kept, picked)
    }

    func test_사용자_오류는_모임_오류와_같은_일곱_종류다() {
        let all: [UserError] = [
            .network, .unauthorized, .forbidden, .notFound,
            .conflict(message: ""), .validation(message: ""), .unknown(message: ""),
        ]
        XCTAssertEqual(
            all.map(kind),
            ["network", "unauthorized", "forbidden", "notFound", "conflict", "validation", "unknown"]
        )
        XCTAssertNotEqual(UserError.conflict(message: "a"), .conflict(message: "b"))
    }

    func test_사용자_입력_상한은_닉네임_10_소개_50_카테고리_5() {
        XCTAssertEqual(UserLimit.nicknameMaxLength, 10)
        XCTAssertEqual(UserLimit.introductionMaxLength, 50)
        XCTAssertEqual(UserLimit.interestMaxCount, 5)
    }

    // 종류가 늘거나 줄면 컴파일이 깨진다
    private func label(_ gender: Gender) -> String {
        switch gender {
        case .male: "남자"
        case .female: "여자"
        }
    }

    private func kind(_ error: UserError) -> String {
        switch error {
        case .network: "network"
        case .unauthorized: "unauthorized"
        case .forbidden: "forbidden"
        case .notFound: "notFound"
        case .conflict: "conflict"
        case .validation: "validation"
        case .unknown: "unknown"
        }
    }
}
