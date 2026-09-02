import Domain
import XCTest

final class UserModelTests: XCTestCase {
    func test_성별_rawValue와_동등성() {
        XCTAssertEqual(Gender.male.rawValue, "male")
        XCTAssertEqual(Gender.female.rawValue, "female")
        XCTAssertEqual(Gender.other.rawValue, "other")
        XCTAssertEqual(Gender.male, Gender.male)
    }

    func test_성별_codable_왕복() throws {
        let data = try JSONEncoder().encode(Gender.other)
        let decoded = try JSONDecoder().decode(Gender.self, from: data)
        XCTAssertEqual(decoded, .other)
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
            gender: .other,
            birthDate: Date(timeIntervalSince1970: 1_000),
            interestIDs: ["travel"]
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(UserProfile.self, from: data)
        XCTAssertEqual(decoded, original)
    }

    func test_온보딩초안_동등성_비교() {
        let birthDate = Date(timeIntervalSince1970: 2_000)
        let a = OnboardingDraft(
            nickname: "모지",
            gender: .male,
            birthDate: birthDate,
            interestIDs: ["food"]
        )
        let b = OnboardingDraft(
            nickname: "모지",
            gender: .male,
            birthDate: birthDate,
            interestIDs: ["food"]
        )
        XCTAssertEqual(a, b)
    }
}
