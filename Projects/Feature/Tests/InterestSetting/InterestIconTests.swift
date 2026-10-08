@testable import Feature
import XCTest

final class InterestIconTests: XCTestCase {
    func test_시안_12개_이름은_각자의_아이콘이다() {
        let pairs: [(name: String, icon: InterestIcon)] = [
            ("취미/오락", .hobby),
            ("자기 계발", .growth),
            ("문화/예술", .art),
            ("액티비티/스포츠", .activity),
            ("친구/또래", .friend),
            ("여행/나들이", .travel),
            ("푸드/드링크", .food),
            ("반려동물", .pet),
            ("디저트", .dessert),
            ("스터디", .study),
            ("파티", .party),
            ("기타", .etc),
        ]

        for pair in pairs {
            XCTAssertEqual(InterestIcon(interestName: pair.name), pair.icon, pair.name)
        }
        XCTAssertEqual(Set(pairs.map(\.icon)), Set(InterestIcon.allCases))
    }

    func test_시안에_없는_이름은_기타_아이콘이다() {
        for name in ["음악", "", "자기계발", "파티 "] {
            XCTAssertEqual(InterestIcon(interestName: name), .etc, name)
        }
    }
}
