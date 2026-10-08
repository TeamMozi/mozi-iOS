import Domain
import XCTest

final class InterestClientTests: XCTestCase {
    func test_InterestClient_testValue는_생성_가능() {
        _ = InterestClient.testValue
    }

    func test_previewValue는_시안_12개_이름을_격자_순서로_돌려준다() async throws {
        let interests = try await InterestClient.previewValue.interests()
        XCTAssertEqual(
            interests.map(\.name),
            [
                "취미/오락", "자기 계발", "문화/예술",
                "액티비티/스포츠", "친구/또래", "여행/나들이",
                "푸드/드링크", "반려동물", "디저트",
                "스터디", "파티", "기타",
            ]
        )
    }

    func test_previewValue_식별자는_서로_다르다() async throws {
        let interests = try await InterestClient.previewValue.interests()
        XCTAssertEqual(Set(interests.map(\.id)).count, 12)
    }

    func test_previewInterests는_previewValue_목록과_같다() async throws {
        let interests = try await InterestClient.previewValue.interests()
        XCTAssertEqual(InterestClient.previewInterests, interests)
    }
}
